/*
module UART_FIFO (
    input clk_100MHz, clk_Button, reset,
    input [7:0] DATA,
    input write_enable, read_enable,
    output reg [31:0] read_data,
    output empty, full
    );

	reg [7:0] memory [15:0];
	reg [3:0] write_pointer, read_pointer;
	wire [7:0] count;
	reg [7:0] write_count, read_count;
		
	always @(posedge clk_100MHz or posedge reset) begin
		if (reset) begin
         write_pointer <= 0;
			write_count <= 0;
      end else begin
			if (write_enable && ~full) begin
				memory[write_pointer] <= DATA;
				write_pointer <= write_pointer + 1;
				write_count <= write_count + 1;
			end else begin
				write_count <= write_count;
				write_pointer <= write_pointer;
			end
		end
	end	
	
	always @(posedge clk_Button or posedge reset) begin
		if (reset) begin
			read_pointer <= 0;
			read_count <= 0;
		end else begin
			if (read_enable && ~empty) begin
				case (count) 
					7'd1: begin
						read_data <= {memory[read_pointer], 24'hFFFFFF};
						read_pointer <= read_pointer + 1;
						read_count <= read_count + 1;	
						end
					7'd2: begin
						read_data <= {memory[read_pointer], memory[read_pointer+1], 16'hFFFF};
						read_pointer <= read_pointer + 2;
						read_count <= read_count + 2;	
						end
					7'd3: begin
						read_data <= {memory[read_pointer], memory[read_pointer+1], memory[read_pointer+2], 8'hFF};
						read_pointer <= read_pointer + 3;
						read_count <= read_count + 3;	
						end
					default: begin
						read_data <= {memory[read_pointer], memory[read_pointer+1], memory[read_pointer+2], memory[read_pointer+3]};
						read_pointer <= read_pointer + 4;
						read_count <= read_count + 4;
						end
				 endcase
			end else if (empty) begin
				read_data <= 32'hFFFFFFFF;
			end else begin
				read_pointer <= read_pointer;
				read_count <= read_count;
			end		
		end
	end

	assign count = write_count - read_count;
	assign full = count == 16;
	assign empty = count == 0;
	
endmodule
*/

module UART_FIFO #(parameter WIDTH=32, parameter BUFFER_SIZE = 16)(
	input clk_100MHz, clk_Button, reset,
	input [7:0] DATA,
	input write_enable, read_enable,
	//output reg [WIDTH-1:0] read_data,
	output wire [WIDTH-1:0] outputData,
	output empty, full
	);

	reg [7:0] memory [15:0];
	reg [3:0] write_pointer, read_pointer;
	wire [7:0] count;
	reg [7:0] write_count, read_count;
	integer kk;
	always @(posedge clk_100MHz) begin
		if (reset) begin
			write_pointer <= 0;
			write_count <= 0;
			for (kk = 0; kk < 16; kk = kk + 1) begin
			     memory[kk] <= 0;
			end
		end else begin
			if (write_enable && ~full) begin
				memory[write_pointer] <= DATA;
				write_pointer <= write_pointer + 1;
				write_count <= write_count + 1;
			end else begin
				write_count <= write_count;
				write_pointer <= write_pointer;
			end
		end
	end	
	
	always @(posedge clk_Button) begin
		if (reset) begin
			read_pointer <= 0;
			read_count <= 0;
		end else begin
			if (read_enable && ~empty) begin
				case (count) 
					8'd1: begin
						//read_data <= {memory[read_pointer], 24'hFFFFFF};
						read_pointer <= read_pointer + 1;
						read_count <= read_count + 1;	
						end
					8'd2: begin
						//read_data <= {memory[read_pointer], memory[read_pointer+1], 16'hFFFF};
						read_pointer <= read_pointer + 2;
						read_count <= read_count + 2;	
						end
					8'd3: begin
						//read_data <= {memory[read_pointer], memory[read_pointer+1], memory[read_pointer+2], 8'hFF};
						read_pointer <= read_pointer + 3;
						read_count <= read_count + 3;	
						end
					default: begin
						//read_data <= {memory[read_pointer], memory[read_pointer+1], memory[read_pointer+2], memory[read_pointer+3]};
						read_pointer <= read_pointer + 4;
						read_count <= read_count + 4;
						end
				 endcase
			end else begin
				read_pointer <= read_pointer;
				read_count <= read_count;
			end		
		end
	end

wire [1:0] selectWord;
wire enableSelect;
wire [WIDTH-1:0] preSelectedData, selectedData;//, outputData;

assign selectWord = count[1:0];
assign enableSelect = ((~empty) && (|count[7:2])) ? 1'b1 : 1'b0;

MUX_4to1 #(.WIDTH(WIDTH)) mux_store (
    .SEL(selectWord),
    .DATA0({32'hFFFFFFFF}),
    .DATA3({memory[read_pointer], memory[read_pointer+1], memory[read_pointer+2], 8'hFF}),
    .DATA2({memory[read_pointer], memory[read_pointer+1], 16'hFFFF}),
    .DATA1({memory[read_pointer], 24'hFFFFFF}),
    .DATA_OUT(preSelectedData)
);

MUX_2to1 #(.WIDTH(WIDTH)) mux_select (
	.DATA0(preSelectedData),
	.DATA1({memory[read_pointer], memory[read_pointer+1], memory[read_pointer+2], memory[read_pointer+3]}),
	.SEL(enableSelect),
	.DATA_OUT(selectedData)
);

assign outputData = (read_enable) ? selectedData : 32'hFFFFFFFF;

	assign count = write_count + $unsigned(~read_count) +  1'b1;
	assign full  = (count >= 8'd16) ? 1'b1 : 1'b0;
	assign empty = (count == 8'd0 ) ? 1'b1 : 1'b0;
	
endmodule