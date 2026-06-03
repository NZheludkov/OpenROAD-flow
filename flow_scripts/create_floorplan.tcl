##START TIME
set start_time [exec date +%s]

##STAGE
set flow_stage create_floorplan

##CREATE FP
initialize_floorplan -utilization $CU -core_space 1 -aspect_ratio $AR -site $core_site

##INIT ROWS (ADD ENDCAP and TRACKS)  
tapcell \
-distance $tap_cell_distance \
-tapcell_master $tap_cell \
-endcap_master $endcap_cell

##CREATE LAYER TRACKS

if {$pdk_name eq "freepdk45"} {
    make_tracks -x_offset 0.07 -x_pitch 0.07 -y_offset 0.07 -y_pitch 0.07 metal1
    make_tracks -x_offset 0.14 -x_pitch 0.14 -y_offset 0.14 -y_pitch 0.14 metal2
    make_tracks -x_offset 0.14 -x_pitch 0.14 -y_offset 0.14 -y_pitch 0.14 metal3
    make_tracks -x_offset 0.28 -x_pitch 0.28 -y_offset 0.28 -y_pitch 0.28 metal4
    make_tracks -x_offset 0.28 -x_pitch 0.28 -y_offset 0.28 -y_pitch 0.28 metal5
    make_tracks -x_offset 0.28 -x_pitch 0.28 -y_offset 0.28 -y_pitch 0.28 metal6
    make_tracks -x_offset 0.80 -x_pitch 0.80 -y_offset 0.80 -y_pitch 0.80 metal7
}

if {$pdk_name eq "asap7"} {
    make_tracks Pad -x_offset 0.116 -x_pitch 0.08 -y_offset 0.116 -y_pitch 0.08
    make_tracks M9 -x_offset 0.116 -x_pitch 0.08 -y_offset 0.116 -y_pitch 0.08
    make_tracks M8 -x_offset 0.116 -x_pitch 0.08 -y_offset 0.116 -y_pitch 0.08
    make_tracks M7 -x_offset 0.016 -x_pitch 0.064 -y_offset 0.016 -y_pitch 0.064
    make_tracks M6 -x_offset 0.012 -x_pitch 0.048 -y_offset 0.016 -y_pitch 0.064
    make_tracks M5 -x_offset 0.012 -x_pitch 0.048 -y_offset 0.012 -y_pitch 0.048
    make_tracks M4 -x_offset 0.009 -x_pitch 0.036 -y_offset 0.012 -y_pitch 0.048
    make_tracks M3 -x_offset 0.009 -x_pitch 0.036 -y_offset 0.009 -y_pitch 0.036

    make_tracks M2 -x_offset 0.009 -x_pitch 0.036 -y_offset 0.045 -y_pitch 0.270
    make_tracks M2 -x_offset 0.009 -x_pitch 0.036 -y_offset 0.081 -y_pitch 0.270
    make_tracks M2 -x_offset 0.009 -x_pitch 0.036 -y_offset 0.117 -y_pitch 0.270
    make_tracks M2 -x_offset 0.009 -x_pitch 0.036 -y_offset 0.153 -y_pitch 0.270
    make_tracks M2 -x_offset 0.009 -x_pitch 0.036 -y_offset 0.189 -y_pitch 0.270
    make_tracks M2 -x_offset 0.009 -x_pitch 0.036 -y_offset 0.225 -y_pitch 0.270
    make_tracks M2 -x_offset 0.009 -x_pitch 0.036 -y_offset 0.270 -y_pitch 0.270

    make_tracks M1 -x_offset 0.009 -x_pitch 0.036 -y_offset 0.009 -y_pitch 0.036
}

if {$pdk_name eq "sky130"} {
    make_tracks -x_offset 0.10 -x_pitch 0.10 -y_offset 0.10 -y_pitch 0.10 li1
    make_tracks -x_offset 0.35 -x_pitch 0.35 -y_offset 0.35 -y_pitch 0.35 met1
    make_tracks -x_offset 0.35 -x_pitch 0.35 -y_offset 0.35 -y_pitch 0.35 met2
    make_tracks -x_offset 0.80 -x_pitch 0.80 -y_offset 0.80 -y_pitch 0.80 met3
    make_tracks -x_offset 0.80 -x_pitch 0.80 -y_offset 0.80 -y_pitch 0.80 met4
    make_tracks -x_offset 1.20 -x_pitch 1.20 -y_offset 1.20 -y_pitch 1.20 met5
}

if {$pdk_name eq "gf180"} {
    make_tracks -x_offset 0.54 -x_pitch 0.54 -y_offset 0.54 -y_pitch 0.54 Metal1
    make_tracks -x_offset 0.54 -x_pitch 0.54 -y_offset 0.54 -y_pitch 0.54 Metal2
    make_tracks -x_offset 0.54 -x_pitch 0.54 -y_offset 0.54 -y_pitch 0.54 Metal3
    make_tracks -x_offset 0.54 -x_pitch 0.54 -y_offset 0.54 -y_pitch 0.54 Metal4
    make_tracks -x_offset 0.54 -x_pitch 0.54 -y_offset 0.54 -y_pitch 0.54 Metal5
    make_tracks -x_offset 0.99 -x_pitch 0.99 -y_offset 0.99 -y_pitch 0.99 MetalTop
}

##CREATE POWER GROUND GRID
pdngen -reset

#ADD STRIPES
if {$pdk_name eq "freepdk45"} {

    #GLOBAL NET CONNECT
    add_global_connection -net VDD -pin_pattern "VDD" -power
    add_global_connection -net VSS -pin_pattern "VSS" -ground

    global_connect

    #VOLTAGE DOMAIN
    set_voltage_domain -name Core -power VDD -ground VSS
    define_pdn_grid -name Core -voltage_domain Core

    add_pdn_stripe -layer metal1 -width 0.17 -grid Core -followpins
    add_pdn_stripe -layer metal4 -width [expr 0.28 * $PDN_VWIDTH_TRACK] -offset [expr 0.28 * 1] -pitch [expr 0.28 * $PDN_VPITCH_TRACK] -spacing [expr 0.28 * $PDN_VSPACING_TRACK]  -grid Core -snap_to_grid
    add_pdn_stripe -layer metal5 -width [expr 0.28 * $PDN_HWIDTH_TRACK] -offset [expr 0.28 * 1] -pitch [expr 0.28 * $PDN_HPITCH_TRACK] -spacing [expr 0.28 * $PDN_HSPACING_TRACK]  -grid Core -snap_to_grid
    add_pdn_stripe -layer metal6 -width [expr 0.28 * $PDN_VWIDTH_TRACK] -offset [expr 0.28 * 16] -pitch [expr 0.28 * $PDN_VPITCH_TRACK] -spacing [expr 0.28 * $PDN_VSPACING_TRACK]  -grid Core -snap_to_grid
    add_pdn_stripe -layer metal7 -width [expr 0.80 * $PDN_HWIDTH_TRACK] -offset [expr 0.80 * 1] -pitch [expr 0.80 * $PDN_HPITCH_TRACK] -spacing [expr 0.80 * $PDN_HSPACING_TRACK]  -grid Core -snap_to_grid

    add_pdn_connect -layers {metal1 metal4} -grid Core
    add_pdn_connect -layers {metal4 metal5} -grid Core
    add_pdn_connect -layers {metal5 metal6} -grid Core
    add_pdn_connect -layers {metal6 metal7} -grid Core
}

if {$pdk_name eq "gf180"} {

    #GLOBAL NET CONNECT
    add_global_connection -net VDD -pin_pattern "VDD" -power
    add_global_connection -net VSS -pin_pattern "VSS" -ground

    global_connect

    #VOLTAGE DOMAIN
    set_voltage_domain -name Core -power VDD -ground VSS
    define_pdn_grid -name Core -voltage_domain Core

    add_pdn_stripe -layer Metal1 -width 0.9 -grid Core -followpins
    add_pdn_stripe -layer Metal4 -width [expr 0.54 * $PDN_VWIDTH_TRACK] -offset [expr 0.54 * 1] -pitch [expr 0.54 * $PDN_VPITCH_TRACK] -spacing [expr 0.54 * $PDN_VSPACING_TRACK]  -grid Core -snap_to_grid
    add_pdn_stripe -layer Metal5 -width [expr 0.54 * $PDN_HWIDTH_TRACK] -offset [expr 0.54 * 1] -pitch [expr 0.54 * $PDN_HPITCH_TRACK] -spacing [expr 0.54 * $PDN_HSPACING_TRACK]  -grid Core -snap_to_grid
    add_pdn_stripe -layer MetalTop -width [expr 0.99 * $PDN_VWIDTH_TRACK] -offset [expr 0.99 * 16] -pitch [expr 0.99 * $PDN_VPITCH_TRACK] -spacing [expr 0.99 * $PDN_VSPACING_TRACK]  -grid Core -snap_to_grid

    add_pdn_connect -layers {Metal1 Metal4} -grid Core
    add_pdn_connect -layers {Metal4 Metal5} -grid Core
    add_pdn_connect -layers {Metal5 MetalTop} -grid Core
}

if {$pdk_name eq "asap7"} {

    #GLOBAL NET CONNECT
    add_global_connection -net VDD -pin_pattern "VDD" -power
    add_global_connection -net VSS -pin_pattern "VSS" -ground

    global_connect

    ####################################
    # voltage domains
    ####################################
    set_voltage_domain -name CORE -power {VDD} -ground {VSS}
    ####################################
    # standard cell grid
    ####################################
    define_pdn_grid -name {stdcells} -voltage_domains CORE -pins {M7}
    add_pdn_stripe -grid {stdcells} -layer {M1} -width {0.018} -pitch {0.54} -offset {0} -followpins
    add_pdn_stripe -grid {stdcells} -layer {M2} -width {0.018} -pitch {0.54} -offset {0} -followpins
    add_pdn_stripe -grid {stdcells} -layer {M5} -width {0.12} -spacing {0.072} -pitch {5.904} \
        -offset {0.300} -snap_to_grid
    add_pdn_stripe -grid {stdcells} -layer {M6} -width {0.288} -spacing {0.096} -pitch {6.0} \
        -offset {0.513} -snap_to_grid

    set M7_pitch [expr {([lindex [ord::get_core_area] 2] - [lindex [ord::get_core_area] 0]) / 2}]
    if {$M7_pitch > 10.0} {
        set M7_pitch 10.0
    }

    proc snap_grid {value} {
        set grid [[ord::get_db_tech] getManufacturingGrid]
        set dbus [[ord::get_db_tech] getDbUnitsPerMicron]

        set val_dbus [ord::microns_to_dbu $value]
        set val_snapped [expr {$grid * round($val_dbus / $grid)}]

        return [ord::dbu_to_microns $val_snapped]
    }

    add_pdn_stripe -grid {stdcells} -layer {M7} -width {0.288} -pitch [snap_grid $M7_pitch] \
        -offset [snap_grid [expr {$M7_pitch / 4}]] -snap_to_grid

    add_pdn_connect -grid {stdcells} -layers {M1 M2}
    add_pdn_connect -grid {stdcells} -layers {M2 M5}
    add_pdn_connect -grid {stdcells} -layers {M5 M6}
    add_pdn_connect -grid {stdcells} -layers {M6 M7}

    utl::warn FLW 1 "Relaxed technology routing rules loaded for ASAP7,\
        this should only be used for trial routing"

    utl::info FLW 1 "Removing right way on grid only rules"
    [[ord::get_db_tech] findLayer M1] setRightWayOnGridOnly 0
    [[ord::get_db_tech] findLayer M2] setRightWayOnGridOnly 0
    [[ord::get_db_tech] findLayer M3] setRightWayOnGridOnly 0
    [[ord::get_db_tech] findLayer M4] setRightWayOnGridOnly 0
    [[ord::get_db_tech] findLayer M5] setRightWayOnGridOnly 0
    [[ord::get_db_tech] findLayer M6] setRightWayOnGridOnly 0
    [[ord::get_db_tech] findLayer M7] setRightWayOnGridOnly 0
  
}

if {$pdk_name eq "sky130"} {

    #GLOBAL NET CONNECT
    add_global_connection -net VDD -pin_pattern "VPWR" -power
    add_global_connection -net VSS -pin_pattern "VGND" -ground

    global_connect

    #VOLTAGE DOMAIN
    set_voltage_domain -name Core -power VDD -ground VSS
    define_pdn_grid -name Core -voltage_domain Core

    add_pdn_stripe -layer met1 -width 0.48 -grid Core -followpins
    add_pdn_stripe -layer met4 -width [expr 0.80 * $PDN_VWIDTH_TRACK] -offset [expr 0.80 * 1] -pitch [expr 0.80 * $PDN_VPITCH_TRACK] -spacing [expr 0.80 * $PDN_VSPACING_TRACK]  -grid Core -snap_to_grid
    add_pdn_stripe -layer met5 -width [expr 1.20 * $PDN_HWIDTH_TRACK] -offset [expr 1.20 * 1] -pitch [expr 1.20 * $PDN_HPITCH_TRACK] -spacing [expr 1.20 * $PDN_HSPACING_TRACK]  -grid Core -snap_to_grid

    add_pdn_connect -layers {met1 met4} -grid Core
    add_pdn_connect -layers {met4 met5} -grid Core
}

#GENERATE POWER-GROUND GRID
pdngen

##ADD PINS
place_pins -hor_layers $pins_hor_layers -ver_layers $pins_ver_layers -min_distance_in_tracks -min_distance 4

##REPORT METRICS
source ./flow_scripts/report_metric.tcl

##END TIME
set end_time [exec date +%s]
set create_floorplan_time [expr $end_time - $start_time]