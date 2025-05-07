module ALUController(
	input [2:0] funct3,
	input funct7, op,
	input [1:0] ALUOp,
	output reg [2:0] ALUControl
);

always @(*) begin
	case (ALUOp)
		2'b00: ALUControl <= 3'b000;  // ADD
		2'b01: ALUControl <= 3'b001;	// SUB
		2'b10: case (funct3) 
					3'b000: ALUControl <= ({op,funct7} == 2'b11) ? 3'b000 : 3'b001; /// ADD else SUB
					3'b010: ALUControl <= 3'b101; /// SLT
					3'b110: ALUControl <= 3'b011; /// OR
					3'b111: ALUControl <= 3'b010; /// AND
					default:ALUControl <= 3'b000;
				endcase
		default: ALUControl <= 3'b000; 
	endcase
end
	
	
endmodule