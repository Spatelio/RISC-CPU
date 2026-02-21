module mdr (
    input  wire        clk,
    input  wire        reset, //synchronous clear
    input  wire        mdr_in, //MDRin / write enable
    input  wire        read,
    input  wire [31:0] bus_mux_out,
    input  wire [31:0] mdatain, //testbenches dirve in phase 1
    output reg  [31:0] q //MDR contents
);

    wire [31:0] mdmux_out = (read) ? mdatain : bus_mux_out;

    always @(posedge clk) begin
        if (reset)
            q <= 32'b0;
        else if (mdr_in)
            q <= mdmux_out;
    end

endmodule