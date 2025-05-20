module Project_top_module_RISCV #(parameter WIDTH = 32)(
    input clk, clk_Button
    input reset,
    input [4:0] Debug_Source,
    output [WIDTH-1:0] Debug_Out,
    output [WIDTH-1:0] Debug_PC
);

// Internal wires to connect Datapath and Controller
wire [WIDTH-1:0] instruction;
wire zeroBit, cmpBit;

wire [2:0] immSrc;
wire aluSrcA, aluSrcB;
wire [2:0] aluControl;
wire [1:0] storeSrc;
wire loadByte, loadSign;
wire [1:0] resultSrc;
wire regWrite, memWrite;
wire pcSrc, link;
wire isSLT, isU;

// ----- UART CHANGE ----- //
wire [WIDTH-1:0] MEMORY_ADDR;
wire [7:0] RX_from_OUTSIDE;
wire TX_to_OUTSIDE;

// ----- UART TX ----- //
// FOR sb to 0x0000_0404 (Uart Address)
wire WRITE_TO_UART;
wire [7:0] UART_TRANSMIT_DATA;

// ----- UART RX ----- //
// FOR lw tfromo 0x0000_0404 (Uart Address)
wire SELECT_UART;
wire [WIDTH-1:0] UART_RECIEVE_DATA;
// ----- UART CHANGE ----- //

Datapath #(.WIDTH(WIDTH)) datapath_inst (
	.clk(clk_Button),
	.reset(reset),
	.Debug_Source(Debug_Source),
	.Debug_Out(Debug_Out),
	.Debug_PC(Debug_PC),

	.INSTRUCTION(instruction),
	.ZeroBit(zeroBit),
	.CMPBit(cmpBit),

	.ImmSrc(immSrc),
	.ALUSrcA(aluSrcA),
	.ALUSrcB(aluSrcB),
	.ALUControl(aluControl),
	.StoreSrc(storeSrc),
	.LoadByte(loadByte),
	.LoadSign(loadSign),
	.ResultSrc(resultSrc),
	.RegWrite(regWrite),
	.MemWrite(memWrite),
	.PCSrc(pcSrc),
	.Link(link),
	.isSLT(isSLT),
	.isU(isU),
	// ----- UART CHANGE ----- //
    // ------ UART ------- //
    .MEMORY_ADDR(MEMORY_ADDR),

    // ----- UART TX ----- //
    // FOR sb to 0x0000_0400 (Uart Address)
    .UART_TRANSMIT_DATA(UART_TRANSMIT_DATA),

    // ----- UART RX ----- //
    // FOR lw from 0x0000_0404 (Uart Address)
    .UART_RECIEVE_DATA(UART_RECIEVE_DATA),
    .SELECT_UART(SELECT_UART)
    // ----- UART CHANGE ----- //
);

Controller #(.WIDTH(WIDTH)) controller_inst (
	.INSTRUCTION(instruction),
	.ZeroBit(zeroBit),
	.CMPBit(cmpBit),

	.ImmSrc(immSrc),
	.ALUSrcA(aluSrcA),
	.ALUSrcB(aluSrcB),
	.ALUControl(aluControl),
	.StoreSrc(storeSrc),
	.LoadByte(loadByte),
	.LoadSign(loadSign),
	.ResultSrc(resultSrc),
	.RegWrite(regWrite),
	.MemWrite(memWrite),
	.PCSrc(pcSrc),
	.Link(link),
	.isSLT(isSLT),
	.isU(isU),

	// ----- UART CHANGE ----- //
	// ------ UART ------- //
	.MEMORY_ADDR(MEMORY_ADDR),

	// ----- UART TX ----- //
	// FOR sb to 0x0000_0400 (Uart Address)
	.WRITE_TO_UART(WRITE_TO_UART),

	// ----- UART RX ----- //
	// FOR lw tfromo 0x0000_0404 (Uart Address)
	.SELECT_UART(SELECT_UART)
	// ----- UART CHANGE ----- //
);

UART_Peripheral #(.WIDTH(WIDTH)) tempUart_inst (
    .clk_100MHz(clk),
	.clk_Button(clk_Button),
	.TX_Start(WRITE_TO_UART),
	.TX_DATA(UART_TRANSMIT_DATA),
	.Read_Access(SELECT_UART),
	.FIFO_OUT(UART_RECIEVE_DATA),
	.RX_Serial(RX_from_OUTSIDE)
	.TX_Serial(TX_to_OUTSIDE)
);

endmodule
