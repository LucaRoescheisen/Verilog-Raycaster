`timescale 1ns / 1ps

`define WIDTH 640
`define HEIGHT 480


module vga_top(
    input clk,
    input reset,
    output h_sync, v_sync,
    output reg[3:0] rgb_r, rgb_g, rgb_b
);
    wire pixel_clk;

    wire [9:0] h_pos, v_pos;

    reg [7:0] column_buffer [0:`WIDTH - 1];


     wire [1:0] fsm_state;
    wire [9:0] ray_index;
    reg data_initialised;
    initial data_initialised = 0;
    //Instantiate 25MHz clock, that uses system clock as source
    vga_clk_25MHz clk_25MHz (.clk(clk), .pixel_clk(pixel_clk));
    vga_sync sync (.pixel_clk(pixel_clk), .reset(reset), .data_initialised(data_initialised), .h_sync(h_sync), .v_sync(v_sync), .h_pos(h_pos), .v_pos(v_pos));
    //spi_master spi_info (.CS(CS), .MOSI(MOSI), .SCK(SCK), .temp_data(spi_data), .received_data(received_spi_data_flag));

    

   wire [9:0] wall_height;
    wire ray_done;
    wire is_new_ray;
    wire switchState;
    wire ray_fed;
    reg write_new_frame;


   ray_counter counter (
        .clk(clk), 
        .reset(reset), 
        .ray_done(ray_done),
        .fsm_state(fsm_state), 
        .ray_index(ray_index),
        .prev_ray_fed(ray_fed)
    );


    wire[11:0] distance_x;
    wire[11:0] distance_y;
    wire[11:0] xPos;
    wire[11:0] yPos;
    wire[8:0] player_angle;
    wire[8:0] ray_angle;    //9 for o to 360 10 for decimal

    assign xPos = 12'b001000000000;
    assign yPos = 12'b001000000000;
    assign player_angle = 128;
    assign ray_angle = 128; //Needs to be normalised between 0 and 511
    /*
    0 = 0 deg
    128 = 90deg
    256 = 180deg
    384 = 270deg
    512 = 360deg

    */

   // wire[18:0] ray_angle;    //9 for o to 360 10 for decimal places
   // assign ray_angle = 270<<10;

    fsm state_machine (
        .clk(clk),
        .reset(reset),

        .switchState(switchState),
        .S(fsm_state) //The Current state
    );
                                            

    ray_feeder feeder(
        .clk(clk),
        .reset(reset),
        .ray_done(ray_done),
        .ray_fed(ray_fed),
        .switchState(switchState)
        
    );

    reg [1:0] previous_fsm_state;
    always @(posedge clk) begin
        previous_fsm_state <= fsm_state;  // store FSM state for next cycle
    end
    

    assign is_new_ray = (fsm_state == 2'b10) && (previous_fsm_state != 2'b10);
    wire[9:0] ray_index_test = 320;
    wire hit_side;
    wire is_wall;
    wire setup_complete;
    ray_calculator calculator (
        .clk(clk),
        .xPos(xPos),
        .yPos(yPos),
        .player_angle(player_angle),
        .ray_angle(ray_angle),
        .is_new_ray(is_new_ray),
        .fsm_state(fsm_state),
        .ray_index(ray_index),
        .write_new_frame(write_new_frame),
        .ray_done(ray_done),
        .distance_x(distance_x),
        .distance_y(distance_y),
        .prev_side(hit_side),
        .is_wall(is_wall),
        .setup_complete(setup_complete)
    );

    
    wire height_found;
    height_calculator height_calc(
        .clk(clk),
        .distance_x(distance_x),
        .distance_y(distance_y),
        .ray_done(ray_done),
        .side(hit_side),
        .is_wall(is_wall),
        .setup_complete(setup_complete),
        .write_new_frame(write_new_frame),
        .wall_height(wall_height),
        .height_found_d(height_found)
    );

    /*ray_calculator calculator(
        .clk(clk),
        .xPos(xPos),
        .yPos(yPos),
        .player_angle(player_angle),
        .ray_angle(ray_angle),
        .is_new_ray(is_new_ray),
        .fsm_state(fsm_state),
        .ray_done(ray_done),
        .distance_x(distance_x),
        .distance_y(distance_y)
    );
*/
    reg [8:0] mem_height_buffer_1 [639:0]; 
    reg [8:0] mem_height_buffer_2 [639:0]; 
    reg [8:0] count_1;
    reg [8:0] count_2;
    reg switch;
    reg first_initialisation;
    initial switch = 0;
    initial first_initialisation = 1;
    always @(posedge clk) begin
        if((v_pos == (`HEIGHT - 1) && h_pos ==(`WIDTH - 1)) || first_initialisation) begin
            write_new_frame <= 1;
            first_initialisation <= 0;
        end

        if (data_initialised == 0) begin
            if (height_found) begin // <--- Only write when the math is actually finished!
                mem_height_buffer_1[ray_index] <= wall_height;
                if(ray_index == 639) begin
                    data_initialised <= 1;
                    switch <= 1;
                end
            end
        end

        else begin
            if(switch == 0 && write_new_frame == 1) begin
                mem_height_buffer_1[ray_index] <= wall_height;
            end
            else if(switch == 1 && write_new_frame == 1) begin
                mem_height_buffer_2[ray_index] <= wall_height;
            end

            if(ray_index == 639 && height_found) begin
                switch <= !switch;
                write_new_frame <= 0;
            end
        end
    end

   
//Main loop
    wire video_on = (h_pos < `WIDTH) && (v_pos < `HEIGHT);
    reg [9:0] pos_count;
    reg [8:0] column_height; //Used to reduce number of reads per cycle
    initial pos_count = 0;
    wire [8:0] half_height = (column_height >> 1);
    wire [9:0] wall_top    = (half_height > 240) ? 0   : (240 - half_height);
    wire [9:0] wall_bottom = (half_height > 240) ? 479 : (240 + half_height);
    always @(posedge pixel_clk) begin
        column_height <= switch ? mem_height_buffer_1[h_pos] : mem_height_buffer_2[h_pos];
    end

    always @(posedge pixel_clk) begin
        if(data_initialised && video_on) begin
            if(v_pos >= wall_top && v_pos <= wall_bottom) begin
                rgb_r <= 4'b1111;
                rgb_g <= 4'b0000;
                rgb_b <= 4'b0000;
            end

        end else begin
            rgb_r <= 4'b0000;
            rgb_g <= 4'b0000;
            rgb_b <= 4'b0000;
        end



          // if(h_pos >= 1 && h_pos < 20 && v_pos >= 1 && v_pos < 20) begin
          //      rgb_r <= 4'b1111;
            //    rgb_g <= 4'b0000;
             //   rgb_b <= 4'b0000;
           // end
           // else begin 

           // end
        
    end


    //2FF Synchronisation
   //reg[1:0] sync_spi_flag = 0;
   //always @(posedge pixel_clk) begin
   //    sync_spi_flag <= {sync_spi_flag[0], received_spi_data_flag};
   //end

   //wire spi_data_ready = (sync_spi_flag & 2'b01);


   //always @(posedge pixel_clk) begin 
   //    if (spi_data_ready) begin                     
   //        if(bram_ptr == `WIDTH -1)
   //            bram_ptr <= 0;
   //        else begin
   //            column_buffer[bram_ptr] <= spi_data[7:0];
   //            bram_ptr <= bram_ptr + 1;
   //       end
   //    end    
   //end 


endmodule




//Generates a 25MHz clock
module vga_clk_25MHz(
    input clk,
    output reg pixel_clk
);

    initial begin
      pixel_clk = 0;
    end


    reg[1:0] counter = 0;

    always @(posedge clk) begin
        if(counter == 1) begin
            counter <= 0;
            pixel_clk <= ~pixel_clk;
        end
        else begin
            counter <= counter + 1'b1;
        end
    end



endmodule
