##START TIME
set start_time [exec date +%s]

##PROPAGATE ALL CLOCKS
set_propagated_clock [all_clocks]

##MAX SLEW AND MAX CAP FOR CTS
set max_slew [expr $max_slew_cts * 1e-9]; # must convert to seconds
set max_cap  [expr $max_cap_cts * 1e-12]; # must convert to farad

##EVAL SPEF
estimate_parasitics -placement

#Clone clock tree inverters next to register loads
#so cts does not try to buffer the inverted clocks.
repair_clock_inverters

##CTS CONFIG
configure_cts_characterization\
    -max_slew $max_slew\
    -max_cap $max_cap

#DISABLE NDR FOR BETTER ROUTING
set_cts_config -apply_ndr $ndr_type

##CTS
clock_tree_synthesis \
    -buf_list $cts_buf_list \
    -root_buf $cts_root_buf \
    -apply_ndr $ndr_type \
    -repair_clock_nets

##DETAIL PLACEMENT AFTER ADDING CTS BUFS
detailed_placement

##OPTIMIZE PLACE BY MIRRORING CELL
optimize_mirroring

##EVAL SPEF
estimate_parasitics -placement

##CTS REPORT
exec mkdir -p $folder_name/cts/report_cts/
exec mkdir -p $folder_name/cts/report_skew/

report_cts -out_file $folder_name/cts/report_cts/cts_report.txt
report_clock_skew -digits 3 > $folder_name/cts/report_skew/report_skew.txt

##REPORT TIMING AFTER CTS
exec mkdir -p $folder_name/cts/timing_reports/
report_checks -corner view -digits 3 -path_delay max -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group in2reg  > $folder_name/cts/timing_reports/in2reg_setup.txt
report_checks -corner view -digits 3 -path_delay max -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group reg2reg > $folder_name/cts/timing_reports/reg2reg_setup.txt
report_checks -corner view -digits 3 -path_delay max -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group reg2out > $folder_name/cts/timing_reports/reg2out_setup.txt
report_checks -corner view -digits 3 -path_delay max -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group in2out  > $folder_name/cts/timing_reports/in2out_setup.txt

report_checks -corner view -digits 3 -path_delay min -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group in2reg  > $folder_name/cts/timing_reports/in2reg_hold.txt
report_checks -corner view -digits 3 -path_delay min -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group reg2reg > $folder_name/cts/timing_reports/reg2reg_hold.txt
report_checks -corner view -digits 3 -path_delay min -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group reg2out > $folder_name/cts/timing_reports/reg2out_hold.txt
report_checks -corner view -digits 3 -path_delay min -format full_clock_expanded -no_line_splits -fields {slew net cap fanout} -path_group in2out  > $folder_name/cts/timing_reports/in2out_hold.txt

##WRITE CTS DATA
exec mkdir -p $folder_name/cts/def/
exec mkdir -p $folder_name/cts/netlist/
exec mkdir -p $folder_name/cts/sdc/
exec mkdir -p $folder_name/cts/sdf/

write_def $folder_name/cts/def/def.def
write_verilog -remove_cells [concat $filler_cells $tap_cell $endcap_cell] $folder_name/cts/netlist/netlist.v
write_sdc $folder_name/cts/sdc/sdc.sdc
write_sdf -digits 3 -corner view $folder_name/cts/sdf/sdf.sdf

##END TIME
set end_time [exec date +%s]
set cts_time [expr $end_time - $start_time]