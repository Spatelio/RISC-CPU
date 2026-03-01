module shiftl(
    input  wire [31:0] A,
    input  wire [4:0]  B, 
    output reg  [31:0] C
);

integer i;

always @(*) begin
    for (i = 0; i < 32; i = i + 1) begin
        // If the target index i is greater than or equal to the shift amount B,
        // we can pull a bit from the original vector A.
        if (i >= B) begin
            C[i] = A[i - B];
        end else begin
            // Otherwise, we are shifting in zeros from the right (LSB side)
            C[i] = 1'b0;
        end
    end
end

endmodule