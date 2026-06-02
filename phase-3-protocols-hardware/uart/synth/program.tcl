# program.tcl
open_hw_manager

# 1. Connect to server (via WSL bridge)
connect_hw_server -url 172.31.176.1:3121
open_hw_target [get_hw_targets *]

# 2. Map and flash the bitstream
set_property PROGRAM.FILE {./synth/uart_top.bit} [get_hw_devices xc7a100t*]
program_hw_devices [get_hw_devices xc7a100t*]

# 3. Cleanup
exit