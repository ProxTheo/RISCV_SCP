module UART_RX #(parameter FREQ = 100000000, BAUDRATE = 9600) (
    input clk, reset,
    input RX_Serial,
    output reg [7:0] RX_OUT,
    output reg RX_Done
    );

    localparam DIV = FREQ / BAUDRATE;

    reg [13:0] baud_counter;
    reg [1:0] state;
    reg [3:0] index;
    reg [7:0] RX_SHIFT_REG;


    // FSM States
    localparam IDLE = 2'b00,
               START_BIT = 2'b01,
               DATA = 2'b10,
               STOP_BIT = 2'b11;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state = IDLE;
            RX_OUT <= 0;
            RX_Done <= 0;
            baud_counter <= 0;
            index = 0;
        end
        else begin
            case(state)

                IDLE: begin
                    if (RX_Serial == 1'b0) begin    
                        state <= START_BIT;
                        baud_counter <= DIV >> 1;
								RX_Done <= 0;
                    end 
                    else begin
                        state <= IDLE;
								RX_Done <= 0;
                    end
                end

                START_BIT: begin
                    if (baud_counter == 0) begin
                        if (RX_Serial == 1'b0) begin       // Check Stop Bit Validity 
                            state <= DATA;
                            baud_counter <= DIV - 1;
                            index <= 0;
									 RX_Done <= 0;
                        end 
                        else begin
                            state <= IDLE;
									 RX_Done <= 0;
                        end
                    end 
                    else begin
                        baud_counter <= baud_counter - 1;
								RX_Done <= 0;
                    end
                end

                DATA: begin
                    if (baud_counter == 0) begin
                        RX_SHIFT_REG[index] <= RX_Serial;  // 
                        index <= index + 1;
                        baud_counter <= DIV - 1;
                        if (index == 3'b111) begin
                            state <= STOP_BIT;
                        end
								RX_Done <= 0;
                    end
                    else begin
                        baud_counter <= baud_counter - 1;
								RX_Done <= 0;
                    end
                end

                STOP_BIT: begin

                    if(baud_counter == 0) begin
                        if (RX_Serial == 1'b1) begin
                            RX_OUT <= RX_SHIFT_REG;
                            RX_Done <= 1;
                        end
                        state <= IDLE;
                    end
                    else begin 
                        baud_counter <= baud_counter - 1;
								RX_Done <= 0;
                    end
                end
            endcase 
        end
    end
endmodule