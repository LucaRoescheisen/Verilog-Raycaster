# FPGA Ray-Casting Engine

**Target Hardware:** Arty S7 (Xilinx Spartan-7), Raspberry Pi Pico  
**Language:** Verilog, Python  
**Tools:** Vivado ML Edition, MicroPython

---

> **Note on Project Origin:** > This was my transition project into Hardware Description Languages (HDLs). My goal was to move beyond basic logic and implement a mathematically complex system (3D Ray-Casting) to understand how FPGAs function, deepening my knowledge of resource management, timing closure, and RTL design patterns.

---

## 1. Project Overview
This project is a real-time 3D rendering engine based on the **DDA (Digital Differential Analyzer)** algorithm. It calculates the intersection of rays with grid lines in hardware to generate a pseudo-3D perspective on a VGA display.

### Key Features
* **Real-time Ray-Casting:** Custom RTL logic to handle high-speed DDA calculations.
* **VGA Controller:** Built from scratch to output **640x480 @ 60Hz**.
* **Texture System:** Supports 16x16px textures (with logic ready for 64x64px expansion).
* **SPI Interface:** Integrated a Raspberry Pi Pico as a Master controller to handle player movement and rotation input.

---

## 2. System Architecture
The design is modularized to separate the math engine from the display and input peripherals.



* **`vga_top.v`**: The top-level module connecting the pixel clock, synchronization logic, and the ray engine.
* **`ray_calculator.v`**: The "Math Core" that calculates ray direction, step distance, and wall hits.
* **`height_calculator.v`**: Translates distance into a wall height clamped between 1px and 480px.
* **`spi_master.v`**: Decodes incoming SPI signals from the external controller.
* **`update_player_movement.v`**: Updates player coordinates and viewing angle based on SPI input.
* **`world.v`**: Acts as ROM/RAM for the level map, providing wall detection data.
* **`fsm.v`**: Manages the rendering pipeline state (**Setup** $\rightarrow$ **Load Ray** $\rightarrow$ **Calculate Distance**).

---

## 3. Engineering Challenges

### Pipeline Alignment & Timing
The current iteration of the ray calculator encountered timing violations due to deep combinational paths in the reciprocal and multiplication logic. 
* **Observation:** Identified a **Worst Negative Slack (WNS) of -0.434ns**.
* **Lesson learned:** Gained a deep understanding of why register balancing is required to break up long logic chains in high-speed RTL.

### IP Core and ILA Debugging
Initially, the project used a CLI-only flow (VS Code + Tcl scripts for Synthesis/Implementation). 
* **Challenge:** Debugging hardware-level bugs proved difficult without visual tools.
* **Solution:** Transitioned to the Vivado GUI to integrate **ILA (Integrated Logic Analyzer)** cores, allowing for real-time signal probing on the Spartan-7 chip.

---

## 4. Resource Utilization
* **DSPs:** Leveraged for multi-stage fixed-point multiplications within the ray-calculator.
* **BRAM (Block RAM):** Utilized to store the `world_map`, `trig_lut` (Trigonometry), and `reciprocal_lut`.

---

## 5. Future Work
* **DDA Pipelining:** Refactoring the DDA loop to eliminate the current -0.434ns timing violation.
* **Clocking Wizard IP:** Replacing the manual counter-based clock divider with a Xilinx Clocking Wizard to generate a more stable, low-jitter 25.175MHz pixel clock.
