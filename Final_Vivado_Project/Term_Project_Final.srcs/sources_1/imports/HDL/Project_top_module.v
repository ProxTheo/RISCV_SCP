

module Project_top_module(
    //////////// GCLK //////////
    input wire                  CLK100MHZ,
	//////////// BTN //////////
	input wire		     		BTNU, 
	                      BTNL, BTNC, BTNR,
	                            BTND,
	//////////// SW //////////
	input wire	     [15:0]		SW,
	//////////// LED //////////
	output wire		 [15:0]		LED,
    //////////// 7 SEG //////////
    output wire [7:0] AN,
    output wire CA, CB, CC, CD, CE, CF, CG, DP,
    
    /////////// UART   //////////
    output wire UART_RXD_OUT,
    input wire UART_TXD_IN
);

wire [31:0] reg_out, PC;
wire [4:0] buttons;

//assign LED = SW;
assign LED = reg_out[31:24];

MSSD mssd_0(
        .clk        (CLK100MHZ                      ),
        .value      ({PC[7:0], reg_out[23:0]}       ),
        .dpValue    (8'b01000000                    ),
        .display    ({CG, CF, CE, CD, CC, CB, CA}   ),
        .DP         (DP                             ),
        .AN         (AN                             )
    );

debouncer debouncer_0(
        .clk        (CLK100MHZ                      ),
        .buttons    ({BTNU, BTNL, BTNC, BTNR, BTND} ),
        .out        (buttons                        )
    );

Project_top_module_RISCV my_computer(
        .clk100Mhz          (CLK100MHZ              ),
        .clk                (buttons[4]             ),
        .reset              (buttons[0]             ),
        .Debug_Source       (SW[4:0]                ),
        .Debug_Out          (reg_out                ),
        .Debug_PC           (PC                     ),
        .RX_from_OUTSIDE    (UART_TXD_IN            ),
        .TX_to_OUTSIDE      (UART_RXD_OUT           )
);

endmodule
