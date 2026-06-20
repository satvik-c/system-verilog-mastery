# build.tcl
set part xc7a100tcsg324-1
set top  spi_top

# 1. Read sources
read_verilog -sv [glob ./rtl/*.sv]
read_xdc     [glob ./synth/*.xdc]

# 2. Synthesis
synth_design -top $top -part $part

# 3. Optimization, placement, routing
opt_design
place_design
phys_opt_design
route_design

# 4. Final reports
report_utilization      -file ./reports/util_impl.rpt
report_timing_summary   -file ./reports/timing_impl.rpt
file delete -force clockInfo.txt

# 5. Generate bitstream
write_bitstream -force ./synth/${top}.bit

# 6. Cleanup
exit