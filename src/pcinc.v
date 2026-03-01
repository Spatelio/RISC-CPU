module pcinc (
    input [31:0] B,
    output wire [31:0] sum
);
    assign sum = B + 1;
endmodule