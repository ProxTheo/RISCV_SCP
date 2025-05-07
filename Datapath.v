module Datapath #(parameter WIDTH = 32) (
    input clk, reset,
    input [4:0] Debug_Source, 
    input RegWrite, MemWrite, PCSrc, ALUSrc,
    input [1:0] ImmSrc, ResultSrc,
    input [2:0] ALUControl,
    output [WIDTH-1:0] Debug_Out, Debug_PC, INSTRUCTION,
    output Zero
);

// PC Register
wire [WIDTH-1:0] PCNext, PC;
assign Debug_PC = PC;

Register_reset reg_PC (
    .clk(clk),
    .reset(reset),
    .DATA(PCNext),
    .DATA_OUT(PC)
);

// PC Adders
wire [WIDTH-1:0] PCPlus4, PCTarget;

Adder adder_PCPlus4 (
    .DATA1(PC),
    .DATA2(32'd4),
    .DATA_OUT(PCPlus4)
);

Adder adder_PCTarget (
    .DATA1(PC),
    .DATA2(ImmExt),
    .DATA_OUT(PCTarget)
);

// PC MUX
MUX_2to1 mux_PC (
    .DATA0(PCPlus4),
    .DATA1(PCTarget),
    .SEL(PCSrc),
    .DATA_OUT(PCNext)
);

// INSTRUCTION MEMORY
wire [WIDTH-1:0] INSTRUCTION;

Memory_INST mem_inst (
    .ADDR(PC),
    .RD(INSTRUCTION)
);

// INSTRUCTION DECODE
wire [4:0] Rs1, Rs2, Rd;

assign Rs1 = INSTRUCTION[19:15];
assign Rs2 = INSTRUCTION[24:20];
assign Rd = INSTRUCTION[11:7];


// Register File
wire [WIDTH-1:0] RD1, RD2;

Register_File register_file (
    .clk(clk),
    .WE(RegWrite),
    .reset(reset)
    .Rs1(Rs1),
    .Rs2(Rs2),
    .Rd(Rd),
    .WD(Result),
    .RD1(RD1),
    .RD2(RD2),
    .Debug_Source(Debug_Source),
    .Debug_Out(Debug_Out)
);

// Extender
wire [WIDTH-1:0] ImmExt;

Extender extender (
    .INSTRUCTION(INSTRUCTION),
    .ImmSrc(ImmSrc),
    .ImmExt(ImmExt),
);

// ALU MUX
wire [WIDTH-1:0] SrcA, SrcB, WriteData;

assign SrcA = RD1;
assign WriteData = RD2;

MUX_2to1 mux_SrcB (
    .DATA0(RD2),
    .DATA1(ImmExt),
    .SEL(ALUSrc),
    .DATA_OUT(SrcB)
);

// ALU
wire [WIDTH-1:0] ALUResult;

ALU alu (
    .SrcA(SrcA),
    .SrcB(SrcB),
    .ALUControl(ALUControl),
    .ALUResult(ALUResult),
    .Zero(Zero)
);

// Data Memory
wire [WIDTH-1:0] ReadData;

Memory_DATA mem_data (
    .clk(clk),
    .MemWrite(MemWrite),
    .ADDR(ALUResult),
    .WD(WriteData),
    .RD(ReadData)
);

// RF WriteData MUX
wire [WIDTH-1:0] Result;

MUX_4to1 mux_WriteData (
    .DATA0(ALUResult),
    .DATA1(ReadData),
    .DATA2(PCPlus4),
    .DATA3(32'd0)
    .SEL(ResultSrc),
    .DATA_OUT(Result)
);


endmodule