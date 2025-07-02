module Register_rsten #(parameter WIDTH=8) (
	  input  clk, reset, WE,
	  input	[WIDTH-1:0] DATA,
	  output reg [WIDTH-1:0] DATA_OUT
    );

initial begin
	DATA_OUT<=0;
end	
	 
always@(posedge clk) begin
	if (reset == 1'b1)
		DATA_OUT<={WIDTH{1'b0}};
	else if(WE==1'b1)	
		DATA_OUT<=DATA;
end
	 
endmodule	 