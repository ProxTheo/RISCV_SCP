module MUX_4to1 #(parameter WIDTH = 32) (
	input [WIDTH-1:0] DATA0, DATA1, DATA2, DATA3,
	input [1:0] SEL,
	output reg [WIDTH-1:0] DATA_OUT	
);
	
	always @(*) begin
		case (SEL) 
			2'b00: DATA_OUT <= DATA0;
			2'b01: DATA_OUT <= DATA1;
			2'b10: DATA_OUT <= DATA2;
			2'b11: DATA_OUT <= DATA3;
		endcase
	end
	
endmodule 