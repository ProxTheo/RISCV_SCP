module Register_reset #(parameter WIDTH = 32) (
	input clk, reset,
	input [WIDTH-1:0] DATA,
	output reg [WIDTH-1:0] DATA_OUT
);

	always @(posedge clk) begin
		if (reset) begin
			DATA_OUT <= {WIDTH{1'b0}};
		end else begin
			DATA_OUT <= DATA;
		end
	end
	
endmodule 