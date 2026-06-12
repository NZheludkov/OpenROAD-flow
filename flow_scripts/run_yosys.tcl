##TCL MODE
yosys -import

##SOURCE CONFIG
source $::env(CONFIG_FILE)

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
# Simplemap to remove coarse-grain cells as $not etc
# ============================================================

puts "\n=== Simplemap ==="

simplemap
opt_clean

# ============================================================
# Technology mapping with ABC
# ============================================================

puts "\n=== Standard Cell Mapping ==="

abc -liberty $liberty -D $delay_constraint_synt -constr $constraint_file

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

exec mkdir -p ${run_dir}/synt/netlist_synt_stat/

tee -o \
    ${run_dir}/synt/netlist_synt_stat/stat.txt \
    stat -top $design -liberty $liberty

# ============================================================
# Write synthesized netlist
# ============================================================

puts "\n=== Writing Netlist ==="

exec mkdir -p ${run_dir}/synt/netlist/

write_verilog \
    -noattr \
    -noexpr \
    -nohex \
    -nodec \
    ${run_dir}/synt/netlist/${design}.v

puts "\n=== SYNTHESIS FINISHED SUCCESSFULLY ==="