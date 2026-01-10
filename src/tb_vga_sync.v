module tb_vga_sync;
    reg clk = 0;
    reg reset = 0; 
    
    vga_sync uut (.pixel_clk(clk), .reset(reset));

    always #1 clk = ~clk;
    
    initial begin


        $display("Starting simulation...");

        #10000000;
        $display("Simulation finished.");
        $stop;
    end
    
endmodule