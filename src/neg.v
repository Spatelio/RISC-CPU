module negate(
    input  wire [31:0] A,
    output reg  [31:0] C
);
    always @(*) begin
        C = ~A + 1'b1;  // Two's complement to negate A
    end
endmodule