#def netlist sds sdf
exec mkdir -p ${run_dir}/${flow_stage}/def/
exec mkdir -p ${run_dir}/${flow_stage}/netlist/
exec mkdir -p ${run_dir}/${flow_stage}/sdc/
exec mkdir -p ${run_dir}/${flow_stage}/sdf/
exec mkdir -p ${run_dir}/${flow_stage}/metrics/

#spef if stage eq route
if {$flow_stage eq "route"} {
	exec mkdir -p $run_dir/route/spef/
	write_spef $run_dir/route/spef/spef.spef
}

write_def ${run_dir}/${flow_stage}/def/def.def
write_verilog -remove_cells [concat $filler_cells $tap_cell $endcap_cell] ${run_dir}/${flow_stage}/netlist/netlist.v
write_sdc ${run_dir}/${flow_stage}/sdc/sdc.sdc
write_sdf -digits 3 -corner view ${run_dir}/${flow_stage}/sdf/sdf.sdf

#create metric file
set metric_file ${run_dir}/${flow_stage}/metrics/metrics.txt
set filename $metric_file
set fileId [open $filename w]
close $fileId

#wns
report_puts "\n=========================================================================="
report_puts "wns"
report_puts "==========================================================================\n"
report_wns -digits 3 >> $metric_file

#tns
report_puts "\n=========================================================================="
report_puts "tns"
report_puts "==========================================================================\n"
report_tns -digits 3 >> $metric_file

#power
report_puts "\n=========================================================================="
report_puts "power"
report_puts "==========================================================================\n"
report_power -digits 3  >> $metric_file

#design area
report_puts "\n=========================================================================="
report_puts "design area"
report_puts "==========================================================================\n"
report_design_area  >> $metric_file

#max tran
report_puts "\n=========================================================================="
report_puts "max transition"
report_puts "==========================================================================\n"
report_check_types -digits 3 -max_slew  >> $metric_file

#max fanout
report_puts "\n=========================================================================="
report_puts "max fanout"
report_puts "==========================================================================\n"
report_check_types -digits 3 -max_fanout >> $metric_file

#max cap
report_puts "\n=========================================================================="
report_puts "max max_capacitance"
report_puts "==========================================================================\n"
report_check_types -digits 3 -max_capacitance >> $metric_file

#max delay
report_puts "\n=========================================================================="
report_puts "max delay"
report_puts "==========================================================================\n"
report_check_types -max_delay -digits 3 >> $metric_file

#min delay
report_puts "\n=========================================================================="
report_puts "min delay"
report_puts "==========================================================================\n"
report_check_types -min_delay -digits 3 >> $metric_file

#min pulse width
report_puts "\n=========================================================================="
report_puts "min pulse width"
report_puts "==========================================================================\n"
report_check_types -min_pulse_width -digits 3 >> $metric_file

#min period
report_puts "\n=========================================================================="
report_puts "min period"
report_puts "==========================================================================\n"
report_check_types -min_period -digits 3 >> $metric_file

#removal check
report_puts "\n=========================================================================="
report_puts "removal check"
report_puts "==========================================================================\n"
report_check_types -removal -digits 3 >> $metric_file

#recovery check
report_puts "\n=========================================================================="
report_puts "recovery check"
report_puts "==========================================================================\n"
report_check_types -recovery -digits 3 >> $metric_file

#skew
report_puts "\n=========================================================================="
report_puts "skew"
report_puts "==========================================================================\n"
report_clock_skew -digits 3 >> $metric_file