module ray_counter(
    input            clk,
    input            reset,
    input            ray_done,

    input wire[1:0]  fsm_state,
    output reg [9:0] ray_index,
    output reg ray_fed 
);
    reg test;
    always @(posedge clk) begin
        if(reset) begin
            ray_index <= 0;
            ray_fed  <= 0;
        end 
        else begin
            if(fsm_state == 2'b01 && ray_done) begin
                ray_index <= ray_index + 1;
                if(ray_index == 639)
                     ray_index <= 0;

                ray_fed  <= 1;
            end
            else if (fsm_state == 2'b00 || fsm_state == 2'b11) begin
                ray_index <= 0;
                ray_fed <= 1;
            end
            else  begin
                ray_fed <= 0;
            end
        end
            
    end


endmodule




module ray_feeder(
    input clk,
    input reset,
    input  ray_done,
    input  ray_fed,
    output reg switchState

);
    reg prev_ray_done;
    always @(posedge clk) begin
        prev_ray_done <= ray_done;
        if(reset) 
            switchState <= 1;
        else begin
            switchState <= 0;       // default
            if(ray_done && !prev_ray_done)
                switchState <= 1;   // 1-cycle pulse for FSM
            if(ray_fed)
                switchState <= 1;   // 1-cycle pulse for FSM
        end
    end

endmodule

//switchState <= !prev_ray_done & ray_done | !prev_ray_fed & ray_fed;   

//MAP 







/*
    reg[11:0] roundUp = 12'b100000000000;
    reg[3:0] counter = 11;
    always @(posedge clk) begin
        if(fsm_state == 2'b10) begin
            if((xPos & roundUp))begin
                roundUp => 12'b100000000000;//reset
                counter => 11;              //reset
            end
            else begin
                roundUp <= roundUp >> 1;

                counter <= counter - 1;
            end
        end
    end
*/