##START TIME
set start_time [exec date +%s]

##DONT USE LIST
foreach cell $dont_use_cells {
	set_dont_use $cell
}

##ROUTING LAYERS
set_routing_layers -signal $bottom_routing_metal-$top_routing_metal -clock $bottom_routing_metal-$top_routing_metal

##LAYER RC

if {$pdk_name eq "freepdk45"} {
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
	set_layer_rc -corner view  -layer metal10 -resistance 3.7500e-05 -capacitance 2.8042e-02
}

if {$pdk_name eq "gf180"} {
	# From: ./gf180mcu_1p6m_1tm_9k_sp_smim_OPTB_wst.rules
	# Metal layers
	set_layer_rc -corner view -layer Metal1 -capacitance 0.00016737654 -resistance 0.628392
	set_layer_rc -corner view  -layer Metal2 -capacitance 0.000145608225 -resistance 0.516178
	set_layer_rc -corner view  -layer Metal3 -capacitance 0.0001492182252 -resistance 0.516178
	set_layer_rc -corner view  -layer Metal4 -capacitance 0.000150508225 -resistance 0.516178
	set_layer_rc -corner view  -layer Metal5 -capacitance 0.0001522992252 -resistance 0.516178
	set_layer_rc -corner view  -layer MetalTop -capacitance 0.0001584638706 -resistance 0.161545
	# Vias
	set_layer_rc -corner view  -via Via1 -resistance 16.845
	set_layer_rc -corner view  -via Via2 -resistance 16.845
	set_layer_rc -corner view  -via Via3 -resistance 16.845
	set_layer_rc -corner view  -via Via4 -resistance 16.845
	set_layer_rc -corner view  -via Via5 -resistance 16.845
}

if {$pdk_name eq "asap7"} {
	# Adopted from: https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts/blob/9895e23b5d4abd4610f8d55ccf8f5173e770375e/flow/platforms/asap7/setRC.tcl

	# Liberty units are fF,kOhm
	set_layer_rc -corner view -layer M1 -capacitance 1.1368e-01 -resistance 1.3889e-01
	set_layer_rc -corner view -layer M2 -capacitance 1.3426e-01 -resistance 2.4222e-02
	set_layer_rc -corner view -layer M3 -capacitance 1.2918e-01 -resistance 2.4222e-02
	set_layer_rc -corner view -layer M4 -capacitance 1.1396e-01 -resistance 1.6778e-02
	set_layer_rc -corner view -layer M5 -capacitance 1.3323e-01 -resistance 1.4677e-02
	set_layer_rc -corner view -layer M6 -capacitance 1.1575e-01 -resistance 1.0371e-02
	set_layer_rc -corner view -layer M7 -capacitance 1.3293e-01 -resistance 9.6720e-03
	set_layer_rc -corner view -layer M8 -capacitance 1.1822e-01 -resistance 7.4310e-03
	set_layer_rc -corner view -layer M9 -capacitance 1.3497e-01 -resistance 6.8740e-03

	set_layer_rc -corner view -via V1 -resistance 1.72E-02
	set_layer_rc -corner view -via V2 -resistance 1.72E-02
	set_layer_rc -corner view -via V3 -resistance 1.72E-02
	set_layer_rc -corner view -via V4 -resistance 1.18E-02
	set_layer_rc -corner view -via V5 -resistance 1.18E-02
	set_layer_rc -corner view -via V6 -resistance 8.20E-03
	set_layer_rc -corner view -via V7 -resistance 8.20E-03
	set_layer_rc -corner view -via V8 -resistance 6.30E-03

}

if {$pdk_name eq "sky130"} {
	set_layer_rc -corner view -layer li1 -capacitance 2.582652E-4 -resistance 1.E-1
	set_layer_rc -corner view -via mcon -resistance 2.3E-2
	set_layer_rc -corner view -layer met1 -capacitance 2.246984E-4 -resistance 1.035714E-3
	set_layer_rc -corner view -via via -resistance 3.E-2
	set_layer_rc -corner view -layer met2 -capacitance 1.384201E-4 -resistance 1.035714E-3
	set_layer_rc -corner view -via via2 -resistance 8.E-3
	set_layer_rc -corner view -layer met3 -capacitance 7.435933E-5 -resistance 1.866667E-4
	set_layer_rc -corner view -via via3 -resistance 8.E-3
	set_layer_rc -corner view -layer met4 -capacitance 6.030297E-5 -resistance 1.866667E-4
	set_layer_rc -corner view -via via4 -resistance 8.91E-4
	set_layer_rc -corner view -layer met5 -capacitance 4.057272E-5 -resistance 2.2375E-5
}


##LAYER FOR RC ESTIMATION
set_wire_rc -clock -layer $wire_rc_metal -corner view
set_wire_rc -signal -layer $wire_rc_metal -corner view

##SET ALL CLOCKS TO IDEL (NOT PROPAGATED)
unset_propagated_clock [all_clocks]

#REMOIVE INITAL BUFFERS FROM SYNT NETLIST
remove_buffers

#GLOBAL PLACEMENT
global_placement \
	-timing_driven \
	-routability_driven \
	-overflow "0.1" \
	-density "0.75" \
	-init_density_penalty "1e-2" \
	-pad_left "2" \
	-pad_right "2" \
	-enable_routing_congestion

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
exec mkdir -p ${run_dir}/prects/timing_reports/
report_checks -corner view -digits 3 -path_delay max -no_line_splits -fields {slew net cap fanout} -path_group in2reg  > ${run_dir}/prects/timing_reports/in2reg.txt
report_checks -corner view -digits 3 -path_delay max -no_line_splits -fields {slew net cap fanout} -path_group reg2reg > ${run_dir}/prects/timing_reports/reg2reg.txt
report_checks -corner view -digits 3 -path_delay max -no_line_splits -fields {slew net cap fanout} -path_group reg2out > ${run_dir}/prects/timing_reports/reg2out.txt
report_checks -corner view -digits 3 -path_delay max -no_line_splits -fields {slew net cap fanout} -path_group in2out  > ${run_dir}/prects/timing_reports/in2out.txt

##WRITE ROUTE DATA
exec mkdir -p ${run_dir}/prects/def/
exec mkdir -p ${run_dir}/prects/netlist/
exec mkdir -p ${run_dir}/prects/sdc/
exec mkdir -p ${run_dir}/prects/sdf/

write_def ${run_dir}/prects/def/def.def
write_verilog -remove_cells [concat $filler_cells $tap_cell $endcap_cell] ${run_dir}/prects/netlist/netlist.v
write_sdc ${run_dir}/prects/sdc/sdc.sdc
write_sdf -digits 3 -corner view ${run_dir}/prects/sdf/sdf.sdf

##END TIME
set end_time [exec date +%s]
set prects_time [expr $end_time - $start_time]