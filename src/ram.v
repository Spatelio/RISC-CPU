module ram (
    input  wire        read,
    input  wire        write,
    input  wire        clk,
    input  wire [31:0] dataIn,
    input  wire [8:0]  addrIn,
    output reg  [31:0] dataOut
);

    reg [31:0] memData [0:511];

    // synchronous write
    always @(posedge clk) begin
        if (write)
            memData[addrIn] <= dataIn;
    end

    always @(*) begin
        if (read)
            dataOut = memData[addrIn];
        else
            dataOut = 32'h00000000;
    end

endmodule