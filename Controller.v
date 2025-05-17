module Controller (
    input [31:0] INSTRUCTION,
    input reset, Zero,
    output RegWrite, MemWrite, ALUSrc,
    output [1:0] PCSrc, ImmSrc, ResultSrc,
    output [2:0] ALUControl
)

wire [2:0] funct3;
wire [6:0] funct7, opcode;

assign funct3 = INSTRUCTION[14:12];
assign funt7 = INSTRUCTION[31:25];
assign opcode = INSTRUCTION[6:0];

wire RType, IType, BType;

assign RType = ~opcode[6] & opcode[5];
assign IType = ~opcode[6] & ~opcode[5];
assign BType = opcode[6] & opcode[5];




assign 