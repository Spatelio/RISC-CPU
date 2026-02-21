module reg32 (
    input  wire        clk, //clock
    input  wire        reset, //clear
    input  wire        wr_en, //write enable
    input  wire [31:0] d, //input
    output reg  [31:0] q  //output
);
    always @(posedge clk) begin
        if (reset)
            q <= 32'b0;
        else if (wr_en)
            q <= d;
    end
endmodule