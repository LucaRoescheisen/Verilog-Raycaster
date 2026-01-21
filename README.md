# **FPGA Ray-Casting Engine**

Target Hardware: Arty S7, Raspberry Pi Pico

Language: Verilog, Python

Tools: Vivado ML Edition, Micro Python

**NOTE:**
This was my transition project into HDLs. My goal was to learn about hardware implementations of 3D rendering and implement a complex system to understand 
how FPGAs function, deepen my knowledge on resource management, timing closure and RTL design patterns

 **##1. Project Overview**
   This project is a real-time 3D rendering engine based on the DDA algorithm (similar to Wolfenstein 3D). It calculates the intersection of rays with grid lines
   in hardware to generate a pseudo-3D perspective on a VGA display.
   Key Features
   - Real-time Ray-Casting: Custom RTL logic to handle DDA calculations.
   - VGA Conbtroller: Outputs at 640x480 @ 60Hz
   - Texture System: Any 16x16px texture (can also upload 64x64 textures with minimum effort).
   - SPI Interface: Pico MAter controller handles player movement and rotation input.

**2. System Architecture**
     - vga_top.v: Acts as the top-level module that connected the pixel clock, synchronisation logic and the ray engine.
     - ray_calculator.v: Calculates ray directgion, step distance and wall hits.
     - height_calculator.v: Uses distance from ray_calculator and produces a wall height that is clamped between 1px and 480px.
     - spi_master.v: Decodes spi signals.
     - update_player_movement.v: Uses output of spi unit to update player location and player angle.
     - world.v: Acts as RAM for level map, providing information whether a wall has been hit/detected.
     - fsm.v: Manages the state of the rendering pipeline (Setup -> Load Ray-> Calculate Ray distance).
  
 **3. Challenges**
     ###- Pipeline Alignment
        - Current version of the ray calculator suffers from timing violations due to long combination paths in the reciprocal and multiplcation logic.
     ###-  IP Core and ILA Debugging
        - First instances of the project were purely built in VS Code and using TCL to Synthesise and create Implementations. This caused issues later on when attempting
          to debug using ILA and utilising IP core.

 **4. Resource Utilisation**
       - DSPs: Used for fixed-point multiplications for multiple stages in the ray-calculator.
       - BRAM: Used to store world_map, trig_lut and reciprocal_lut.

 **5. Future Work**
       - Pipelining DDA: Fixs timing violations of -0.434ns
       - Utilise IP Clocking cores to generate 25MHz instead of a counter.
