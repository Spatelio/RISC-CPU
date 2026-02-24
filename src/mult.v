module mult(input signed [31:0] a, b, output[63:0] z);
	//booth alg multiplier
	reg [2:0] cc[15:0];
	reg [32:0] pp[15:0];
	reg[63:0] spp[15:0];
	
	reg [63:0] product;
	
	integer j,i;
	
	//get 2s comp of multiplicand
	wire [32:0] inv_a;
	assign inv_a = {~a[31], ~a} +1;
	
	always @ (a or b or inv_a) 
	begin
		//implicit 0 at the start
		cc[0] = {b[1], b[0], 1'b0};
		//recoding
		for (j=1; j < 16; j = j+1)
			cc[j] = {b[2*j+1], b[2*j], b[2*j-1]};

		//getting partial products	
		for (j=0; j < 16; j = j+1) 
		begin	
			case(cc[j])
				3'b001 : pp[j] = {a[31], a}; //sign extend
				3'b010 : pp[j] = {a[31], a}; //sign extend
				3'b011 : pp[j] = {a, 1'b0}; //left shift a
				3'b100 : pp[j] = {inv_a[31:0], 1'b0}; //left shift -a
				3'b101 : pp[j] = inv_a; //-a
				3'b110 : pp[j] = inv_a; //-a
				default : pp[j] = 0; //000 case or 111 case
			endcase
			spp[j] = $signed(pp[j]); 
			
			for (i=0 ; i<j ; i = i + 1)
				spp[j] = {spp[j], 2'b00}; //shift 2 bits
		end
	
		product = spp[0];
		//final accumulation
		for (j=1; j < 16; j = j+1)
			product = product + spp[j];
	end
	assign z = product;	
endmodule