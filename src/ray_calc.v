module ray_calculator(
    input              clk,
    input              reset,
    //input reset,//Ignore for the moment
    input [11:0]       xPos,                 //4 bits for world location normalised (0-15) // 8 bits for fractional part (0-255)
    input [11:0]       yPos,                   //4 bits for world location normalised (0-15) // 8 bits for fractional part (0-255)
    input [8:0]        player_angle,

    input wire         is_new_ray,
    input wire [1:0]   fsm_state,
    input wire [9:0]   ray_index,
    input wire         write_new_frame,
    output reg         ray_done,
    output reg [11:0]  distance_x,
    output reg [11:0]  distance_y,
    output reg         prev_side,
    output wire        is_wall,
    output reg         setup_complete,
    output reg [1:0]   lighting_factor,
    output reg [3:0]   tex_coord
);


    reg side;
    wire[3:0] x_i_p = xPos[11:8];
    wire[3:0] y_i_p = yPos[11:8];
    wire[7:0] x_f_p = xPos[7:0];
    wire[7:0] y_f_p = yPos[7:0];
    reg [3:0] mapX;
    reg [3:0] mapY;
    //wire [1:0] is_wall;
   

    wire [3:0] hit_x_coord;
    wire [3:0] hit_y_coord;

    reg [23:0] deltaDistX; //All below are in Q 8.16 format for precision
    reg [23:0] deltaDistY;
    reg [23:0] sideDistX;  
    reg [23:0] sideDistY;

    reg set_positional_values;

    reg [31:0] trig_lut [511:0];
    reg [23:0] reciprocal_lut [0:4095];
    reg [15:0] cam_x_lut [0:639];
    reg [31:0] full_trig_row;

    world world_map (.clk(clk), .reset(reset), .xPos(mapX), .yPos(mapY), .setup_complete(setup_complete), .is_new_ray(is_new_ray), .is_wall(is_wall), .hit_coord_x(hit_x_coord), .hit_coord_y(hit_y_coord));
    initial begin
        $readmemh("D:/HDL_Environment/src/trig_lut.mem", trig_lut);
        $readmemh("D:/HDL_Environment/src/reciprocal_lut.mem", reciprocal_lut);
        $readmemh("D:/HDL_Environment/src/cam_x_lut.mem", cam_x_lut);

        
    end

    reg [2:0] setup_timer;
    //Separate the fractional and integer parts of the player's position for readability



    always @(posedge clk) begin
        if(reset || is_new_ray) begin
            set_positional_values <= 1;
        end

        if(fsm_state == 2'b01 && set_positional_values == 1 && write_new_frame) begin
            setup_timer <= 3'b001;  
            full_trig_row <= trig_lut[player_angle];
            set_positional_values <= 0;
        end else begin
            if(write_new_frame)
            setup_timer <= {setup_timer[1:0], 1'b0}; // Shift left every clock
        end
    end

    wire signed [15:0] dirX = full_trig_row[31:16];
    wire signed [15:0] dirY = full_trig_row[15:0];


    reg signed [3:0] step_x, step_y;
    wire [8:0] plane_angle = player_angle + 9'd128;
    wire [31:0] plane_trig = trig_lut[plane_angle];

    wire signed [15:0] raw_plane_x = plane_trig[31:16];
    wire signed [15:0] raw_plane_y = plane_trig[15:0];

    wire signed [31:0] scaled_planeX = (raw_plane_x * 17'sd11468) >>> 14;
    wire signed [31:0] scaled_planeY = (raw_plane_y * 17'sd11468) >>> 14;

    wire signed [15:0] plane_x = scaled_planeX[15:0];
    wire signed [15:0] plane_y = scaled_planeY[15:0];


    wire signed [15:0] cam_x = cam_x_lut[ray_index];
    wire signed [31:0] part_x = (plane_x * cam_x) >>> 14;
    wire signed [31:0] part_y = (plane_y * cam_x) >>> 14;

    wire signed [15:0] rayDirX = dirX + part_x[15:0];
    wire signed [15:0] rayDirY = dirY + part_y[15:0];
    wire [15:0] abs_full_x = rayDirX[15] ? (-rayDirX) : rayDirX;
    wire [15:0] abs_full_y = rayDirY[15] ? (-rayDirY) : rayDirY;




    //Find/Update Delta Values
   always @(posedge clk) begin
    if(ray_done || reset) begin
        deltaDistX <= 0;
        deltaDistY <= 0;
        step_x     <= 0;
        step_y     <= 0;
    end

    if (abs_full_x[14]) begin 
        deltaDistX <= 24'h010000; // 1.0 in Q8.16
    end else begin
        // Indexing with [13:4] (1024 entries)
        deltaDistX <= reciprocal_lut[abs_full_x[13:2]]; 
    end

    if (abs_full_y[14]) begin
        deltaDistY <= 24'h010000;
    end else begin
        deltaDistY <= reciprocal_lut[abs_full_y[13:2]];
    end

        step_x <=rayDirX[15] ? -2'd1 : 2'd1;
        step_y <=rayDirY[15] ? -2'd1 : 2'd1;
    end

    reg [23:0] prev_sideDistX;  
    reg [23:0] prev_sideDistY;
    always @(posedge clk) begin
        

        if(ray_done || reset) begin
            prev_sideDistX <= 0;
            prev_sideDistY <= 0;
            sideDistX      <= 0;
            sideDistY      <= 0;
            setup_complete <= 0;
            mapX           <= xPos[11:8];
            mapY           <= yPos[11:8];
        end

        if (setup_timer[1]) begin
            if(step_x > 0) begin
                sideDistX <= ((256 - x_f_p) * deltaDistX )>> 8;
                setup_complete <= 1;
            end else begin 
                sideDistX <= ((x_f_p)       * deltaDistX) >> 8;
                setup_complete <= 1;
            end

            if(step_y > 0) begin
                sideDistY <= ((256 - y_f_p) * deltaDistY) >> 8;
                setup_complete <= 1;
            end else begin 
                sideDistY <= ((y_f_p)       * deltaDistY) >> 8;
                setup_complete <= 1;
            end
        end

        if(setup_complete == 1 && is_wall == 0) begin
            prev_side <= side;
            prev_sideDistX <= sideDistX;
            prev_sideDistY <= sideDistY;
            if(sideDistX < sideDistY) begin
                sideDistX <= sideDistX + deltaDistX;
                mapX <= mapX + step_x;
                side <= 0;  //Vertical hit  |
            end
            else begin
                sideDistY <= sideDistY + deltaDistY;
                mapY <= mapY + step_y;
                side <= 1;  //Horizontal hit -
            end

        end
    end

    wire [23:0] raw_distance = (prev_side == 0) ? (prev_sideDistX - deltaDistX) 
                                                : (prev_sideDistY - deltaDistY);


    //Make raw_distance signed so you can multiply by the rayDir, then shift to 32 bits and add to a padded XPos
    wire signed [40:0] x_part = ($signed({1'b0, raw_distance}) * $signed(rayDirX));
    wire signed [40:0] y_part = ($signed({1'b0, raw_distance}) * $signed(rayDirY));
    wire signed[31:0] wall_hit_x =  ($signed({12'b0, xPos, 8'b0})) + (x_part >>> 14);
                                    
    wire signed[31:0] wall_hit_y = ($signed({12'b0, yPos, 8'b0}))  + (y_part >>> 14);

 
    always @(posedge clk) begin
        if(reset) begin
            ray_done <= 0;
        end

        if(is_wall && ray_done != 1 && setup_complete) begin
            if(prev_side == 0) begin    //Vertical wall
                distance_x <= raw_distance[19:8]; // Since we are Q8.16 we take 4 lowest bits (corresponds to 0- 16), then the 8 highest fractional bits (corresponding to 0- 256)
                distance_y <= 0;
                 if (step_x == 1)
                    tex_coord <= 4'd15 - wall_hit_y[15:12];
                else
                    tex_coord <= wall_hit_y[15:12];

                lighting_factor <= 2'b01;  // Left and right faces are both the same colour (medium colour)
            end
                else begin  //Horizontal wall
                    distance_y <= raw_distance[19:8]; 
                    // FORCE FLIP EVERYTHING
                    if (step_y == -1)
                        tex_coord <= 4'd15 - wall_hit_x[15:12];
                    else
                        tex_coord <= wall_hit_x[15:12];
                        
                    distance_x <= 0;
                    lighting_factor <= (step_y == 1) ? 2'b00 : 2'b10;  // If hits top remain same colour, if its bottom then darken through bit shifting
            end
            ray_done <= 1;
        end  
        if(fsm_state == 2'b01) begin
            ray_done <= 0;
        end
    end

endmodule    