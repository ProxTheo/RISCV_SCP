module Extender_Load (
    input isSigned, isByte,
    input [31:0] INPUT,
    output reg [31:0] OUTPUT
);

always @(*) begin
    case({isSigned, isByte})
        2'b00: OUTPUT <= {{(16){1'b0}}, INPUT[15:0]};         /// Zero-Extend, HalfWord
        2'b01: OUTPUT <= {{(24){1'b0}}, INPUT[7:0]};          /// Zero-Extend, Byte
        2'b10: OUTPUT <= {{(16){INPUT[15]}}, INPUT[15:0]};    /// Sign-Extend, HalfWord
        2'b11: OUTPUT <= {{(24){INPUT[7]}}, INPUT[7:0]};      /// Sign-Extend, Byte
    endcase 
end

endmodule