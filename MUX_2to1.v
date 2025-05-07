module MUX_2to1 #(parameter WIDTH = 32) (
	input [WIDTH-1:0] DATA0, DATA1,
	input SEL,
	output reg [WIDTH-1:0] OUT	
);
	
	always @(*) begin
		if (SEL) begin
			OUT <= DATA1;
		end else begin
			OUT <= DATA0;
		end
	end
	
	
endmodule 