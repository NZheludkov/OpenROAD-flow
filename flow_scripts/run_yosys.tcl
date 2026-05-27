##TCL MODE
yosys -import

# =====================================
# Basic run vars
# =====================================

set design              $env(design)
set rtl_dataset_path    $env(rtl_dataset_path)
set pdk_path            $env(pdk_path)
set output_dir          $env(output_dir)

# =====================================
# Timing / floorplan vars
# =====================================

set CLK_PERIOD          $env(CLK_PERIOD)
set IO_DELAY            $env(IO_DELAY)

set CU                  $env(CU)
set AR                  $env(AR)

# =====================================
# PDN vars
# =====================================

set PDN_HWIDTH          $env(PDN_HWIDTH)
set PDN_HSPACING        $env(PDN_HSPACING)
set PDN_HPITCH          $env(PDN_HPITCH)

set PDN_VWIDTH          $env(PDN_VWIDTH)
set PDN_VSPACING        $env(PDN_VSPACING)
set PDN_VPITCH          $env(PDN_VPITCH)

# =====================================
# PDK vars
# =====================================

set tech_lef            $env(tech_lef)
set cells_lef           $env(cells_lef)
set lef_list            $env(lef_list)

set liberty             $env(liberty)

set core_site           $env(core_site)

set tap_cell            $env(tap_cell)
set endcap_cell         $env(endcap_cell)
set tap_cell_distance   $env(tap_cell_distance)

set techmap_verilog_files $env(techmap_verilog_files)

set bottom_routing_metal $env(bottom_routing_metal)
set top_routing_metal    $env(top_routing_metal)

set pins_hor_layers      $env(pins_hor_layers)
set pins_ver_layers      $env(pins_ver_layers)

set wire_rc_metal        $env(wire_rc_metal)

set tiehi_cell           $env(tiehi_cell)
set tielo_cell           $env(tielo_cell)

set tiehi_cell_pin       $env(tiehi_cell_pin)
set tielo_cell_pin       $env(tielo_cell_pin)

set filler_cells         $env(filler_cells)
set dont_use_cells       $env(dont_use_cells)

set max_slew_cts         $env(max_slew_cts)
set max_cap_cts          $env(max_cap_cts)

set cts_root_buf         $env(cts_root_buf)
set cts_buf_list         $env(cts_buf_list)

set process_node         $env(process_node)

set rc_extract_file      $env(rc_extract_file)

set pdk_name             $env(pdk_name)

##source config
source $rtl_dataset_path/designs/${design}/config.tcl

set folder_name ""

if {[info exists CLK_PERIOD]} { append folder_name "CLK_${CLK_PERIOD}_" }
if {[info exists IO_DELAY]} { append folder_name "IO_${IO_DELAY}_" }
if {[info exists CU]} { append folder_name "CU_${CU}_" }
if {[info exists AR]} { append folder_name "AR_${AR}_" }
if {[info exists PDN_HWIDTH]} { append folder_name "HW_${PDN_HWIDTH}_" }
if {[info exists PDN_HSPACING]} { append folder_name "HS_${PDN_HSPACING}_" }
if {[info exists PDN_HPITCH]} { append folder_name "HP_${PDN_HPITCH}_" }
if {[info exists PDN_VWIDTH]} { append folder_name "VW_${PDN_VWIDTH}_" }
if {[info exists PDN_VSPACING]} { append folder_name "VS_${PDN_VSPACING}_" }
if {[info exists PDN_VPITCH]} { append folder_name "VP_${PDN_VPITCH}_" }

# Удаляем последний символ "_"
set folder_name [string trimright $folder_name "_"]
set folder_name $output_dir/${pdk_name}/${design}/$folder_name

# Создаем папку
exec mkdir -p $folder_name

# ============================================================
# Read Liberty
# ============================================================
# ASAP7 Liberty may contain incomplete latch information.
# Ignore non-critical parser warnings.

puts "\n=== Reading Liberty ==="

read_liberty \
    -ignore_miss_func \
    -ignore_miss_dir \
    -ignore_miss_data_latch \
    -lib \
    $liberty

# ============================================================
# Read RTL
# ============================================================

puts "\n=== Reading RTL ==="

set rtl_list [glob $rtl_dataset_path/designs/$design/rtl/*.v]

foreach rtl $rtl_list {
    puts "Reading: $rtl"
    read_verilog $rtl
}

# ============================================================
# Design elaboration
# ============================================================

puts "\n=== Hierarchy Check ==="

hierarchy -check -top $design

# ============================================================
# Process lowering
# ============================================================
# Convert behavioral RTL into internal RTLIL netlist.

puts "\n=== Process Conversion ==="

proc_clean
proc_rmdead
proc_prune
proc_init
proc_arst
proc_rom
proc_mux
proc_dlatch
proc_dff
proc_memwr
proc_clean

# ============================================================
# Early optimizations
# ============================================================

puts "\n=== Early Optimization ==="

opt_expr
opt_clean
opt -nodffe -nosdff

# ============================================================
# Optional hierarchy flattening
# ============================================================
# Flatten improves optimization but removes hierarchy.

puts "\n=== Flatten Design ==="

flatten

# ============================================================
# Logic optimization
# ============================================================

puts "\n=== Logic Optimization ==="

opt_expr
opt_clean

fsm
opt

wreduce
peepopt

opt_clean

alumacc
share

opt

# ============================================================
# Memory processing
# ============================================================

puts "\n=== Memory Mapping ==="

memory -nomap
opt_clean

opt -fast -full

memory_map

opt -full

# ============================================================
# Technology mapping preparation
# ============================================================

puts "\n=== Techmap Preparation ==="

techmap
opt -fast

# ============================================================
# Generic ABC optimization
# ============================================================
# Technology-independent optimization before cell mapping.

puts "\n=== Generic ABC Optimization ==="

abc -fast
opt -fast

# ============================================================
# Post-optimization checks
# ============================================================

hierarchy -check -top $design

stat
check

# ============================================================
# Final generic cleanup
# ============================================================

opt
opt_clean -purge

# ============================================================
# Custom techmaps
# ============================================================
# Optional user-defined technology mappings.

if {[llength $techmap_verilog_files] > 0} {

    puts "\n=== Applying Custom Techmaps ==="

    foreach file $techmap_verilog_files {

        puts "Techmap: $file"

        techmap -map $file
    }
}

# ============================================================
# Sequential cell mapping
# ============================================================

puts "\n=== DFF Mapping ==="

dfflibmap -liberty $liberty

# ============================================================
# Technology mapping with ABC
# ============================================================
# IMPORTANT:
# Use legacy ABC instead of abc9/abc_new for ASAP7 stability.

puts "\n=== Standard Cell Mapping ==="

abc -liberty $liberty

# ============================================================
# Final checks
# ============================================================

puts "\n=== Final Checks ==="

hierarchy -check -top $design

stat -top $design

check

# ============================================================
# Net cleanup
# ============================================================

splitnets
clean -purge

# ============================================================
# Reports
# ============================================================

puts "\n=== Writing Reports ==="

exec mkdir -p ${folder_name}/synt/netlist_synt_stat/

tee -o \
    ${folder_name}/synt/netlist_synt_stat/stat.txt \
    stat -top $design -liberty $liberty

# ============================================================
# Write synthesized netlist
# ============================================================

puts "\n=== Writing Netlist ==="

exec mkdir -p ${folder_name}/synt/netlist/

write_verilog \
    -noattr \
    -noexpr \
    -nohex \
    -nodec \
    ${folder_name}/synt/netlist/${design}.v

puts "\n=== SYNTHESIS FINISHED SUCCESSFULLY ==="