module rotl(
    input  wire [31:0] A,
    input  wire [4:0]  B, //shift amount
    output wire [31:0] C
);
    assign C = (A << B) | (A >> (32 - B));
endmodule