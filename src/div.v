module div(input signed [31:0] dividend, divisor, output reg [63:0] res);
	reg [31:0] A;
	reg [31:0] Q;
	reg [31:0] M;

	integer i;
	always @(*) begin
		A = 32'b0;
		Q = dividend;
		M = divisor;

		for (i = 0; i<32; i = i+1) begin
			//shift left
			{A, Q} = {A, Q} << 1;

			A = A-M;
			if (A[31]) begin // If A is negative
                Q[0] = 1'b0;      // set Quotient bit 0
                A = A + M;        // add M back to A
            end else begin
                Q[0] = 1'b1;      // set Quotient bit 1
            end
		end

		res = {A, Q}; //final output
	end		
endmodule