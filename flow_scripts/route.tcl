##START TIME
set start_time [exec date +%s]

##ROUTE SETTINGS
set_routing_layers -signal metal1-metal10 -clock metal1-metal10
 
#GLOBAL ROUTE
global_route -allow_congestion -verbose -guide_file $folder_name/groute.guide

##FIX SLEW,FANOUT,CAP (DRV)
repair_design -verbose

##FIX SETUP 1
repair_timing -setup -verbose -repair_tns 100

##FIX HOLD 1
repair_timing -hold -allow_setup_violations

##FIX SETUP 2
repair_timing -setup -verbose -repair_tns 100

##FIX HOLD 2
repair_timing -hold -allow_setup_violations

##DETAIL PLACEMENT AFTER ADDING CTS BUFS
detailed_placement

##OPTIMIZE PLACE BY MIRRORING CELL
optimize_mirroring

##ADD FILLER
filler_placement -prefix FILLER "\
FILLCELL_X1
FILLCELL_X2
FILLCELL_X4
FILLCELL_X8
FILLCELL_X16 
FILLCELL_X32"

#GLOBAL ROUTE
global_route -allow_congestion -verbose -guide_file $folder_name/groute.guide

##DETAIL ROUTE
detailed_route \
-droute_end_iter "5" \
-verbose "10" \
-output_drc $folder_name/drc_report.txt \
-db_process_node "45"

##EVAL SPEF
estimate_parasitics -global_routing

##REPORT TIMING AFTER DROUTE
exec mkdir -p $folder_name/timing_reports/route/
report_checks -corner view -digits 3 -path_delay max -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group in2reg  > $folder_name/timing_reports/route/in2reg_setup.txt
report_checks -corner view -digits 3 -path_delay max -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group reg2reg > $folder_name/timing_reports/route/reg2reg_setup.txt
report_checks -corner view -digits 3 -path_delay max -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group reg2out > $folder_name/timing_reports/route/reg2out_setup.txt
report_checks -corner view -digits 3 -path_delay max -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group in2out  > $folder_name/timing_reports/route/in2out_setup.txt

report_checks -corner view -digits 3 -path_delay min -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group in2reg  > $folder_name/timing_reports/route/in2reg_hold.txt
report_checks -corner view -digits 3 -path_delay min -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group reg2reg > $folder_name/timing_reports/route/reg2reg_hold.txt
report_checks -corner view -digits 3 -path_delay min -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group reg2out > $folder_name/timing_reports/route/reg2out_hold.txt
report_checks -corner view -digits 3 -path_delay min -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group in2out  > $folder_name/timing_reports/route/in2out_hold.txt

##RC EXTRACTION
define_process_corner -ext_model_index 0 X
extract_parasitics -ext_model_file "${pdk_path}/base/pex/openroad/typical.rules" \
-cc_model 12 -max_res 0 -context_depth 10 \
-coupling_threshold 0.1

##WRITE AND READ SPEF
write_spef $folder_name/spef.spef
read_spef $folder_name/spef.spef -corner view -max

##REPORT TIMING AFTER DROUTE
exec mkdir -p $folder_name/timing_reports/route_spef/
report_checks -corner view -digits 3 -path_delay max -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group in2reg  > $folder_name/timing_reports/route_spef/in2reg_setup.txt
report_checks -corner view -digits 3 -path_delay max -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group reg2reg > $folder_name/timing_reports/route_spef/reg2reg_setup.txt
report_checks -corner view -digits 3 -path_delay max -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group reg2out > $folder_name/timing_reports/route_spef/reg2out_setup.txt
report_checks -corner view -digits 3 -path_delay max -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group in2out  > $folder_name/timing_reports/route_spef/in2out_setup.txt

report_checks -corner view -digits 3 -path_delay min -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group in2reg  > $folder_name/timing_reports/route_spef/in2reg_hold.txt
report_checks -corner view -digits 3 -path_delay min -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group reg2reg > $folder_name/timing_reports/route_spef/reg2reg_hold.txt
report_checks -corner view -digits 3 -path_delay min -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group reg2out > $folder_name/timing_reports/route_spef/reg2out_hold.txt
report_checks -corner view -digits 3 -path_delay min -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group in2out  > $folder_name/timing_reports/route_spef/in2out_hold.txt

##WRITE WNS
with_output_to_variable a {report_checks -path_group reg2reg -digits 3 -format slack_only -no_line_splits}
set wns [lindex $a 4]

##WRITE ROUTE DATA
exec mkdir -p $folder_name/route/def/
exec mkdir -p $folder_name/route/netlist/
exec mkdir -p $folder_name/route/sdc/
exec mkdir -p $folder_name/route/spef/
exec mkdir -p $folder_name/route/sdf/

write_def $folder_name/route/def/def.def
write_verilog -remove_cells "*FILL* *TAPCELL_X1*" $folder_name/route/netlist/netlist.v
write_sdc $folder_name/route/sdc/sdc.sdc
write_spef $folder_name/route/spef/spef.spef
write_sdf -digits 3 -corner view $folder_name/route/sdf/sdf.sdf

##END TIME
set end_time [exec date +%s]
set route_time [expr $end_time - $start_time]