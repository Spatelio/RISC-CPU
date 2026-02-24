module not_(
	input wire [31:0] A,
	output wire [31:0] C
	);
	
	genvar i;
	generate
		for (i=0; i<32; i=i+1) begin : loop
			assign C[i] = !A[i];
		end
	endgenerate
endmodule