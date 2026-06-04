##START TIME
set start_time [exec date +%s]

##STAGE
set flow_stage route

##CREATE FOLDER FOR STAGE REPORTS
exec mkdir -p $run_dir/route/

##ROUTE SETTINGS
set_routing_layers -signal $bottom_routing_metal-$top_routing_metal -clock $bottom_routing_metal-$top_routing_metal

#GLOBAL ROUTE
exec mkdir -p $run_dir/route/groute_guide/
global_route -allow_congestion -verbose -guide_file $run_dir/route/groute_guide/groute.guide

##EVAL SPEF
estimate_parasitics -global_routing

##FIX SLEW,FANOUT,CAP (DRV)
repair_design -verbose

##FIX SETUP 1
repair_timing -setup -verbose -repair_tns 100

##FIX HOLD 1
repair_timing -hold -allow_setup_violations -verbose

##FIX SETUP 2
repair_timing -setup -verbose -repair_tns 100

##FIX HOLD 2
repair_timing -hold -allow_setup_violations -verbose

##DETAIL PLACEMENT AFTER ADDING CTS BUFS
detailed_placement

##OPTIMIZE PLACE BY MIRRORING CELL
optimize_mirroring

##ADD FILLER
filler_placement -prefix FILLER $filler_cells

#GLOBAL ROUTE
global_route -allow_congestion -verbose -guide_file $run_dir/route/groute_guide/groute.guide

##DETAIL ROUTE
exec mkdir -p $run_dir/route/drc_report/
detailed_route \
-droute_end_iter "10" \
-verbose "10" \
-output_drc $run_dir/route/drc_report/drc_report.txt \
-db_process_node $process_node

##RC EXTRACTION
define_process_corner -ext_model_index 0 X
extract_parasitics -ext_model_file $rc_extract_file \
-cc_model 12 -max_res 0 -context_depth 10 \
-coupling_threshold 0.1

##WRITE AND READ SPEF
exec mkdir -p $run_dir/route/spef/
exec mkdir -p $run_dir/route/parasitic_annotation/

write_spef $run_dir/route/spef/spef.spef
read_spef $run_dir/route/spef/spef.spef -corner view -max

report_parasitic_annotation -report_unannotated > $run_dir/route/parasitic_annotation/parasitic_annotation.txt

##REPORT TIMING AFTER DROUTE
exec mkdir -p $run_dir/route/timing_reports/
report_checks -corner view -digits 3 -path_delay max -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group in2reg  > $run_dir/route/timing_reports/in2reg_setup.txt
report_checks -corner view -digits 3 -path_delay max -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group reg2reg > $run_dir/route/timing_reports/reg2reg_setup.txt
report_checks -corner view -digits 3 -path_delay max -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group reg2out > $run_dir/route/timing_reports/reg2out_setup.txt
report_checks -corner view -digits 3 -path_delay max -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group in2out  > $run_dir/route/timing_reports/in2out_setup.txt

report_checks -corner view -digits 3 -path_delay min -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group in2reg  > $run_dir/route/timing_reports/in2reg_hold.txt
report_checks -corner view -digits 3 -path_delay min -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group reg2reg > $run_dir/route/timing_reports/reg2reg_hold.txt
report_checks -corner view -digits 3 -path_delay min -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group reg2out > $run_dir/route/timing_reports/reg2out_hold.txt
report_checks -corner view -digits 3 -path_delay min -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group in2out  > $run_dir/route/timing_reports/in2out_hold.txt

##WRITE FINAL WNS
with_output_to_variable a {report_checks -path_group reg2reg -digits 3 -format slack_only -no_line_splits}
set wns [lindex $a 4]

##WRITE FINAL TOTAL POWER
with_output_to_variable a {report_power -digits 3}
set total_power [lindex $a 43]

##DESIGN AREA
with_output_to_variable a {report_design_area}
set design_area [lindex $a 2]

##REPORT METRICS
source ./flow_scripts/report_metric.tcl

##END TIME
set end_time [exec date +%s]
set route_time [expr $end_time - $start_time]

##WRITE TIME
exec mkdir -p $run_dir/runtime/
set file [open $run_dir/runtime/runtime.csv "w"]

puts $file "init_design;create_floorplan;prects;cts;postcts;route"
puts $file "${init_design_time};${create_floorplan_time};${prects_time};${cts_time};${postcts_time};${route_time}"

close $file

##WRITE RUN META INFO
set file [open $run_dir/run_info.csv "w"]

puts $file "design;pdk_name;CLK_PERIOD;IO_DELAY;CU;AR;PDN_HWIDTH_TRACK;PDN_HSPACING_TRACK;PDN_HPITCH_TRACK;PDN_VWIDTH_TRACK;PDN_VSPACING_TRACK;PDN_VPITCH_TRACK;cells_number;nets_number;regs_number;yosys_time;init_design_time;create_floorplan_time;prects_time;cts_time;postcts_time;route_time;wns;total_power;design_area"
puts $file "$design;$pdk_name;$CLK_PERIOD;$IO_DELAY;$CU;$AR;$PDN_HWIDTH_TRACK;$PDN_HSPACING_TRACK;$PDN_HPITCH_TRACK;$PDN_VWIDTH_TRACK;$PDN_VSPACING_TRACK;$PDN_VPITCH_TRACK;$cells_number;$nets_number;$regs_number;${yosys_time};${init_design_time};${create_floorplan_time};${prects_time};${cts_time};${postcts_time};${route_time};$wns;$total_power;$design_area"

close $file
