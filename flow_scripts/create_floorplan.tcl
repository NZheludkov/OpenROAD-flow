##START TIME
set start_time [exec date +%s]

##CREATE FP
initialize_floorplan -utilization $CU -core_space 3 -aspect_ratio $AR -site FreePDK45_38x28_10R_NP_162NW_34O

##INIT ROWS (ADD ENDCAP and TRACKS)  
tapcell \
    -distance 120 \
    -tapcell_master "TAPCELL_X1" \
    -endcap_master "TAPCELL_X1"


##CREATE LAYER TRACKS
make_tracks

##CREATE POWER GROUND GRID
pdngen -reset

add_global_connection -net VDD -pin_pattern "VDD" -power
add_global_connection -net VSS -pin_pattern "VSS" -ground

global_connect

set_voltage_domain -name Core -power VDD -ground VSS
define_pdn_grid -name Core -voltage_domain Core 

add_pdn_stripe -layer metal10 -width $PDN_VWIDTH -offset 8  -pitch $PDN_VPITCH -spacing $PDN_VSPACING  -grid Core
add_pdn_stripe -layer metal9 -width $PDN_HWIDTH -offset 6  -pitch $PDN_HPITCH -spacing $PDN_HSPACING  -grid Core
add_pdn_stripe -layer metal8 -width $PDN_VWIDTH -offset 6  -pitch $PDN_VPITCH -spacing $PDN_VSPACING  -grid Core
add_pdn_stripe -layer metal7 -width $PDN_HWIDTH -offset 4  -pitch $PDN_HPITCH -spacing $PDN_HSPACING  -grid Core
add_pdn_stripe -layer metal6 -width $PDN_VWIDTH -offset 4  -pitch $PDN_VPITCH -spacing $PDN_VSPACING  -grid Core
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

pdngen

##ADD PINS
place_pins -hor_layers {metal3 metal5} -ver_layers {metal2 metal4} -min_distance_in_tracks -min_distance 4

##END TIME
set end_time [exec date +%s]
set create_floorplan_time [expr $end_time - $start_time]