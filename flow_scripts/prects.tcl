##START TIME
set start_time [exec date +%s]

##DONT USE LIST
#set_dont_use *clk*
#set_dont_use *_0
#set_dont_use *decap*
#set_dont_use *dly*
#set_dont_use *diode*
#set_dont_use *ebuf*
#set_dont_use *ebuf*
#set_dont_use *ed*
#set_dont_use *ei*
#set_dont_use *lpflow*
#set_dont_use *probe*
#set_dont_use *sd*
#set_dont_use *tap*
#set_dont_use *bufbuf*
#set_dont_use *bufinv*
#set_dont_use *conb*
#set_dont_use *metal*
#set_dont_use *diode*
#set_dont_use *tap*

##ROUTING LAYERS
set_routing_layers -signal metal1-metal10 -clock metal1-metal10

##LAYER FOR RC ESTIMATION
set_wire_rc -clock -layer metal3
set_wire_rc -signal -layer metal3

# Liberty units are fF,kOhm
set_layer_rc {{ corner }} -layer metal1 -resistance 5.4286e-03 -capacitance 7.41819E-02
set_layer_rc {{ corner }} -layer metal2 -resistance 3.5714e-03 -capacitance 6.74606E-02
set_layer_rc {{ corner }} -layer metal3 -resistance 3.5714e-03 -capacitance 8.88758E-02
set_layer_rc {{ corner }} -layer metal4 -resistance 1.5000e-03 -capacitance 1.07121E-01
set_layer_rc {{ corner }} -layer metal5 -resistance 1.5000e-03 -capacitance 1.08964E-01
set_layer_rc {{ corner }} -layer metal6 -resistance 1.5000e-03 -capacitance 1.02044E-01
set_layer_rc {{ corner }} -layer metal7 -resistance 1.8750e-04 -capacitance 1.10436E-01
set_layer_rc {{ corner }} -layer metal8 -resistance 1.8750e-04 -capacitance 9.69714E-02
# No calibration data available for metal9 and metal10
set_layer_rc {{ corner }} -layer metal9 -resistance 3.7500e-05 -capacitance 3.6864e-02
set_layer_rc {{ corner }} -layer metal10 -resistance 3.7500e-05 -capacitance 2.8042e-0

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
-enable_routing_congestion

##ADD TIELO TIEHI
insert_tiecells -prefix TIE LOGIC0_X1/Z
insert_tiecells -prefix TIE LOGIC1_X1/Z

repair_tie_fanout -verbose LOGIC0_X1/Z
repair_tie_fanout -verbose LOGIC0_X1/Z

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
exec mkdir -p ${folder_name}/timing_reports/prects/
report_checks -corner view -digits 3 -path_delay max -no_line_splits -fields {slew net cap fanout} -path_group in2reg  > ${folder_name}/timing_reports/prects/in2reg.txt
report_checks -corner view -digits 3 -path_delay max -no_line_splits -fields {slew net cap fanout} -path_group reg2reg > ${folder_name}/timing_reports/prects/reg2reg.txt
report_checks -corner view -digits 3 -path_delay max -no_line_splits -fields {slew net cap fanout} -path_group reg2out > ${folder_name}/timing_reports/prects/reg2out.txt
report_checks -corner view -digits 3 -path_delay max -no_line_splits -fields {slew net cap fanout} -path_group in2out  > ${folder_name}/timing_reports/prects/in2out.txt

##WRITE ROUTE DATA
exec mkdir -p ${folder_name}/prects/def/
exec mkdir -p ${folder_name}/prects/netlist/
exec mkdir -p ${folder_name}/prects/sdc/
exec mkdir -p ${folder_name}/prects/sdf/

write_def ${folder_name}/prects/def/def.def
write_verilog -remove_cells "*FILL* *TAPCELL_X1*" ${folder_name}/prects/netlist/netlist.v
write_sdc ${folder_name}/prects/sdc/sdc.sdc
write_sdf -digits 3 -corner view ${folder_name}/prects/sdf/sdf.sdf

##END TIME
set end_time [exec date +%s]
set prects_time [expr $end_time - $start_time]