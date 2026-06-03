##START TIME
set start_time [exec date +%s]

##STAGE
set flow_stage init_design

##CREATE TIMING CORNER
define_corners view

##READ LEF LIST
foreach lef $lef_list {
	read_lef $lef
}

##READ LIBERTY FILE
foreach lib $liberty {
	read_liberty -corner view $lib
}

##UNITS
set_cmd_units -time $liberty_time_unit -capacitance $liberty_cap_unit -current $liberty_current_unit -voltage $liberty_voltage_unit -resistance $liberty_res_unit -distance um

##READ NETLIST
read_verilog ${run_dir}/synt/netlist/${design}.v
link_design $design

##READ SDC
read_sdc $rtl_dataset_path/designs/$design/sdc/func.tcl

##CREATE PATH GROUP
group_path -name reg2reg -from [all_registers] -to [all_registers]
group_path -name in2reg -from [all_inputs] -to [all_registers]
group_path -name reg2out -from [all_registers] -to [all_outputs]
group_path -name in2out -from [all_inputs] -to [all_outputs]

#get netlist size (cells and nets)
set cells_number [llength [get_cells *]]
set nets_number [llength [get_nets *]]

##END TIME
set end_time [exec date +%s]
set init_design_time [expr $end_time - $start_time]