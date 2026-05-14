##TCL MODE
yosys -import

#extract vars
set design $env(design)
set rtl_dataset_path $env(rtl_dataset_path)
set pdk_path $env(pdk_path)
set output_dir $env(output_dir)

#set MAN_MODE $env(MAN_MODE)
#if { ${MAN_MODE} } { source ../config.tcl } else { source config.tcl }

#read rtl
set rtl_list [glob $rtl_dataset_path/designs/$design/rtl/*.v]
foreach rtl $rtl_list {
	read_verilog $rtl
}

#read system verilog
#set rtl_list [glob $rtl_dataset_path/designs/$design/rtl/*.sv]
#foreach rtl $rtl_list {
#	#read_verilog -sv $rtl
#}

##PDK VARS
if {[regexp {freepdk45} $pdk_path]} {
    set liberty "$pdk_path/libs/nangate45/nldm/NangateOpenCellLibrary_typical.lib"
    set techmap_verilog_files [glob $pdk_path/libs/nangate45/techmap/yosys/*]
    set pdk_name "freepdk45"
}

if {[regexp {gf180} $pdk_path]} {
    set liberty "$pdk_path/libs/gf180mcu_fd_sc_mcu9t5v0/nldm/gf180mcu_fd_sc_mcu9t5v0__ss_125C_4v50.lib.gz"
    set techmap_verilog_files [glob $pdk_path/libs/gf180mcu_fd_sc_mcu9t5v0/techmap/yosys/*]
    set pdk_name "gf180"
}

##READ LIBERTY LATCH
read_liberty -ignore_miss_func -ignore_miss_dir -ignore_miss_data_latch -lib $liberty

##SYNT
hierarchy -check -top $design
proc_clean
proc_rmdead
proc_prune
proc_init
proc_arst
proc_rom
proc_mux
proc_dlatch
proc_dff
proc_memwr
proc_clean
opt_expr

#flatten or no
flatten


opt_expr
opt_clean
opt -nodffe -nosdff
fsm
opt
wreduce
peepopt
opt_clean
alumacc
share
opt
memory -nomap
opt_clean
opt -fast -full
memory_map
opt -full
techmap
foreach file $techmap_verilog_files {
	techmap -map $file
}
opt -fast
abc -fast
opt -fast
hierarchy -check -top $design
stat
check

opt
opt_clean -purge

##ABC

dfflibmap -liberty $liberty

#set D [expr 10 * 1000]

abc -liberty $liberty \
-dont_use *clk* -dont_use *edfxtp* -dont_use *decap* -dont_use *dly*  -dont_use *diode*  -dont_use *ebuf*  -dont_use *ebuf*  -dont_use *ed*  -dont_use *ei*  -dont_use *lpflow*  -dont_use *probe*  -dont_use *sd*  -dont_use *tap*  -dont_use *bufbuf*  -dont_use *bufinv*  -dont_use *conb*  -dont_use *metal*   -dont_use *diode*  -dont_use *tap*


tee -o ${output_dir}/${pdk_name}/${design}/run_0/stat.txt stat -top $design -liberty $liberty

##Clean up the design (just the last step of opt)
#clean
splitnets
clean -purge

##autoname

# write synthesized design
write_verilog -noattr -noexpr -nohex -nodec ${output_dir}/${pdk_name}/${design}/run_0/${design}.v