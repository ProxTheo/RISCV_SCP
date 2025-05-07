module ALU #(parameter WIDTH = 32) (
	input [WIDTH-1:0] SrcA, SrcB,
	input [2:0] ALUControl,
	output reg [WIDTH-1:0] ALUResult,
	output Zero
	);
	
	always @(*) begin
		case(ALUControl)
			3'b000: ALUResult <= SrcA + SrcB;  								/// ADD
			3'b001: ALUResult <= SrcA - SrcB;								/// SUB
			3'b010: ALUResult <= SrcA & SrcB;								/// AND
			3'b011: ALUResult <= SrcA | SrcB;								/// OR
			3'b101: ALUResult <= {{(WIDTH-1){1'b0}}, {SrcA < SrcB}};	/// SLT
			default: ALUResult <= SrcA;
		endcase
	end

	assign Zero = ~|ALUResult; 

endmodule	
	
	
 