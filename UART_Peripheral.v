module UART_Peripheral(
    input clk_100MHz, clk_Button, reset,
    input TX_Start,
    input [7:0] TX_DATA,
    input Read_Access, RX_Serial,
    output TX_Serial,
    output [31:0] FIFO_OUT
    );

    wire TX_BUSY;
    wire RX_Done;
    wire [7:0] RX_OUT;

    UART_TX uart_tx_inst(
        .clk(clk_100MHz),
        .reset(reset),
        .TX_Start(TX_Start),
        .TX_DATA(TX_DATA),
        .TX_Serial(TX_Serial),
        .TX_BUSY(TX_BUSY)
    );


    UART_RX uart_rx_inst(
        .clk(clk_100MHz),
        .reset(reset),
        .RX_Serial(RX_Serial),
        .RX_Done(RX_Done),
        .RX_OUT(RX_OUT)
    );

    UART_FIFO uart_fifo_inst(
        .clk_100MHz(clk_100MHz),
		.clk_Button(clk_Button),
        .reset(reset),
        .DATA(RX_OUT),
        .write_enable(RX_Done),
        .read_enable(Read_Access),
        .read_data(FIFO_OUT)
    );


endmodule