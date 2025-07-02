module Decoder_5to32 (
	input [4:0] input_value,
	output [31:0] output_value
);

	assign output_value = 32'd1 << input_value;

endmodule