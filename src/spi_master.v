module spi_master (
    input clk,
    input CS,           //IO10
    input MOSI,         //IO11
    input SCK,           //IO13
    
    output reg[7:0] temp_data,
    output reg received_data
);



   // output reg[15:0] column_buffer [640]

    reg[2:0] addr_ptr = 0;
        //We want to process data on posedge of received data

    reg sck_sync0, sck_sync1;
    reg mosi_sync0, mosi_sync1;
    reg cs_sync0, cs_sync1;
    always @(posedge clk) begin
        sck_sync0 <= SCK;
        sck_sync1 <= sck_sync0;
        
        mosi_sync0 <= MOSI;
        mosi_sync1 <= mosi_sync0;
        
        cs_sync0   <= CS;
        cs_sync1   <= cs_sync0;
    end
    wire sck_rise = sck_sync0 & ~sck_sync1;

always @(posedge clk) begin 
    if(cs_sync1 == 1) begin 
        addr_ptr <= 7;
        temp_data <= 0;
        received_data <= 0;
    end
    else if (sck_rise) begin
        temp_data[addr_ptr] <= mosi_sync1;    //LSB to MSB
        if(addr_ptr ==  0) begin
            received_data <= 1'b1;
            addr_ptr <= 7;
        end
        else begin
            received_data <= 0;
            addr_ptr <= addr_ptr - 1'b1;
        end
    end
end




endmodule