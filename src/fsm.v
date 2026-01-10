//The Different States
// 00 : IDLE
// 01 : FEED RAY
// 10 : PROCESS RAY
// 11 : COMPLETED ALL RAYS



module fsm(
    input clk,
    input reset,
    input switchState,
    output wire [1:0] S //The Current state
    );
    reg [1:0] S_current, S_next;
    reg switchState_d;

    localparam  IDLE    = 2'b00,
                FEED    = 2'b01,
                PROCESS = 2'b10,
                DONE    = 2'b11;

    


    always @(posedge clk) begin
        if(reset) begin
            S_current <= 0;

        end
        else 
            S_current <= S_next;
    end

    

    always @(posedge clk) begin
        if(reset)
            switchState_d <= 0;
        else
            switchState_d <= switchState;
    end

    wire switchState_pulse = switchState & ~switchState_d;


    always @(*) begin
         S_next = S_current;
        case(S_current)
            IDLE    : S_next = switchState_pulse ? FEED    : IDLE;
            FEED    : S_next = switchState_pulse ? PROCESS : FEED;
            PROCESS : S_next = switchState_pulse ? FEED    : PROCESS;
            DONE    : S_next = switchState_pulse ? IDLE    : DONE;  //Currently ignoring this state

        endcase
    end

    assign S = S_current;

endmodule