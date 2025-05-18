module Controller #(parameter WIDTH = 32)
(
input [WIDTH-1:0] INSTRUCTION,
input reset,

output RegWrite, MemWrite,
output PCSrc, link,
output ALUSrcA, ALUSrcB,
output [1:0] ResultSrc, MemWDSrc
output [2:0] ALUControl,
input ZeroBit, CMPBit, // USE IT IN REGWRITE
output [2:0] ImmSrc,
output [1:0] StoreSrc
output LoadByte, LoadSign
);

localparam ADD		= 3'b000;
localparam SUB		= 3'b001;
localparam AND		= 3'b010;
localparam ORR		= 3'b011;
localparam XOR		= 3'b100;
localparam LSL		= 3'b101;
localparam LSR		= 3'b110;
localparam ASR		= 3'b111;

localparam BEQ		= 3'b000;
localparam BNE		= 3'b001;
localparam BLT		= 3'b100;
localparam BGE		= 3'b101;
localparam BLTU		= 3'b110;
localparam BGEU		= 3'b111;

localparam 
	OP_MEM 		= 3'b000,
	OP_ALU 		= 3'b100,
	OP_AUIPC 	= 3'b101,
	OP_LUI 		= 3'b101,
	OP_JLR 		= 3'b001,
	OP_JLI 		= 3'b011,
	OP_BR		= 3'b000;

localparam
	OP_BType = 2'b11,
	OP_RType = 2'b01,
	OP_IType = 2'b00;

localparam 
	ALU_RESULT 	= 2'b00,
	PC_TARGET 	= 2'b01,
	MEMORY_READ = 2'b11,
	MEMORY_EXT 	= 2'b10;
	
	
localparam 
	RS_WORD = 2'b00,
	
	RS_BYTE = 2'b10,
	RS_HALF = 2'b11;
	
localparam LOW = 1'b0;
localparam HIGH= 1'b1;

wire [2:0] funct3;
wire [6:0] funct7, opcode;

assign funct3 = INSTRUCTION[14:12];
assign funct7 = INSTRUCTION[31:25];
assign opcode = INSTRUCTION[6:0];

wire RType, IType, BType, SType, UType;
wire AUIPC, LUI;


assign SType = ~opcode[6] && opcode[5];
assign RType = ~opcode[6] && opcode[5];
assign IType = ~opcode[6] && ~opcode[5];
assign BType = opcode[6] && opcode[5];
assign JType
assign AUIPC = opcode[6:2] == 5'b00101;
assign LUI = opcode[6:2] == 5'b01101;
assign UType = AUIPC && LUI;


assign isSLT = (opcode[4:0] == 5'b10011) && ((funct3 == 3'b010) || (funct3 == 3'b011));
assign isU = (opcode[4:0] == 5'b10011);

// ALU COND CHECK

wire EQ, NEQ, LT, NLT, LTU, NLTU;


/*

output [2:0] ImmSrc,

output ALUSrcA, ALUSrcB,
output [2:0] ALUControl,

output [1:0] StoreSrc,

output LoadByte, LoadSign,

output [1:0] ResultSrc,

output RegWrite, MemWrite,

output PCSrc, link,

output isSLT, isU,

input ZeroBit, CMPBit, // USE IT IN REGWRITE

*/



always @(*) begin
	case ({opcode[6:2]})
		// I
		5'd0	: begin //LOAD
			ImmSrc 			= 3'b000; 	// imm
			
			ALUSrcA			= LOW;		// rs1
			ALUSrcB			= HIGH;		// ImmExt
			ALUControl		= ADD;		// ALU <- rs1 + ImmExt
			
			isSLT 			= LOW;		// NO SLT
			isU				= LOW;		// NO UNS
			
			StoreSrc		= RS_WORD; 	// NA

			LoadByte = ~funct[0];		// Byte/Half
			LoadSign = ~funct[2];		// Sign/Zero

			ResultSrc[1] = HIGH; 		// MEM
			ResultSrc[0] = funct3[1] 	// RESULT <- MEM_RD/MEM_EXT
			
			RegWrite		= HIGH;		// REG WRITE
			MemWrite		= LOW;		// NO MEM WRITE
			
			PCSrc			= LOW; 		// PC <- PC + 4
			Link			= LOW;		// NO
		end
		5'd16	: begin //ALU IMM
			ImmSrc 			= 3'b000; 	// imm
			
			ALUSrcA			= LOW;		// rs1
			ALUSrcB			= HIGH;		// ImmExt
			case(funct3)
				3'b000: ALUControl = ADD;								///ADD
				3'b001: ALUControl = LSL;		                       	///LSL
				3'b010: ALUControl = SUB;                       		///SLT
				3'b011: ALUControl = SUB;                       		///SLTU
				3'b100: ALUControl = XOR;                       		///XOR
				3'b101: ALUControl = funct7[5] ? ASR : LSR;   			///SRA/SRL
				3'b110: ALUControl = ORR;                       		///OR
				3'b111: ALUControl = AND;                       		///AND
				default: ALUControl = ADD;								///UNDEFINED
			endcase
			
			isSLT 	= (funct3 == 3'b010) ? HIGH : LOW;	// SLT
			isU		= (funct3 == 3'b010) ? HIGH : LOW;	// UNS
			
			StoreSrc		= RS_WORD; 	// NA

			LoadByte = LOW;				// NA
			LoadSign = LOW;				// NA

			ResultSrc[1] = LOW; 		// NOT MEM
			ResultSrc[0] = LOW;			// RESULT <- ALU
			
			RegWrite		= HIGH;		// REG WRITE
			MemWrite		= LOW;		// NO MEM WRITE
			
			PCSrc			= LOW; 		// PC <- PC + 4
			Link			= LOW;		// NO
		end
		5'd100	: begin //JUMP LINK REGISTER
			ImmSrc 			= 3'b000; 	// imm
			
			ALUSrcA			= LOW;		// rs1
			ALUSrcB			= HIGH;		// ImmExt
			ALUControl		= ADD;		// ALU <- rs1 + ImmExt
			
			isSLT 			= LOW;		// NO SLT
			isU				= LOW;		// NO UNS
			
			StoreSrc		= RS_WORD; 	// NA

			LoadByte = LOW;				// NA
			LoadSign = LOW;				// NA

			ResultSrc[1] = LOW; 		// NOT MEM
			ResultSrc[0] = LOW;			// RESULT <- ALU
			
			RegWrite		= HIGH;		// REG WRITE
			MemWrite		= LOW;		// NO MEM WRITE
			
			PCSrc			= HIGH;		// PC <- RESULT
			Link			= HIGH;		// RD <- PC+4
		end
		
		// U
		5'd20	: begin //AUIPC
			ImmSrc 			= 3'b100; 	// imm
			
			ALUSrcA			= HIGH;		// NA
			ALUSrcB			= HIGH;		// NA
			ALUControl		= ADD;		// NA
			
			isSLT 			= LOW;		// NO SLT
			isU				= LOW;		// NO UNS
			
			StoreSrc		= RS_WORD; 	// NA

			LoadByte = LOW;				// NA
			LoadSign = LOW;				// NA

			ResultSrc[1] = LOW; 		// NOT MEM
			ResultSrc[0] = HIGH;		// RESULT <- PC_TARGET
			
			RegWrite		= HIGH;		// REG WRITE
			MemWrite		= LOW;		// NO MEM WRITE
			
			PCSrc			= LOW; 		// PC <- PC + 4
			Link			= LOW;		// NO
		end
		5'd52	: begin //LUI
			ImmSrc 			= 3'b100; 	// imm
			
			ALUSrcA			= HIGH;		// ZERO
			ALUSrcB			= HIGH;		// ImmExt
			ALUControl		= ADD;		// ALU <- ImmExt
			
			isSLT 			= LOW;		// NO SLT
			isU				= LOW;		// NO UNS
			
			StoreSrc		= RS_WORD; 	// NA

			LoadByte = LOW;				// NA
			LoadSign = LOW;				// NA

			ResultSrc[1] = LOW; 		// NOT MEM
			ResultSrc[0] = LOW;			// RESULT <- ALU_RESULT
			
			RegWrite		= HIGH;		// REG WRITE
			MemWrite		= LOW;		// NO MEM WRITE
			
			PCSrc			= LOW; 		// PC <- PC + 4
			Link			= LOW;		// NO
		end
		
		// S
		5'd32	: begin //STORE
			ImmSrc 			= 3'b001; 	// imm
			
			ALUSrcA			= LOW;		// rs1
			ALUSrcB			= HIGH;		// ImmExt
			ALUControl		= ADD;		// ALU <- rs1 + ImmExt
			
			isSLT 			= LOW;		// NO SLT
			isU				= LOW;		// NO UNS
			
			case(funct3)
				3'b000: StoreSrc 	= RS_BYTE; // Store Byte
				3'b001: StoreSrc 	= RS_HALF; // Store HalfWord
				3'b010: StoreSrc	= RS_WORD; // Store RWord
				default: StoreSrc 	= RS_WORD; // UNDEFINED
			endcase

			LoadByte = LOW;				// NA
			LoadSign = LOW;				// NA

			ResultSrc[1] = LOW; 		// NA
			ResultSrc[0] = LOW;			// NA
			
			RegWrite		= LOW;		// NO
			MemWrite		= HIGH;		// MEM WRITE
			
			PCSrc			= LOW; 		// PC <- PC + 4
			Link			= LOW;		// NO
		end
		
		// B
		5'd96	: begin //BRANCH
			ImmSrc 			= 3'b010; 	// imm
			
			ALUSrcA			= LOW;		// rs1
			ALUSrcB			= LOW;		// rs2
			ALUControl		= SUB;		// ALU <- rs1 - rs2
			
			isSLT 	= HIGH;	// SLT
			isU		= HIGH;	// UNS
			
			StoreSrc		= RS_WORD; 	// NA
			
			LoadByte = LOW;				// NA
			LoadSign = LOW;				// NA

			ResultSrc[1] = LOW; 		// ALU/PCT
			ResultSrc[0] = HIGH;		// RESULT <- PC_TARGET
			
			RegWrite		= LOW;		// NO
			MemWrite		= LOW;		// NO
			
			case (funct3)
				BEQ : PCSrc	=  ZeroBit; // rs1 == rs2
				BNE : PCSrc	= ~ZeroBit; // rs1 != rs2
				BLT : PCSrc	= 	CMPBit; // rs1 <  rs2
				BGE : PCSrc	=  ~CMPBit; // rs1 >= rs2
				BLTU: PCSrc =   CMPBit; // rs1 <  rs2
				BGEU: PCSrc =  ~CMPBit; // rs1 >= rs2
				default: PCSrc = LOW; 	// UNDEFINED
			endcase

			Link			= LOW;		// NO
		end
		
		// J
		5'd108	: begin // JUMP LINK
			ImmSrc 			= 3'b011; 	// imm
			
			ALUSrcA			= LOW;		// rs1
			ALUSrcB			= HIGH;		// ImmExt
			ALUControl		= ADD;		// ALU <- rs1 + ImmExt
			
			isSLT 			= LOW;		// NO SLT
			isU				= LOW;		// NO UNS
			
			StoreSrc		= RS_WORD; 	// NA

			LoadByte = LOW;				// NA
			LoadSign = LOW;				// NA
			
			ResultSrc[1] = LOW; 		// ALU/PCT
			ResultSrc[0] = HIGH;		// RESULT <- PC_TARGET
			
			RegWrite		= HIGH;		// REG WRITE
			MemWrite		= LOW;		// NO MEM WRITE
			
			PCSrc			= HIGH; 	// PC <- RESULT
			Link			= HIGH;		// RD <- PC+4
		end
		
		// R
		5'd48	: begin //ALU REG
			ImmSrc 			= 3'b111; 	// imm
			
			ALUSrcA			= LOW;		// rs1
			ALUSrcB			= LOW;		// rs2
			case(funct3)
				3'b000: ALUControl = funct7[5] ? SUB: ADD; 				///SUB/ADD
				3'b001: ALUControl = LSL;		                       	///LSL
				3'b010: ALUControl = SUB;                       		///SLT
				3'b011: ALUControl = SUB;                       		///SLTU
				3'b100: ALUControl = XOR;                       		///XOR
				3'b101: ALUControl = funct7[5] ? ASR : LSR;   			///SRA/SRL
				3'b110: ALUControl = ORR;                       		///OR
				3'b111: ALUControl = AND;                       		///AND
				default: ALUControl = ADD;								///UNDEFINED
			endcase
			
			isSLT 	= (funct3 == 3'b010) ? HIGH : LOW;	// SLT
			isU		= (funct3 == 3'b010) ? HIGH : LOW;	// UNS
			
			StoreSrc		= RS_WORD; 	// NA

			LoadByte = LOW;				// NA
			LoadSign = LOW;				// NA

			ResultSrc[1] = LOW; 		// NOT MEM
			ResultSrc[0] = LOW;			// RESULT <- ALU
			
			RegWrite		= HIGH;		// REG WRITE
			MemWrite		= LOW;		// NO MEM WRITE
			
			PCSrc			= LOW; 		// PC <- PC + 4
			Link			= LOW;		// NO
		end
		
		// UNDEFINED
		default : ImmSrc = 3'b111;
	endcase
end

assign