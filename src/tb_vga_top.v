
module tb_vga_top;
    reg clk = 0;
    reg reset = 0;




    vga_top uut (
        .clk(clk),
        .reset(reset)
    );

    //spi_master uuut(.CS(CS), .MOSI(MOSI), .SCK(clk));
    always #5 clk = ~clk;

    initial begin


        $display("Starting simulation...");
        
        reset = 1;
        #10;
        reset = 0;

        // Simulate toggling switchState to trigger FSM transitions

        #1000000000;
        $display("Simulation finished.");
        $stop;
    end

endmodule