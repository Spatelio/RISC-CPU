module subtractor(A, B, Result);

input [31:0] A, B;
output [31:0] Result;

reg [31:0] TwosCompB;
reg [31:0] Result;
reg [32:0] LocalCarry;

integer i;

always@(A or B)
    begin
	TwosCompB = ~B +1'b1; //2's complement
        LocalCarry = 33'd0;
        for(i = 0; i < 32; i = i + 1)
        begin
                Result[i] = A[i]^TwosCompB[i]^LocalCarry[i];
                LocalCarry[i+1] = (A[i]&TwosCompB[i])|(LocalCarry[i]&(A[i]|TwosCompB[i]));
        end
end
endmodule