
module tb_vga_top;
    reg clk = 0;
    reg CS = 1;
    reg SCK = 0;
    reg MOSI = 0;

    task send_spi_data(input [7:0] data);
        integer i;
        begin
            CS = 0;
            #5;
            for (i = 7; i>= 0; i = i -1) begin
                MOSI = data[i];
                #20;
                SCK = 1;
                #20;
                SCK = 0;
                #20;
            end
            #10;
            CS = 1;             
            #40;
        end
    
    endtask

    vga_top uut (
        .clk(clk),
        .CS(CS),
        .MOSI(MOSI),
        .SCK(SCK)
    );

    //spi_master uuut(.CS(CS), .MOSI(MOSI), .SCK(clk));
    always #1 clk = ~clk;

    initial begin


        $display("Starting simulation...");
        CS = 1;
        SCK = 0;
        MOSI = 0;
        #2500;
         $display("Sending packet");
        send_spi_data(8'h02);
   
       

        // Simulate toggling switchState to trigger FSM transitions

        #1000000000;
        $display("Simulation finished.");
        $stop;
    end

endmodule