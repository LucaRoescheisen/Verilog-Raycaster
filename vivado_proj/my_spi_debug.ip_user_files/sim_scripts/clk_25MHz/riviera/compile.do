transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xpm
vlib riviera/xil_defaultlib

vmap xpm riviera/xpm
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xpm  -incr "+incdir+../../../ipstatic" "+incdir+../../../../../../XilinxSoftware/2025.1/Vivado/data/rsb/busdef" -l xpm -l xil_defaultlib \
"D:/XilinxSoftware/2025.1/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -93  -incr \
"D:/XilinxSoftware/2025.1/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../ipstatic" "+incdir+../../../../../../XilinxSoftware/2025.1/Vivado/data/rsb/busdef" -l xpm -l xil_defaultlib \
"../../../../my_spi_debug.gen/sources_1/ip/clk_25MHz/clk_25MHz_clk_wiz.v" \
"../../../../my_spi_debug.gen/sources_1/ip/clk_25MHz/clk_25MHz.v" \

vlog -work xil_defaultlib \
"glbl.v"

