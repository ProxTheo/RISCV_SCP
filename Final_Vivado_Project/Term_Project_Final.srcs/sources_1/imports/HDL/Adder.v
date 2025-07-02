module Adder #(parameter WIDTH = 32) (
	input [WIDTH-1:0] DATA1, DATA2,
	output [WIDTH-1:0] DATA_OUT
);

assign DATA_OUT = DATA1 + DATA2;

endmodule