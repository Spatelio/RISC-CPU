module shiftr(
    input  wire [31:0] A,
    input  wire [4:0]  B, //shift amount
    output wire [31:0] C
);

assign C = A >> B;

endmodule
