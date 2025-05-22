module Memory_DATA#(BYTE_SIZE=4, ADDR_WIDTH=32)(
	input clk, MemWrite,
	input [ADDR_WIDTH-1:0] ADDR,
	input [(BYTE_SIZE*8)-1:0] WD,
	output [(BYTE_SIZE*8)-1:0] RD 
);

localparam MEM_SIZE = 256;

reg [7:0] mem [0:MEM_SIZE-1];
integer kk;

initial begin
	
	for (kk = 0; kk < MEM_SIZE; kk = kk + 1) begin
		mem[kk] <= 8'b0000_0000;
	end
end

genvar i;
generate
	for (i = 0; i < BYTE_SIZE; i = i + 1) begin: read_generate
		assign RD[8*i+:8] = mem[ADDR+i];
	end
endgenerate	
integer k;

always @(posedge clk) begin
	 if(MemWrite) begin	
		  for (k = 0; k < BYTE_SIZE; k = k + 1) begin
				mem[ADDR+k] <= WD[8*k+:8];
		  end
	 end
end

endmodule