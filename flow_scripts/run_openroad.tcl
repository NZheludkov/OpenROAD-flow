# =====================================
# Basic run vars
# =====================================

set design              $env(design)
set rtl_dataset_path    $env(rtl_dataset_path)
set pdk_path            $env(pdk_path)
set output_dir          $env(output_dir)

# =====================================
# Timing / floorplan vars
# =====================================

set CLK_PERIOD          $env(CLK_PERIOD)
set IO_DELAY            $env(IO_DELAY)

set CU                  $env(CU)
set AR                  $env(AR)

# =====================================
# PDN vars
# =====================================

set PDN_HWIDTH          $env(PDN_HWIDTH)
set PDN_HSPACING        $env(PDN_HSPACING)
set PDN_HPITCH          $env(PDN_HPITCH)

set PDN_VWIDTH          $env(PDN_VWIDTH)
set PDN_VSPACING        $env(PDN_VSPACING)
set PDN_VPITCH          $env(PDN_VPITCH)

# =====================================
# PDK vars
# =====================================

set tech_lef            $env(tech_lef)
set cells_lef           $env(cells_lef)
set lef_list            $env(lef_list)

set liberty             $env(liberty)

set core_site           $env(core_site)

set tap_cell            $env(tap_cell)
set endcap_cell         $env(endcap_cell)
set tap_cell_distance   $env(tap_cell_distance)

set techmap_verilog_files $env(techmap_verilog_files)

set bottom_routing_metal $env(bottom_routing_metal)
set top_routing_metal    $env(top_routing_metal)

set pins_hor_layers      $env(pins_hor_layers)
set pins_ver_layers      $env(pins_ver_layers)

set wire_rc_metal        $env(wire_rc_metal)

set tiehi_cell           $env(tiehi_cell)
set tielo_cell           $env(tielo_cell)

set tiehi_cell_pin       $env(tiehi_cell_pin)
set tielo_cell_pin       $env(tielo_cell_pin)

set filler_cells         $env(filler_cells)
set dont_use_cells       $env(dont_use_cells)

set max_slew_cts         $env(max_slew_cts)
set max_cap_cts          $env(max_cap_cts)

set cts_root_buf         $env(cts_root_buf)
set cts_buf_list         $env(cts_buf_list)

set process_node         $env(process_node)

set rc_extract_file      $env(rc_extract_file)

set pdk_name             $env(pdk_name)

if {0} {

##PDK VARS
if {[regexp {freepdk45} $pdk_path]} {
	set tech_lef "${pdk_path}/base/apr/freepdk45.tech.lef"
	set cells_lef "${pdk_path}/libs/nangate45/lef/NangateOpenCellLibrary.macro.mod.lef"
	set lef_list [concat $tech_lef $cells_lef]
    set liberty "$pdk_path/libs/nangate45/nldm/NangateOpenCellLibrary_typical.lib"
    set core_site "FreePDK45_38x28_10R_NP_162NW_34O"
    set tap_cell "TAPCELL_X1"
    set endcap_cell "TAPCELL_X1"
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
    set rc_extract_file "${pdk_path}/base/pex/openroad/typical.rules"
    set pdk_name "freepdk45"

    #defualt runs params
    set CLK_PERIOD "100.0"
    set IO_DELAY "0.33"
    set CU "20"
    set AR "1.0"
    set PDN_HWIDTH "1.6"
    set PDN_HSPACING "1.6"
    set PDN_HPITCH "16"
    set PDN_VWIDTH "1.6"
    set PDN_VSPACING "1.6"
    set PDN_VPITCH "16"
}

if {[regexp {gf180} $pdk_path]} {
    set tech_lef "${pdk_path}/base/apr/gf180mcu_6LM_1TM_9K_9t_tech.lef"
    set cells_lef "${pdk_path}/libs/gf180mcu_fd_sc_mcu9t5v0/lef/gf180mcu_fd_sc_mcu9t5v0.lef"
    set lef_list [concat $tech_lef $cells_lef]
    set liberty "$pdk_path/libs/gf180mcu_fd_sc_mcu9t5v0/nldm/gf180mcu_fd_sc_mcu9t5v0__ss_125C_4v50.lib.gz"
    set core_site "GF018hv5v_green_sc9"
    set tap_cell "gf180mcu_fd_sc_mcu9t5v0__filltie"
    set endcap_cell "gf180mcu_fd_sc_mcu9t5v0__endcap"
    set tap_cell_distance "25"
    set techmap_verilog_files [glob $pdk_path/libs/gf180mcu_fd_sc_mcu9t5v0/techmap/yosys/*]
    set bottom_routing_metal "Metal1"
    set top_routing_metal "MetalTop"
    set pins_hor_layers "Metal3 Metal5"
    set pins_ver_layers "Metal2 Metal4"
    set wire_rc_metal "Metal3"
    set tiehi_cell "gf180mcu_fd_sc_mcu9t5v0__tieh"
    set tielo_cell "gf180mcu_fd_sc_mcu9t5v0__tiel"
    set tiehi_cell_pin "Z"
    set tielo_cell_pin "ZN"
    set filler_cells "gf180mcu_fd_sc_mcu9t5v0__fillcap_64 gf180mcu_fd_sc_mcu9t5v0__fillcap_32 gf180mcu_fd_sc_mcu9t5v0__fillcap_16 gf180mcu_fd_sc_mcu9t5v0__fillcap_8 gf180mcu_fd_sc_mcu9t5v0__fillcap_4 gf180mcu_fd_sc_mcu9t5v0__fill_1 gf180mcu_fd_sc_mcu9t5v0__fill_2"
    set dont_use_cells "gf180mcu_fd_sc_mcu9t5v0__antenna gf180mcu_fd_sc_mcu9t5v0__clk* gf180mcu_fd_sc_mcu9t5v0__endcap gf180mcu_fd_sc_mcu9t5v0__fill* gf180mcu_fd_sc_mcu9t5v0__lat* gf180mcu_fd_sc_mcu9t5v0__tie*"
    set max_slew_cts "0.5"
    set max_cap_cts "0.3"
    set cts_root_buf "gf180mcu_fd_sc_mcu9t5v0__clkinv_16"
    set cts_buf_list "gf180mcu_fd_sc_mcu9t5v0__clkinv_1 gf180mcu_fd_sc_mcu9t5v0__clkinv_2 gf180mcu_fd_sc_mcu9t5v0__clkinv_4 gf180mcu_fd_sc_mcu9t5v0__clkinv_8 gf180mcu_fd_sc_mcu9t5v0__clkinv_16"
    set process_node "180"
    set rc_extract_file "${pdk_path}/base/pex/openroad/gf180mcu_1p6m_1tm_9k_sp_smim_OPTB_wst.rules"
    set pdk_name "gf180"

    #defualt runs params
    set CLK_PERIOD "100.0"
    set IO_DELAY "0.33"
    set CU "20"
    set AR "1.0"
    set PDN_HWIDTH "4.4"
    set PDN_HSPACING "4.4"
    set PDN_HPITCH "44"
    set PDN_VWIDTH "4.4"
    set PDN_VSPACING "4.4"
    set PDN_VPITCH "44"
}

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

