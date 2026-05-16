##START TIME
set start_time [exec date +%s]

##CREATE FP
initialize_floorplan -utilization $CU -core_space 3 -aspect_ratio $AR -site $core_site

##INIT ROWS (ADD ENDCAP and TRACKS)  
tapcell \
-distance $tap_cell_distance \
-tapcell_master $tap_cell \
-endcap_master $tap_cell

##CREATE LAYER TRACKS
make_tracks

##CREATE POWER GROUND GRID
pdngen -reset

#GLOBAL NET CONNECT
add_global_connection -net VDD -pin_pattern "VDD" -power
add_global_connection -net VSS -pin_pattern "VSS" -ground

global_connect

#VOLTAGE DOMAIN
set_voltage_domain -name Core -power VDD -ground VSS
define_pdn_grid -name Core -voltage_domain Core 

#ADD STRIPES
if {$pdk_name eq "freepdk45"} {
    add_pdn_stripe -layer metal10 -width $PDN_VWIDTH -offset 16  -pitch $PDN_VPITCH -spacing $PDN_VSPACING  -grid Core
    add_pdn_stripe -layer metal9 -width $PDN_HWIDTH -offset 12  -pitch $PDN_HPITCH -spacing $PDN_HSPACING  -grid Core
    add_pdn_stripe -layer metal8 -width $PDN_VWIDTH -offset 12  -pitch $PDN_VPITCH -spacing $PDN_VSPACING  -grid Core
    add_pdn_stripe -layer metal7 -width $PDN_HWIDTH -offset 8  -pitch $PDN_HPITCH -spacing $PDN_HSPACING  -grid Core
    add_pdn_stripe -layer metal6 -width $PDN_VWIDTH -offset 8  -pitch $PDN_VPITCH -spacing $PDN_VSPACING  -grid Core
    add_pdn_stripe -layer metal5 -width $PDN_HWIDTH -offset 2  -pitch $PDN_HPITCH -spacing $PDN_HSPACING  -grid Core
    add_pdn_stripe -layer metal4 -width $PDN_VWIDTH -offset 2  -pitch $PDN_VPITCH -spacing $PDN_VSPACING  -grid Core
    add_pdn_stripe -layer metal1 -width 0.17 -grid Core -followpins

    add_pdn_connect -layers {metal1 metal4} -grid Core
    add_pdn_connect -layers {metal4 metal5} -grid Core
    add_pdn_connect -layers {metal5 metal6} -grid Core
    add_pdn_connect -layers {metal6 metal7} -grid Core
    add_pdn_connect -layers {metal7 metal8} -grid Core
    add_pdn_connect -layers {metal8 metal9} -grid Core
    add_pdn_connect -layers {metal9 metal10} -grid Core
}

#GENERATE POWER-GROUND GRID
pdngen

##ADD PINS
place_pins -hor_layers $pins_hor_layers -ver_layers $pins_ver_layers -min_distance_in_tracks -min_distance 4

##WRITE OUT DATA AT FP
exec mkdir -p ${folder_name}/floorplan/def/
exec mkdir -p ${folder_name}/floorplan/netlist/
exec mkdir -p ${folder_name}/floorplan/sdc/
exec mkdir -p ${folder_name}/floorplan/sdf/

write_def ${folder_name}/floorplan/def/def.def
write_verilog -remove_cells [concat $filler_cells $tap_cell] ${folder_name}/floorplan/netlist/netlist.v
write_sdc ${folder_name}/floorplan/sdc/sdc.sdc
write_sdf -digits 3 -corner view ${folder_name}/floorplan/sdf/sdf.sdf

##END TIME
set end_time [exec date +%s]
set create_floorplan_time [expr $end_time - $start_time]