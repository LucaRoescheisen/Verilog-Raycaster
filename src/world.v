`define WORLD_X 16
`define WORLD_Y 16

module world(
    input       clk,
    input       reset,
    input [3:0] xPos,
    input [3:0] yPos,
    input setup_complete,
    input is_new_ray,
    output reg  is_wall, // 1 is wall, 0 is air 
    output reg [3:0] hit_coord_x,
    output reg [3:0] hit_coord_y
);

    reg [7:0] map [0:`WORLD_X*`WORLD_Y-1];
    initial begin 
        $readmemh("D:/HDL_Environment/src/map.hex", map);
    end

    reg [3:0] delayed_x, delayed_y;
    reg lock;
    always @(posedge clk) begin 
        if(reset) begin
            is_wall <= 0;
        end


        if (is_new_ray || setup_complete == 0) begin
            lock <= 0;
            is_wall <= 0;
        end else begin
            is_wall <= map[yPos*`WORLD_X + xPos];

            delayed_x <= xPos;
            delayed_y <= yPos;
            if(is_wall && lock != 0) begin
      
                hit_coord_x <= delayed_x;
                hit_coord_y <= delayed_y;
                lock <= 1;
            end
        end
    end

endmodule

