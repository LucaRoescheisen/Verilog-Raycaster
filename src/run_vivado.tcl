create_project -force my_spi_debug ./vivado_proj -part xc7s50csga324-1
add_files [glob ./src/*.v]
set_property top vga_top [current_fileset]
update_compile_order -fileset sources_1
add_files -fileset constrs_1 ./constraints/arty.xdc
start_gui