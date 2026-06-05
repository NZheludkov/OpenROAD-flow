##START TIME
set start_time [exec date +%s]

##STAGE
set flow_stage postcts

##POSTCTS (FIX DRV, SETUP, HOLD)
##FIX SLEW,FANOUT,CAP (DRV)
repair_design -verbose

##DETAIL PLACEMENT AFTER ADDING CTS BUFS
detailed_placement

##OPTIMIZE PLACE BY MIRRORING CELL
optimize_mirroring

##EVAL SPEF
estimate_parasitics -placement

##FIX SETUP 1
repair_timing -setup -verbose -repair_tns 100

##FIX HOLD 1
repair_timing -hold -allow_setup_violations -verbose 

##FIX SETUP 2
repair_timing -setup -verbose

##FIX HOLD 2
repair_timing -hold -allow_setup_violations -verbose 

##DETAIL PLACEMENT AFTER ADDING CTS BUFS
detailed_placement

##OPTIMIZE PLACE BY MIRRORING CELL
optimize_mirroring

##EVAL SPEF
estimate_parasitics -placement

##REPORT TIMING AFTER POSTCTS
exec mkdir -p $run_dir/postcts/timing_reports/
report_checks -corner view -digits 3 -path_delay max -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group in2reg  > $run_dir/postcts/timing_reports/in2reg_setup.txt
report_checks -corner view -digits 3 -path_delay max -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group reg2reg > $run_dir/postcts/timing_reports/reg2reg_setup.txt
report_checks -corner view -digits 3 -path_delay max -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group reg2out > $run_dir/postcts/timing_reports/reg2out_setup.txt
report_checks -corner view -digits 3 -path_delay max -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group in2out  > $run_dir/postcts/timing_reports/in2out_setup.txt

report_checks -corner view -digits 3 -path_delay min -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group in2reg  > $run_dir/postcts/timing_reports/in2reg_hold.txt
report_checks -corner view -digits 3 -path_delay min -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group reg2reg > $run_dir/postcts/timing_reports/reg2reg_hold.txt
report_checks -corner view -digits 3 -path_delay min -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group reg2out > $run_dir/postcts/timing_reports/reg2out_hold.txt
report_checks -corner view -digits 3 -path_delay min -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group in2out  > $run_dir/postcts/timing_reports/in2out_hold.txt

##REPORT METRICS
source ./flow_scripts/report_metric.tcl

##END TIME
set end_time [exec date +%s]
set postcts_time [expr $end_time - $start_time]