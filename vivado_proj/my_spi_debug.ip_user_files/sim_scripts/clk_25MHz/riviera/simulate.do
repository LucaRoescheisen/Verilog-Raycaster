transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+clk_25MHz  -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.clk_25MHz xil_defaultlib.glbl

do {clk_25MHz.udo}

run 1000ns

endsim

quit -force
