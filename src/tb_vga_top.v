
module tb_vga_top;
    reg clk = 0;





    vga_top uut (
        .clk(clk)
   
    );

    //spi_master uuut(.CS(CS), .MOSI(MOSI), .SCK(clk));
    always #5 clk = ~clk;

    initial begin


        $display("Starting simulation...");
        
 
   
       

        // Simulate toggling switchState to trigger FSM transitions

        #1000000000;
        $display("Simulation finished.");
        $stop;
    end

endmodule