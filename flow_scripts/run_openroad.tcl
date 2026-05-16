#extract vars
set design $env(design)
set rtl_dataset_path $env(rtl_dataset_path)
set pdk_path $env(pdk_path)
set output_dir $env(output_dir)

##PDK VARS
if {[regexp {freepdk45} $pdk_path]} {
	set tech_lef "${pdk_path}/base/apr/freepdk45.tech.lef"
	set cells_lef "${pdk_path}/libs/nangate45/lef/NangateOpenCellLibrary.macro.mod.lef"
	set lef_list [concat $tech_lef $cells_lef]
    set liberty "$pdk_path/libs/nangate45/nldm/NangateOpenCellLibrary_typical.lib"
    set core_site "FreePDK45_38x28_10R_NP_162NW_34O"
    set tap_cell "TAPCELL_X1"
    set tap_cell_distance "120"
    set techmap_verilog_files [glob $pdk_path/libs/nangate45/techmap/yosys/*]
    set bottom_routing_metal "metal1"
    set top_routing_metal "metal10"
    set pins_hor_layers "metal3 metal5"
    set pins_ver_layers "metal2 metal4"
    set wire_rc_metal "metal3"
    set tiehi_cell "LOGIC1_X1"
    set tielo_cell "LOGIC0_X1"
    set tiehi_cell_pin "Z"
    set tielo_cell_pin "Z"
    set filler_cells "FILLCELL_X1 FILLCELL_X2 FILLCELL_X4 FILLCELL_X8 FILLCELL_X16 FILLCELL_X32"
    set dont_use_cells "ANTENNA_X1 FILL* LOGIC* TAPCELL_X1 TBUF* TINV* TLAT*"
    set max_slew_cts "0.5"
    set max_cap_cts "0.3"
    set cts_root_buf "CLKBUF_X3"
    set cts_buf_list "CLKBUF_X1 CLKBUF_X2 CLKBUF_X3"
    set process_node "45"
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

#source procs
source ./flow_scripts/procs.tcl

#init design
source ./flow_scripts/init_design.tcl

#create floorplan
source ./flow_scripts/create_floorplan.tcl

#prects 
source ./flow_scripts/prects.tcl

#cts 
source ./flow_scripts/cts.tcl

#postcts 
source ./flow_scripts/postcts.tcl

#route 
source ./flow_scripts/route.tcl

