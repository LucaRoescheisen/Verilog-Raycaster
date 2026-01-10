

module spi_master (
    input CS,           //IO10
    input MOSI,         //IO11
    input SCK,           //IO13
    
    output reg[7:0] temp_data,
    output reg received_data
);



   // output reg[15:0] column_buffer [640]

    reg[2:0] addr_ptr = 0;
        //We want to process data on posedge of received data


always @(posedge SCK or posedge CS) begin 
    if(CS == 1) begin 
        addr_ptr <= 0;
        temp_data <= 0;
        received_data <= 0;
    end
    else begin
        temp_data[addr_ptr] <= MOSI;    //LSB to MSB

        if(addr_ptr == 7) begin
            received_data <= 1'b1;
        end

        addr_ptr <= addr_ptr + 1'b1;
    end


end


endmodule