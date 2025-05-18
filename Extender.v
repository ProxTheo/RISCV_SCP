module Extender (
	input [31:0] INSTRUCTION, 
	input [2:0] ImmSrc,
	output reg [31:0] ImmExt
);
    
	always @(*) begin
		case(ImmSrc)
			3'b000: ImmExt = {{20{INSTRUCTION[31]}}, INSTRUCTION[31:20]};												// I
			3'b001: ImmExt = {{20{INSTRUCTION[31]}}, INSTRUCTION[31:25], INSTRUCTION[11:7]};							// S
			3'b010: ImmExt = {{20{INSTRUCTION[31]}}, INSTRUCTION[7], INSTRUCTION[30:25], INSTRUCTION[11:8], 1'b0};		// B
			3'b011: ImmExt = {{12{INSTRUCTION[31]}}, INSTRUCTION[19:12], INSTRUCTION[20], INSTRUCTION[30:21], 1'b0};	// J
			3'b100: ImmExt = {20{INSTRUCTION[31:12]}, 12'b0};															// U
			default: ImmExt = 32'b0;
		endcase    
	end    
endmodule