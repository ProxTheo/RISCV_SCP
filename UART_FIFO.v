module UART_FIFO (
    input clk, reset,
    input [7:0] DATA,
    input write_enable, read_enable,
    output reg [7:0] read_data,
    output empty, full
    );

    reg [7:0] memory [15:0];
    reg [3:0] write_pointer, read_pointer, count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            write_pointer <= 0;
            read_pointer <= 0;
            read_data <= 0;
            count <= 0;
        end else begin 

            if (write_enable && ~full) begin
                memory[write_pointer] <= DATA;
                write_pointer <= write_pointer + 1;
                count <= count + 1;
            end

            if (read_enable && ~empty) begin
                read_data <= memory[read_pointer];
                read_pointer <= read_pointer + 1;
                count <= count - 1;
            end
        end
    end

    assign empty = (count== 0);
    assign full = (count == 15);

endmodule