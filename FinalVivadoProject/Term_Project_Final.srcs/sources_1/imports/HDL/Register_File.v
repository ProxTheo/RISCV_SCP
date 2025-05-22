module Register_File #(parameter WIDTH = 32) (
	input clk, WE, reset,
	input [4:0] Rs1, Rs2, Rd, Debug_Source,
	input [WIDTH-1:0] WD,
	output [WIDTH-1:0] RD1, RD2, Debug_Out
);

wire [WIDTH-1:0] Reg_Out [31:0];
wire [WIDTH-1:0] Enable_Wires;

Decoder_5to32 decoder(
	.input_value(Rd),
	.output_value(Enable_Wires)
	);

genvar i;
generate
	for (i = 1; i < 32; i = i + 1) begin : generate_Register
		Register_rsten #(.WIDTH(WIDTH)) Reg_Inst (
			.clk(clk),
			.reset(reset),
			.WE(WE && Enable_Wires[i]),
			.DATA(WD),
			.DATA_OUT(Reg_Out[i])
			);
	end
endgenerate

assign Reg_Out[0] = {WIDTH{1'b0}};

assign RD1 = Reg_Out[Rs1];
assign RD2 = Reg_Out[Rs2];
assign Debug_Out = Reg_Out[Debug_Source];

//assign RD1 = (Rs1 == 0) ? {WIDTH{1'b0}} : Reg_Out[Rs1];
//assign RD2 = (Rs2 == 0) ? {WIDTH{1'b0}} : Reg_Out[Rs2];
//assign Debug_Out = (Rs2 == 0) ? {WIDTH{1'b0}} : Reg_Out[Debug_Source];

endmodule