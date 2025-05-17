module ALU #(parameter WIDTH = 32) (
	input [WIDTH-1:0] SrcA, SrcB,
	input [2:0] ALUControl,
	input isSLT, isU,
	output [WIDTH-1:0] ALUResult,
	output Zero
	);
	
	reg [WIDTH-1:0] ASLUResult, SLTResult;

	/// ASLU (Arithmetic Shift Logic Unit)
	always @(*) begin
		case(ALUControl)
			3'b000: ASLUResult <= SrcA + SrcB;  				/// ADD
			3'b001: ASLUResult <= SrcA - SrcB;					/// SUB
			3'b010: ASLUResult <= SrcA & SrcB;					/// AND
			3'b011: ASLUResult <= SrcA | SrcB;					/// OR
			3'b100: ASLUResult <= SrcA ^ SrcB;					/// XOR
			3'b001: ASLUResult <= SrcA << SrcB;					/// LSL
			3'b110: ASLUResult <= SrcA >> SrcB;					/// LSR
			3'b111: ASLUResult <= SrcA >>> SrcB;				/// ASR
			default: ASLUResult <= {(WIDTH)(1'b0)};							
		endcase
	end


	/// SLT Unit
	always @(*) begin	
		if (isU) begin
			SLTResult = {(WIDTH-1){1'b0}, ($unsigned(SrcA) < $unsigned(SrcB))};
		end else begin
			SLTResult = {(WIDTH-1){1'b0}, ($signed(SrcA) < $signed(SrcB))};
		end
	end

	assign ALUResult = isSLT ? SLTResult : ASLUResult; 

	assign Zero = ~|ALUResult; 

endmodule	
	
	
 