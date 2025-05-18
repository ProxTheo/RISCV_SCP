module ALU #(parameter WIDTH = 32) (
input [WIDTH-1:0] SrcA, SrcB,
input [2:0] ALUControl,
input isSLT, isU,
output wire [WIDTH-1:0] ALUResult,
output wire Zero
);

localparam 
	ADD=3'b000,
	SUB=3'b001,
	AND=3'b010,
	ORR=3'b011,
	XOR=3'b100,
	LSL=3'b101,
	LSR=3'b110,
	ASR=3'b111;

localparam LOW = 1'b0;
localparam HIGH= 1'b1;

reg [WIDTH-1:0] ASLUResult, SLTResult;

reg CO,OVF;
wire N;//,Z;
wire [4:0] shamt;
assign shamt = SrcB[4:0];

assign N = ASLUResult[WIDTH-1];
//assign Z = ~(|ASLUResult);

/// ASLU (Arithmetic Shift Logic Unit)
always @(*) begin
	case(ALUControl)
		ADD:begin
			{CO,ASLUResult} = SrcA + SrcB;
			OVF = (SrcA[WIDTH-1] & SrcB[WIDTH-1] & ~ASLUResult[WIDTH-1]) | (~SrcA[WIDTH-1] & ~SrcB[WIDTH-1] & ASLUResult[WIDTH-1]);
		end
		SUB:begin
			{CO,ASLUResult} =  SrcA +  $unsigned(~SrcB) +  1'b1;
			OVF = (SrcA[WIDTH-1] & ~SrcB[WIDTH-1] & ~ASLUResult[WIDTH-1]) | (~SrcA[WIDTH-1] & SrcB[WIDTH-1] & ASLUResult[WIDTH-1]);
		end
		AND:begin
			ASLUResult = SrcA & SrcB;
			CO = 1'b0;
			OVF = 1'b0;
		end
		ORR:begin
			ASLUResult = SrcA | SrcB;
			CO = 1'b0;
			OVF = 1'b0;
		end
		XOR:begin
			ASLUResult = SrcA ^ SrcB;
			CO = 1'b0;
			OVF = 1'b0;
		end
		LSL:begin
			ASLUResult = SrcA << shamt;					/// LSL
			CO = LOW;
			OVF = LOW;
		end
		LSR:begin
			ASLUResult = SrcA >> shamt;					/// LSR
			CO = LOW;
			OVF = LOW;
		end
		ASR:begin
			ASLUResult = SrcA >>> shamt;					/// ASR
			CO = LOW;
			OVF = LOW;
		end
		default:begin
			ASLUResult = {(WIDTH){1'b0}};
			CO = LOW;
			OVF = LOW;
		end
	endcase
end


always @(*) begin
	if (isU) begin // UNSIGNED
		SLTResult = {{(WIDTH-1){1'b0}}, LTU};
	end
	else begin // SIGNED
		SLTResult = {{(WIDTH-1){1'b0}}, LT};
	end
end
/// SLT Unit
wire LT, LTU;

assign LT 	= N ^ OVF; 	// SIGNED LESS THAN
assign LTU 	= ~CO; 		// UNSIGNED LESS THAN


assign ALUResult = isSLT ? SLTResult : ASLUResult; 

assign Zero = ~(|ALUResult);

endmodule	
	
	
 