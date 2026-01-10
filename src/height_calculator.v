

module height_calculator(
    input clk,
    input [11:0] distance_x,
    input [11:0] distance_y,
    input ray_done,
    input  side,
    input is_wall,
    input setup_complete,
    input wire write_new_frame,
    output reg [9:0] wall_height,
    output reg height_found_d
);

    wire [11:0] distance_final = (side == 0) ? distance_x : distance_y;
    reg [11:0] prev_distance_final;
    reg height_found ;
    reg[11:0] height_lut [4095:0];
    
    initial begin
        $readmemh("D:/HDL_Environment/src/height_lut.mem", height_lut);

    end

    always @(posedge clk) begin
        prev_distance_final <= distance_final;
        if(ray_done && setup_complete && write_new_frame) begin
            wall_height <= height_lut[distance_final];
            height_found <= 1;
           // $display("Dist Index: %d | Height Output: %d", distance_final, height_lut[distance_final]);
           // $display("%d", height_lut[distance_final]);
        end
        else begin
        height_found <= 0;
        end
    end

    always @(posedge clk) begin
        height_found_d <= height_found;

    end
endmodule