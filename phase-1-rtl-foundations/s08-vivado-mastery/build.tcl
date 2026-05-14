# build.tcl
set part xc7a100tcsg324-1
set top  traffic_light

# 1. Read sources
read_verilog -sv [glob ../s06*/rtl/*.sv]
read_xdc     [glob ./xdc/*.xdc]

# 2. Synthesis
synth_design -top $top -part $part
# write_checkpoint -force ./build/post_synth.dcp
# report_utilization -file ./build/util_synth.rpt
# report_timing_summary -file ./build/timing_synth.rpt

# 3. Optimization, placement, routing
opt_design
place_design
phys_opt_design
route_design
# write_checkpoint -force ./build/post_route.dcp

# 4. Final reports
report_utilization      -file ./build/util_impl.rpt
report_timing_summary   -file ./build/timing_impl.rpt
file delete -force clockInfo.txt

# 5. Generate bitstream
write_bitstream -force ./build/${top}.bit

# 6. Cleanup
exit