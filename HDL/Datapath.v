module Datapath #(parameter WIDTH = 32) (
    input clk, reset,
    input [4:0] Debug_Source, 
    output [WIDTH-1:0] Debug_Out, Debug_PC,
	
	// ------ NEW -------- //

	output [WIDTH-1:0] INSTRUCTION,
	output ZeroBit, CMPBit,

	input [2:0] ImmSrc,
	input ALUSrcA, ALUSrcB,
	input [2:0] ALUControl,
	input [1:0] StoreSrc,
	input LoadByte, LoadSign,
	input [1:0] ResultSrc,
	input RegWrite, MemWrite,
	input PCSrc, Link,
	input isSLT, isU,
    
    // ----- UART CHANGE ----- //
    // ------ UART ------- //
    output wire [WIDTH-1:0] MEMORY_ADDR,

    // ----- UART TX ----- //
    // FOR sb to 0x0000_0404 (Uart Address)
    //output wire [7:0] UART_TRANSMIT_DATA,

    // ----- UART RX ----- //
    // FOR lw tfromo 0x0000_0404 (Uart Address)
    //input [WIDTH-1:0] UART_RECEIVE_DATA,
    input SELECT_UART,
    // ----- UART CHANGE ----- //
    
    // UART INTEGRATE
    input clk_100MHz,
    input WRITE_TO_UART,
    output TX_to_OUTSIDE, 
    input RX_from_OUTSIDE
);

wire [7:0] UART_TRANSMIT_DATA;
wire [WIDTH-1:0] UART_RECEIVE_DATA;

UART_Peripheral Uart_inst (
    .clk_100MHz(clk_100MHz),
	.clk_Button(clk),
	.reset(reset),
	.TX_Start(WRITE_TO_UART),
	.TX_DATA(UART_TRANSMIT_DATA),
	.Read_Access(SELECT_UART),
	.FIFO_OUT(UART_RECEIVE_DATA),
	.RX_Serial(RX_from_OUTSIDE),
	.TX_Serial(TX_to_OUTSIDE)
);

// ----- UART CHANGE ----- //
assign MEMORY_ADDR = ALUResult;
assign UART_TRANSMIT_DATA = WriteData[7:0];
// ----- UART CHANGE ----- //


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

Adder #(.WIDTH(WIDTH)) adder_PCPlus4 (
    .DATA1(PC),
    .DATA2(32'd4),
    .DATA_OUT(PCPlus4)
);

Adder #(.WIDTH(WIDTH)) adder_PCTarget (
    .DATA1(PC),
    .DATA2(ImmExt),
    .DATA_OUT(PCTarget)
);

// PC MUX
MUX_2to1 #(.WIDTH(WIDTH)) mux_PC (
    .DATA0(PCPlus4),
    .DATA1(Result),
    .SEL(PCSrc),
    .DATA_OUT(PCNext)
);

// INSTRUCTION MEMORY
Memory_INST mem_inst (
    .ADDR(PC),
    .RD(INSTRUCTION)
);

// INSTRUCTION DECODE
wire [4:0] Rs1, Rs2, Rd;

assign Rs1 = INSTRUCTION[19:15];
assign Rs2 = INSTRUCTION[24:20];
assign Rd = INSTRUCTION[11:7];

wire [4:0] Ra1;

// RS1 MUX
MUX_2to1 #(.WIDTH(5)) mux_RS1 (
    .DATA0(Rs1),
    .DATA1({(5){1'b0}}),
    .SEL(ALUSrcA),
    .DATA_OUT(Ra1)
);

// WD MUX
MUX_2to1 #(.WIDTH(WIDTH)) mux_WD (
    .DATA0(Result),
    .DATA1(PCPlus4),
    .SEL(Link),
    .DATA_OUT(WD)
);

// Register File
wire [WIDTH-1:0] RD1, RD2, WD;

Register_File #(.WIDTH(WIDTH)) register_file (
    .clk(clk),
    .WE(RegWrite),
    .reset(reset),
    .Rs1(Ra1),
    .Rs2(Rs2),
    .Rd(Rd),
    .WD(WD),
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
    .ImmExt(ImmExt)
);

// ALU MUX
wire [WIDTH-1:0] SrcA, SrcB;

assign SrcA = RD1;

MUX_2to1 #(.WIDTH(WIDTH)) mux_SrcB (
    .DATA0(RD2),
    .DATA1(ImmExt),
    .SEL(ALUSrcB),
    .DATA_OUT(SrcB)
);

// ALU
wire [WIDTH-1:0] ALUResult;

ALU #(.WIDTH(WIDTH)) alu (
    .SrcA(SrcA),
    .SrcB(SrcB),
    .ALUControl(ALUControl),
	.isSLT(isSLT), .isU(isU),
    .ALUResult(ALUResult),
    .Zero(ZeroBit)
);
assign CMPBit = ALUResult[0];

// Data Memory
wire [WIDTH-1:0] ReadData, WriteData;

Memory_DATA mem_data (
    .clk(clk),
    .MemWrite(MemWrite),
    .ADDR(ALUResult),
    .WD(WriteData),
    .RD(ReadData)
);

MUX_4to1 #(.WIDTH(WIDTH)) mux_store (
    .SEL(StoreSrc),
    .DATA0(RD2),
    .DATA1(RD2),
    .DATA2({ReadData[31:8], RD2[7:0]}),
    .DATA3({ReadData[31:16], RD2[15:0]}),
    .DATA_OUT(WriteData)
);


// RF WriteData MUX
wire [WIDTH-1:0] Result, ExtendedMemory, AfterPCSelect;

Extender_Load extender_load (
    .isSigned(LoadSign),
    .isByte(LoadByte),
    .INPUT(ReadData),
    .OUTPUT(ExtendedMemory)
);

// ----- UART CHANGE ----- //
wire [WIDTH-1:0] ValidReadData;
// UART RECEIVE WORD MUX
MUX_2to1 #(.WIDTH(WIDTH)) mux_UART (
    .DATA0(ReadData),
    .DATA1(UART_RECEIVE_DATA),
    .SEL(SELECT_UART),
    .DATA_OUT(ValidReadData)
);
// ----- UART CHANGE ----- //

MUX_4to1 #(.WIDTH(WIDTH)) mux_WriteData (
    .DATA0(ALUResult),
	.DATA1(PCTarget),
    .DATA2(ValidReadData),//.DATA2(ReadData), // ----- UART CHANGE ----- //
    .DATA3(ExtendedMemory),
    .SEL(ResultSrc),
    .DATA_OUT(Result)
);


endmodule