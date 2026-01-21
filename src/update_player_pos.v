module update_player_pos(
    input clk,
    input reset,
    input spi_flag,
    input [7:0] spi_data,
    input [8:0] player_angle,
    output reg[11:0] x_pos,
    output reg[11:0] y_pos


);
    localparam FORWARD = 1;
    localparam BACKWARD = 2;
    localparam SPEED = 12; //actual speed is /2
    reg [31:0] trig_lut [511:0];
    reg [31:0] full_trig_row;
    initial begin
        $readmemh("D:/HDL_Environment/src/trig_lut.mem", trig_lut);
        x_pos = 12'b001000000000;
        y_pos = 12'b001000000000;
    end

    wire signed [15:0] dir_x = full_trig_row[31:16]; //Instantly update given the case statement
    wire signed [15:0] dir_y = full_trig_row[15:0];

   
    reg spi_sync_0, spi_sync_1;
    wire spi_tick;
    always @(posedge clk) begin
        spi_sync_0 <= spi_flag;
        spi_sync_1 <= spi_sync_0;
    end
    assign spi_tick = spi_sync_0 && !spi_sync_1;


    always @(posedge clk) begin
        if(reset) begin
            x_pos <= 12'b001000000000;
            y_pos <= 12'b001000000000;
     
        end

        full_trig_row <= trig_lut[player_angle];

        if(spi_tick) begin

            case(spi_data)
                FORWARD : begin
                    x_pos <= x_pos + $signed((dir_x * $signed(SPEED)) >>> 14); 
                    y_pos <= y_pos + $signed((dir_y * $signed(SPEED)) >>> 14);
                end
                BACKWARD : begin
                    x_pos <= x_pos - $signed((dir_x * $signed(SPEED)) >>> 14);
                    y_pos <= y_pos - $signed((dir_y * $signed(SPEED)) >>> 14);
                end
                default : begin
                        x_pos <= x_pos;
                        y_pos <= y_pos;
                end
            endcase
        end


    end


endmodule