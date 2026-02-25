module shiftr(
    input  wire [31:0] A,
    input  wire [4:0]  B, 
    output reg  [31:0] C // Changed to reg for always block assignment
);

integer i;

always @(*) begin
    for (i = 0; i < 32; i = i + 1) begin
        // Check if the current bit position plus shift amount is within 0-31
        if (i + B < 32) begin
            C[i] = A[i + B];
        end else begin
            C[i] = 1'b0; // Fill with zeros for logical shift
        end
    end
end

endmodule