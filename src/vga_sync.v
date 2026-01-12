`timescale 1ns / 1ps

module vga_sync#(
//Static Parameters
    //All numbers are derived from https://digilent.com/reference/pmod/pmodvga/reference-manual
    //H-sync
    parameter H_FRONT        = 16,
    parameter H_BACK         = 48,
    parameter H_PULSE_WIDTH  = 96,
    parameter H_DISPLAY_TIME = 640,
    parameter H_SYNC_PULSE   = 800, 

    //V-sync
    parameter V_FRONT        = 10,
    parameter V_BACK         = 29,
    parameter V_PULSE_WIDTH  = 2,
    parameter V_DISPLAY_TIME = 480,
    parameter V_SYNC_PULSE   = 521

    //Pixel Positions

)

(
//Inputs
    input pixel_clk,  //Pixel clock runs at 25MHz
    input reset,
    input data_initialised,
//Outputs
    output reg h_sync,
    output reg v_sync,
    
    output reg[9:0] h_pos, 
    output reg[9:0] v_pos
);


    reg [9:0] h_count = 0;
    reg [9:0] v_count = 0;  



    //Counts pixel clock pulses, and sets HIGH when VGA can write to screen (HSYNC)
   always @(posedge pixel_clk) begin
    if(reset) begin
        h_count <= 0;
        v_count <= 0;
        h_pos <= 0;
        v_pos <= 0;
        h_sync <= 1;
        v_sync <= 1;
    end else begin
        
        // Horizontal counter
        if(h_count == H_SYNC_PULSE - 1) begin
            h_count <= 0;
            // Vertical counter
            if(v_count == V_SYNC_PULSE - 1)
                v_count <= 0;
            else
                v_count <= v_count + 1;
        end else begin
            h_count <= h_count + 1;
        end

        // Sync signals (active low)
        h_sync <= !((h_count >= (H_DISPLAY_TIME + H_FRONT)) && (h_count < (H_DISPLAY_TIME + H_FRONT + H_PULSE_WIDTH)));
        v_sync <= !((v_count >= (V_DISPLAY_TIME + V_FRONT)) && (v_count < (V_DISPLAY_TIME + V_FRONT + V_PULSE_WIDTH)));

        // Pixel positions
        h_pos <= h_count;
        v_pos <= v_count;

        
    end
end


    
endmodule