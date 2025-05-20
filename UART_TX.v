module UART_TX #(parameter FREQ = 100000000, BAUDRATE = 9600) (
    input clk, reset,
    input TX_Start,
    input [7:0] TX_DATA,
    output reg TX_Serial, TX_BUSY
    );

    localparam DIV = FREQ / BAUDRATE;

    reg [13:0] baud_counter;
    reg [4:0] index;
    reg [9:0] TX_SHIFT_REG;
    reg tick;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            baud_counter <= 0;
            index <= 0;
            TX_SHIFT_REG <= 0;
            TX_Serial <= 1'b1;
            TX_BUSY <= 0;
        end
        else begin
            if (TX_BUSY) begin
                if (baud_counter == DIV - 1) begin
                    baud_counter <= 0;
                    tick <= 1'b1;
                end 
                else begin
                    baud_counter <= baud_counter + 1;
                    tick <= 0;
                end

                if (tick) begin
                    TX_Serial <= TX_SHIFT_REG[0];
                    TX_SHIFT_REG <= {1'b1, TX_SHIFT_REG[9:1]};
                    index <= index + 1;
                    if (index == 9) begin
                        TX_BUSY <= 1'b0;
                    end
                end
            end
            else if (TX_Start) begin
                TX_SHIFT_REG <= {1'b1, TX_DATA, 1'b0};
                TX_BUSY <= 1'b1;
                index <= 0;
                baud_counter <= 0;
            end else begin
					TX_Serial <= 1'b1;
				end
        end 
				
    end
endmodule
