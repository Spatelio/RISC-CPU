module ram (
    input wire read,
    input wire write,
    input wire clk,
    input wire[31:0] dataIn,
    input wire[8:0] addrIn,
    output reg[31:0] dataOut //we'll do sync ram
);

reg[31:0] memData[0:511];

initial begin
    $readmemh("currentcase.hex", memData);
end

always @(posedge clk) begin
    if(write) begin
        memData[addrIn] <= dataIn;
    end
end

always @(*) begin
    if(read) begin
        dataOut <= memData[addrIn];
    end
    else begin
        dataOut <= 32'b0;
    end
end

endmodule 