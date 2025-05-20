module Controller #(parameter WIDTH = 32)
(
input [WIDTH-1:0] INSTRUCTION,
input ZeroBit, CMPBit,

output reg [2:0] ImmSrc,
output reg ALUSrcA, ALUSrcB,
output reg [2:0] ALUControl,
output reg [1:0] StoreSrc,
output reg LoadByte, LoadSign,
output reg [1:0] ResultSrc,
output reg RegWrite, MemWrite,
output reg PCSrc, Link,
output reg isSLT, isU,

// ----- UART CHANGE ----- //
// ------ UART ------- //
input [WIDTH-1:0] MEMORY_ADDR,

// ----- UART TX ----- //
// FOR sb to 0x0000_0400 (Uart Address)
output reg WRITE_TO_UART,

// ----- UART RX ----- //
// FOR lw tfromo 0x0000_0404 (Uart Address)
output reg SELECT_UART
// ----- UART CHANGE ----- //
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

//localparam 
//	OP_MEM 		= 3'b000,
//	OP_ALU 		= 3'b100,
//	OP_AUIPC 	= 3'b101,
//	OP_LUI 		= 3'b101,
//	OP_JLR 		= 3'b001,
//	OP_JLI 		= 3'b011,
//	OP_BR		= 3'b000;
//
//localparam
//	OP_BType = 2'b11,
//	OP_RType = 2'b01,
//	OP_IType = 2'b00;
//
//localparam 
//	ALU_RESULT 	= 2'b00,
//	PC_TARGET 	= 2'b01,
//	MEMORY_READ = 2'b11,
//	MEMORY_EXT 	= 2'b10;
//	
	
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

//wire RType, IType, BType, SType, UType;
//wire AUIPC, LUI;
//
//
//assign SType = ~opcode[6] && opcode[5];
//assign RType = ~opcode[6] && opcode[5];
//assign IType = ~opcode[6] && ~opcode[5];
//assign BType = opcode[6] && opcode[5];
//assign AUIPC = opcode[6:2] == 5'b00101;
//assign LUI = opcode[6:2] == 5'b01101;
//assign UType = AUIPC && LUI;


//assign isSLT = (opcode[4:0] == 5'b10011) && ((funct3 == 3'b010) || (funct3 == 3'b011));
//assign isU = (opcode[4:0] == 5'b10011);

// ALU COND CHECK

wire EQ, NEQ, LT, NLT, LTU, NLTU;

/*

begin 
	ImmSrc 			= DECODE OPCODE
	
	ALUSrcA			= UType ? HIGH : LOW;
	ALUSrcB			= (BType || RType) ? LOW : HIGH;
	ALUControl		= IF (ALU R/I) -> DECODE FUNCT3
					  IF (BTYPE)   -> SUB
					  ELSE		   -> ADD
	
	isSLT 			= IF (ALU R/I) -> DECODE FUNCT3
					  IF (BTYPE)   -> HIGH
					  ELSE		   -> LOW
					  
	isU				= IF (ALU R/I) -> DECODE FUNCT3
					  IF (BTYPE)   -> HIGH
					  ELSE		   -> LOW
	
	StoreSrc		= DECODE FUNCT3;

	SELECT_UART 	= IF (LW && EA = 0x404) -> HIGH	// UART READ
					  ELSE 					-> LOW; // NO UART READ
	WRITE_TO_UART 	= IF (SB && EA = 0x400) -> HIGH	// UART WRITE
					  ELSE 					-> LOW; // NO UART WRITE
	
	LoadByte = ~funct3[0];		// Byte/Half
	LoadSign = ~funct3[2];		// Sign/Zero

	ResultSrc[1] = (LOAD) ? HIGH : LOW;	
	ResultSrc[0] = IF (LOAD) 					-> funct3[1]
				   IF (AUIPC || BTYPE || JTYPE) -> HIGH
				   ELSE 						-> LOW
	
	
	
	RegWrite		= (SType || BRANCH) ? LOW : HIGH;
	MemWrite		= (SType) ? HIGH : LOW;	
	
	PCSrc			= IF (BTYPE) 							-> DECODE FUNCT3
					  IF (JUMP LINK OR JUMP LINK REGISTER) 	-> HIGH
					  ELSE 								   	-> LOW
					  
	Link			= (JUMP LINK OR JUMP LINK REGISTER) ? HIGH : LOW
end

*/

// ------ UART CHANGE ----- //
// UART ADDRESS CHECK
wire UART_ADDR_MATCH_404;
assign UART_ADDR_MATCH_404 = (MEMORY_ADDR == 32'h0000_0404) ? HIGH : LOW;
wire UART_ADDR_MATCH_400;
assign UART_ADDR_MATCH_400 = (MEMORY_ADDR == 32'h0000_0400) ? HIGH : LOW;
// ------ UART CHANGE ----- //

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

			SELECT_UART 	= funct3[1] && UART_ADDR_MATCH_404; // UART READ
			WRITE_TO_UART 	= LOW; 		// NO UART WRITE

			LoadByte = ~funct3[0];		// Byte/Half
			LoadSign = ~funct3[2];		// Sign/Zero

			ResultSrc[1] = HIGH; 		// MEM
			ResultSrc[0] = ~funct3[1]; 	// RESULT <- MEM_RD/MEM_EXT
			
			RegWrite		= HIGH;		// REG WRITE
			MemWrite		= LOW;		// NO MEM WRITE
			
			PCSrc			= LOW; 		// PC <- PC + 4
			Link			= LOW;		// NO
		end
		5'd4	: begin //ALU IMM
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
			
			isSLT 	= (funct3[2:1] == 2'b01) ? HIGH : LOW;	// SLT
			isU		= (funct3 == 3'b011) ? HIGH : LOW;	// UNS
			
			StoreSrc		= RS_WORD; 	// NA

			SELECT_UART 	= LOW; 		// NO UART READ
			WRITE_TO_UART 	= LOW; 		// NO UART WRITE

			LoadByte = LOW;				// NA
			LoadSign = LOW;				// NA

			ResultSrc[1] = LOW; 		// NOT MEM
			ResultSrc[0] = LOW;			// RESULT <- ALU
			
			RegWrite		= HIGH;		// REG WRITE
			MemWrite		= LOW;		// NO MEM WRITE
			
			PCSrc			= LOW; 		// PC <- PC + 4
			Link			= LOW;		// NO
		end
		5'd25	: begin //JUMP LINK REGISTER
			ImmSrc 			= 3'b000; 	// imm
			
			ALUSrcA			= LOW;		// rs1
			ALUSrcB			= HIGH;		// ImmExt
			ALUControl		= ADD;		// ALU <- rs1 + ImmExt
			
			isSLT 			= LOW;		// NO SLT
			isU				= LOW;		// NO UNS
			
			StoreSrc		= RS_WORD; 	// NA

			SELECT_UART 	= LOW; 		// NO UART READ
			WRITE_TO_UART 	= LOW; 		// NO UART WRITE

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
		5'd5	: begin //AUIPC
			ImmSrc 			= 3'b100; 	// imm
			
			ALUSrcA			= HIGH;		// NA
			ALUSrcB			= HIGH;		// NA
			ALUControl		= ADD;		// NA
			
			isSLT 			= LOW;		// NO SLT
			isU				= LOW;		// NO UNS
			
			StoreSrc		= RS_WORD; 	// NA

			SELECT_UART 	= LOW; 		// NO UART READ
			WRITE_TO_UART 	= LOW; 		// NO UART WRITE
			
			LoadByte = LOW;				// NA
			LoadSign = LOW;				// NA

			ResultSrc[1] = LOW; 		// NOT MEM
			ResultSrc[0] = HIGH;		// RESULT <- PC_TARGET
			
			RegWrite		= HIGH;		// REG WRITE
			MemWrite		= LOW;		// NO MEM WRITE
			
			PCSrc			= LOW; 		// PC <- PC + 4
			Link			= LOW;		// NO
		end
		5'd13	: begin //LUI
			ImmSrc 			= 3'b100; 	// imm
			
			ALUSrcA			= HIGH;		// ZERO
			ALUSrcB			= HIGH;		// ImmExt
			ALUControl		= ADD;		// ALU <- ImmExt
			
			isSLT 			= LOW;		// NO SLT
			isU				= LOW;		// NO UNS
			
			StoreSrc		= RS_WORD; 	// NA

			SELECT_UART 	= LOW; 		// NO UART READ
			WRITE_TO_UART 	= LOW; 		// NO UART WRITE
			
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
		5'd8	: begin //STORE
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

			SELECT_UART 	= LOW; 		// NO UART READ
			WRITE_TO_UART 	= (funct3 == 3'b000) ? UART_ADDR_MATCH_400 : LOW; // UART WRITE

			LoadByte = LOW;				// NA
			LoadSign = LOW;				// NA

			ResultSrc[1] = LOW; 		// NA
			ResultSrc[0] = LOW;			// NA
			
			RegWrite		= LOW;		// NO
			MemWrite		= ~WRITE_TO_UART;	// MEM WRITE IF NOT UART WRITE
			
			PCSrc			= LOW; 		// PC <- PC + 4
			Link			= LOW;		// NO
		end
		
		// B
		5'd24	: begin //BRANCH
			ImmSrc 			= 3'b010; 	// imm
			
			ALUSrcA			= LOW;		// rs1
			ALUSrcB			= LOW;		// rs2
			ALUControl		= SUB;		// ALU <- rs1 - rs2
			
			isSLT 	= ~((funct3 == BEQ) || (funct3 == BNE));	// SLT
			isU		= ((funct3 == BLTU) || (funct3 == BGEU));	// UNS
			
			StoreSrc		= RS_WORD; 	// NA

			SELECT_UART 	= LOW; 		// NO UART READ
			WRITE_TO_UART 	= LOW; 		// NO UART WRITE
			
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
				BGE : PCSrc	=   ~CMPBit; // rs1 >= rs2
				BLTU: PCSrc =   CMPBit; // rs1 <  rs2
				BGEU: PCSrc =   ~CMPBit; // rs1 >= rs2
				default: PCSrc = LOW; 	// UNDEFINED
			endcase

			Link			= LOW;		// NO
		end
		
		// J
		5'd27	: begin // JUMP LINK
			ImmSrc 			= 3'b011; 	// imm
			
			ALUSrcA			= LOW;		// rs1
			ALUSrcB			= HIGH;		// ImmExt
			ALUControl		= ADD;		// ALU <- rs1 + ImmExt
			
			isSLT 			= LOW;		// NO SLT
			isU				= LOW;		// NO UNS
			
			StoreSrc		= RS_WORD; 	// NA

			SELECT_UART 	= LOW; 		// NO UART READ
			WRITE_TO_UART 	= LOW; 		// NO UART WRITE
			
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
		5'd12	: begin //ALU REG
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
			
			isSLT 	= (funct3[2:1] == 2'b01) ? HIGH : LOW;	// SLT
			isU		= (funct3 == 3'b011) ? HIGH : LOW;	// UNS
			
			StoreSrc		= RS_WORD; 	// NA

			SELECT_UART 	= LOW; 		// NO UART READ
			WRITE_TO_UART 	= LOW; 		// NO UART WRITE
			
			LoadByte = LOW;				// NA
			LoadSign = LOW;				// NA

			ResultSrc[1] = LOW; 		// NOT MEM
			ResultSrc[0] = LOW;			// RESULT <- ALU
			
			RegWrite		= HIGH;		// REG WRITE
			MemWrite		= LOW;		// NO MEM WRITE
			
			PCSrc			= LOW; 		// PC <- PC + 4
			Link			= LOW;		// NO
		end

		default : begin //UNDEFINED
			ImmSrc 			= 3'b111; 	// imm
			
			ALUSrcA			= LOW;		// rs1
			ALUSrcB			= LOW;		// rs2
			ALUControl 		= ADD;		// UNDEFINED
			
			isSLT 			= LOW;		// SLT
			isU				= LOW;		// UNS
			
			StoreSrc		= RS_WORD; 	// NA

			SELECT_UART 	= LOW; 		// NO UART READ
			WRITE_TO_UART 	= LOW; 		// NO UART WRITE
			
			LoadByte 		= LOW;		// NA
			LoadSign 		= LOW;		// NA

			ResultSrc[1] 	= LOW; 		// NOT MEM
			ResultSrc[0] 	= LOW;		// RESULT <- ALU
			
			RegWrite		= LOW;		// NO REG WRITE
			MemWrite		= LOW;		// NO MEM WRITE
			
			PCSrc			= LOW; 		// PC <- PC + 4
			Link			= LOW;		// NO
		end
	endcase
end

endmodule