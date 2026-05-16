##START TIME
set start_time [exec date +%s]

##DONT USE LIST
foreach cell $dont_use_cells {
	set_dont_use $cell
}

##ROUTING LAYERS
set_routing_layers -signal $bottom_routing_metal-$top_routing_metal -clock $bottom_routing_metal-$top_routing_metal

##LAYER FOR RC ESTIMATION
set_wire_rc -clock -layer $wire_rc_metal
set_wire_rc -signal -layer $wire_rc_metal

# Liberty units are fF,kOhm
set_layer_rc -corner view -layer metal1 -resistance 5.4286e-03 -capacitance 7.41819E-02
set_layer_rc -corner view  -layer metal2 -resistance 3.5714e-03 -capacitance 6.74606E-02
set_layer_rc -corner view  -layer metal3 -resistance 3.5714e-03 -capacitance 8.88758E-02
set_layer_rc -corner view  -layer metal4 -resistance 1.5000e-03 -capacitance 1.07121E-01
set_layer_rc -corner view  -layer metal5 -resistance 1.5000e-03 -capacitance 1.08964E-01
set_layer_rc -corner view  -layer metal6 -resistance 1.5000e-03 -capacitance 1.02044E-01
set_layer_rc -corner view  -layer metal7 -resistance 1.8750e-04 -capacitance 1.10436E-01
set_layer_rc -corner view  -layer metal8 -resistance 1.8750e-04 -capacitance 9.69714E-02
# No calibration data available for metal9 and metal10
set_layer_rc -corner view  -layer metal9 -resistance 3.7500e-05 -capacitance 3.6864e-02
set_layer_rc -corner view  -layer metal10 -resistance 3.7500e-05 -capacitance 2.8042e-0

##SET ALL CLOCKS TO IDEL (NOT PROPAGATED)
unset_propagated_clock [all_clocks]

#REMOIVE INITAL BUFFERS FROM SYNT NETLIST
remove_buffers 

#GLOBAL PLACEMENT
global_placement \
-timing_driven \
-routability_driven \
-overflow "0.01" \
-density "0.5" \
-init_density_penalty "1e-2" \
-pad_left "4" \
-pad_right "4" \
-enable_routing_congestion \
-routability_use_grt

##ADD TIELO TIEHI
insert_tiecells -prefix TIE ${tiehi_cell}/${tiehi_cell_pin}
insert_tiecells -prefix TIE ${tielo_cell}/${tielo_cell_pin}

repair_tie_fanout -verbose ${tiehi_cell}/${tiehi_cell_pin}
repair_tie_fanout -verbose ${tielo_cell}/${tielo_cell_pin}

#DETAILED PLACEMENT
detailed_placement

#estimate_parasitics
estimate_parasitics -placement

#OPT DRV
repair_design -verbose

#OPT SETUP
repair_timing -setup -verbose

#DETAILED PLACEMENT
detailed_placement

#OPT MIRROR
optimize_mirroring

check_placement

##estimate_parasitics
estimate_parasitics -placement

##REPORT TIMING AFTER PRECTS
exec mkdir -p ${folder_name}/prects/timing_reports/
report_checks -corner view -digits 3 -path_delay max -no_line_splits -fields {slew net cap fanout} -path_group in2reg  > ${folder_name}/prects/timing_reports/in2reg.txt
report_checks -corner view -digits 3 -path_delay max -no_line_splits -fields {slew net cap fanout} -path_group reg2reg > ${folder_name}/prects/timing_reports/reg2reg.txt
report_checks -corner view -digits 3 -path_delay max -no_line_splits -fields {slew net cap fanout} -path_group reg2out > ${folder_name}/prects/timing_reports/reg2out.txt
report_checks -corner view -digits 3 -path_delay max -no_line_splits -fields {slew net cap fanout} -path_group in2out  > ${folder_name}/prects/timing_reports/in2out.txt

##WRITE ROUTE DATA
exec mkdir -p ${folder_name}/prects/def/
exec mkdir -p ${folder_name}/prects/netlist/
exec mkdir -p ${folder_name}/prects/sdc/
exec mkdir -p ${folder_name}/prects/sdf/

write_def ${folder_name}/prects/def/def.def
write_verilog -remove_cells [concat $filler_cells $tap_cell] ${folder_name}/prects/netlist/netlist.v
write_sdc ${folder_name}/prects/sdc/sdc.sdc
write_sdf -digits 3 -corner view ${folder_name}/prects/sdf/sdf.sdf

##END TIME
set end_time [exec date +%s]
set prects_time [expr $end_time - $start_time]