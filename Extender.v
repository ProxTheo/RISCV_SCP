module Extender (
	input [31:0] INSTRUCTION, 
	input [1:0] ImmSrc,
	output reg [31:0] ImmExt
);
    
	always @(*) begin
		case(ImmSrc)
			2'b00: ImmExt = {{20{INSTRUCTION[31]}}, INSTRUCTION[31:20]};											// I
			2'b01: ImmExt = {{20{INSTRUCTION[31]}}, INSTRUCTION[31:25], INSTRUCTION[11:7]};							// S
			2'b10: ImmExt = {{20{INSTRUCTION[31]}}, INSTRUCTION[7], INSTRUCTION[30:25], INSTRUCTION[11:8], 1'b0};	// B
			2'b11: ImmExt = {{12{INSTRUCTION[31]}}, INSTRUCTION[19:12], INSTRUCTION[20], INSTRUCTION[30:21], 1'b0};	// J
		endcase    
	end    
endmodule