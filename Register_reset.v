module Register_reset #(parameter WIDTH = 32) (
	input clk, reset,
	input [WIDTH-1:0] DATA,
	output reg [WIDTH-1:0] OUT
);

	always @(posedge clk) begin
		if (reset) begin
			OUT <= 0;
		end else begin
			OUT <= DATA;
		end
	end
	
endmodule 