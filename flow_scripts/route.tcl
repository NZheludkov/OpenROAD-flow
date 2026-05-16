##START TIME
set start_time [exec date +%s]

##CREATE FOLDER FOR STAGE REPORTS
exec mkdir -p $folder_name/route/

##ROUTE SETTINGS
set_routing_layers -signal $bottom_routing_metal-$top_routing_metal -clock $bottom_routing_metal-$top_routing_metal

#GLOBAL ROUTE
exec mkdir -p $folder_name/route/groute_guide/
global_route -allow_congestion -verbose -guide_file $folder_name/route/groute_guide/groute.guide

##EVAL SPEF
estimate_parasitics -global_routing

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
filler_placement -prefix FILLER $filler_cells

#GLOBAL ROUTE
global_route -allow_congestion -verbose -guide_file $folder_name/route/groute_guide/groute.guide

##DETAIL ROUTE
exec mkdir -p $folder_name/route/drc_report/
detailed_route \
-droute_end_iter "5" \
-verbose "10" \
-output_drc $folder_name/route/drc_report/drc_report.txt \
-db_process_node $process_node

##RC EXTRACTION
define_process_corner -ext_model_index 0 X
extract_parasitics -ext_model_file "${pdk_path}/base/pex/openroad/typical.rules" \
-cc_model 12 -max_res 0 -context_depth 10 \
-coupling_threshold 0.1

##WRITE AND READ SPEF
exec mkdir -p $folder_name/route/spef/
exec mkdir -p $folder_name/route/parasitic_annotation/

write_spef $folder_name/route/spef/spef.spef
read_spef $folder_name/route/spef/spef.spef -corner view -max

report_parasitic_annotation -report_unannotated > $folder_name/route/parasitic_annotation/parasitic_annotation.txt

##REPORT TIMING AFTER DROUTE
exec mkdir -p $folder_name/route/timing_reports/
report_checks -corner view -digits 3 -path_delay max -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group in2reg  > $folder_name/route/timing_reports/in2reg_setup.txt
report_checks -corner view -digits 3 -path_delay max -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group reg2reg > $folder_name/route/timing_reports/reg2reg_setup.txt
report_checks -corner view -digits 3 -path_delay max -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group reg2out > $folder_name/route/timing_reports/reg2out_setup.txt
report_checks -corner view -digits 3 -path_delay max -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group in2out  > $folder_name/route/timing_reports/in2out_setup.txt

report_checks -corner view -digits 3 -path_delay min -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group in2reg  > $folder_name/route/timing_reports/in2reg_hold.txt
report_checks -corner view -digits 3 -path_delay min -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group reg2reg > $folder_name/route/timing_reports/reg2reg_hold.txt
report_checks -corner view -digits 3 -path_delay min -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group reg2out > $folder_name/route/timing_reports/reg2out_hold.txt
report_checks -corner view -digits 3 -path_delay min -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group in2out  > $folder_name/route/timing_reports/in2out_hold.txt

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
write_verilog -remove_cells [concat $filler_cells $tap_cell] $folder_name/route/netlist/netlist.v
write_sdc $folder_name/route/sdc/sdc.sdc
write_spef $folder_name/route/spef/spef.spef
write_sdf -digits 3 -corner view $folder_name/route/sdf/sdf.sdf

##END TIME
set end_time [exec date +%s]
set route_time [expr $end_time - $start_time]