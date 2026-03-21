module conff(
    input wire [31:0] bus_in, //32 bits
    input wire [1:0]  irIn, //20-19
    input wire        con_in, // Control signal to load the Flip-Flop 
    input wire        clk,    // synchronous
    input wire        reset,  // 
    output reg        q
);

    wire is_zero;
    wire is_nonzero;
    wire is_pos;
    wire is_neg;

    assign is_zero    = (bus_in == 32'b0);       // "== 0"
    assign is_nonzero = (bus_in != 32'b0);       // "!= 0" (Or reduction |bus_in)
    assign is_pos     = (bus_in[31] == 1'b0);    // ">= 0" (MSB is 0)
    assign is_neg     = (bus_in[31] == 1'b1);

    wire [3:0] decoded;

    //bit selection into a 4 bit signal
    assign decoded = 4'b0001 << irIn;

    wire condition_met;
    assign condition_met = (decoded[0] & is_zero) | 
                           (decoded[1] & is_nonzero) | 
                           (decoded[2] & is_pos) | 
                           (decoded[3] & is_neg);

    always @(posedge clk) begin
        if (reset) begin
            q <= 1'b0;
        end else if (con_in) begin
            q <= condition_met;
        end
    end

endmodule