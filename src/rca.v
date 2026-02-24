module adder (
    input [31:0] A, B,
    output reg [31:0] sum
);

    reg [32:0] carry;  // Carry bits (One extra bit for final carry)
    integer i;

    always @(*) begin
        carry[0] = 1'b0;  // Initialize carry to 0
        for (i = 0; i < 32; i = i + 1) begin
            sum[i] = A[i] ^ B[i] ^ carry[i];
            carry[i+1] = (A[i] & B[i]) | (carry[i] & (A[i] | B[i]));
        end
    end
endmodule