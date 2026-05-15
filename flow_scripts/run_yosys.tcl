##TCL MODE
yosys -import

#extract vars
set design $env(design)
set rtl_dataset_path $env(rtl_dataset_path)
set pdk_path $env(pdk_path)
set output_dir $env(output_dir)

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

##source config
source $rtl_dataset_path/designs/${design}/config.tcl

set folder_name ""

if {[info exists CLK_PERIOD]} { append folder_name "CLK_${CLK_PERIOD}_" }
if {[info exists IO_DELAY]} { append folder_name "IO_${IO_DELAY}_" }
if {[info exists CU]} { append folder_name "CU_${CU}_" }
if {[info exists AR]} { append folder_name "AR_${AR}_" }
if {[info exists PDN_HWIDTH]} { append folder_name "HW_${PDN_HWIDTH}_" }
if {[info exists PDN_HSPACING]} { append folder_name "HS_${PDN_HSPACING}_" }
if {[info exists PDN_HPITCH]} { append folder_name "HP_${PDN_HPITCH}_" }
if {[info exists PDN_VWIDTH]} { append folder_name "VW_${PDN_VWIDTH}_" }
if {[info exists PDN_VSPACING]} { append folder_name "VS_${PDN_VSPACING}_" }
if {[info exists PDN_VPITCH]} { append folder_name "VP_${PDN_VPITCH}_" }

# Удаляем последний символ "_"
set folder_name [string trimright $folder_name "_"]
set folder_name $output_dir/${pdk_name}/${design}/$folder_name

# Создаем папку
exec mkdir -p $folder_name

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

exec mkdir -p ${folder_name}/netlist_synt_stat/
tee -o ${folder_name}/netlist_synt_stat/stat.txt stat -top $design -liberty $liberty

##Clean up the design (just the last step of opt)
#clean
splitnets
clean -purge

##autoname

# write synthesized design
exec mkdir -p ${folder_name}/netlist_synt/
write_verilog -noattr -noexpr -nohex -nodec ${folder_name}/netlist_synt/${design}.v