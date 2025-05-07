module MUX_4to1 #(parameter WIDTH = 32) (
	input [WIDTH-1:0] DATA0, DATA1, DATA2, DATA3,
	input [1:0] SEL,
	output reg [WIDTH-1:0] OUT	
);
	
	always @(*) begin
		case (SEL) 
			2'b00: OUT <= DATA0;
			2'b01: OUT <= DATA1;
			2'b10: OUT <= DATA2;
			2'b11: OUT <= DATA3;
		endcase
	end
	
endmodule 