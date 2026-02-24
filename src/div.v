module div(input signed [31:0] dividend, divisor, output reg [63:0] z);
	reg [31:0] high, low;
	always @ (*)
	begin
		high = dividend % divisor;
		low = (dividend - high) / divisor;
		z = {high, low};
	end
				
endmodule