module negate(
    input  wire [31:0] A,
    output wire [31:0] C
);
    wire [31:0] inverted_A;
    wire [32:0] carry;

    //Inversion (1's complement)
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : inv_loop
            assign inverted_A[i] = ~A[i];
        end
    endgenerate

    //Add 1 using a Carry 
    assign carry[0] = 1'b1;

    generate //ripple carry adder to add 1
        for (i = 0; i < 32; i = i + 1) begin : add_one_loop
            assign C[i] = inverted_A[i] ^ carry[i];
            
            assign carry[i+1] = inverted_A[i] & carry[i];
        end
    endgenerate

endmodule