# Read HDL source
read_verilog "src/vga_top.v"
read_verilog "src/vga_sync.v"
read_verilog "src/fsm.v"
read_verilog "src/height_calculator.v"
read_verilog "src/ray_calc.v"
read_verilog "src/ray_feeder.v"
read_verilog "src/spi_master.v"
read_verilog "src/world.v"
read_verilog "src/update_player_pos.v"
# Read constraints
read_xdc "D:/HDL_Environment/constraints/arty.xdc"

# Synthesize
synth_design -top vga_top -part xc7s50csga324-1


# Implement
opt_design
place_design
route_design

# Write bitstream
write_bitstream -force "vga_proj.bit"

