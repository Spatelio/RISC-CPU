
module bus (
    // data sources
    input  wire [31:0] r0,  input wire [31:0] r1,  input wire [31:0] r2,  input wire [31:0] r3,
    input  wire [31:0] r4,  input wire [31:0] r5,  input wire [31:0] r6,  input wire [31:0] r7,
    input  wire [31:0] r8,  input wire [31:0] r9,  input wire [31:0] r10, input wire [31:0] r11,
    input  wire [31:0] r12, input wire [31:0] r13, input wire [31:0] r14, input wire [31:0] r15,

    input  wire [31:0] hi,
    input  wire [31:0] lo,
    input  wire [31:0] zhi,
    input  wire [31:0] zlo,
    input  wire [31:0] pc,
    input  wire [31:0] mdr,
    input  wire [31:0] in_port,
    input  wire [31:0] c_signext,

    // bus source controls
    input  wire [15:0] r_out,
    input  wire        hi_out,
    input  wire        lo_out,
    input  wire        zhi_out,
    input  wire        zlo_out,
    input  wire        pc_out,
    input  wire        mdr_out,
    input  wire        in_port_out,
    input  wire        c_out,

    output wire [31:0] bus_out,

    output wire        bus_valid,
    output wire        bus_multi
);


    wire [31:0] onehot;
    assign onehot[15:0] = r_out;
    assign onehot[16]   = hi_out;
    assign onehot[17]   = lo_out;
    assign onehot[18]   = zhi_out;
    assign onehot[19]   = zlo_out;
    assign onehot[20]   = pc_out;
    assign onehot[21]   = mdr_out;
    assign onehot[22]   = in_port_out;
    assign onehot[23]   = c_out;

    assign onehot[31:24] = 8'b0;

    wire [4:0] sel;

    encoder32to5 u_enc (
        .onehot(onehot),
        .sel   (sel),
        .valid (bus_valid),
        .multi (bus_multi)
    );

    // 32 to 1 mux inputs
    bus_mux32 u_mux (
        .sel (sel),

        .in0 (r0),  .in1 (r1),  .in2 (r2),  .in3 (r3),
        .in4 (r4),  .in5 (r5),  .in6 (r6),  .in7 (r7),
        .in8 (r8),  .in9 (r9),  .in10(r10), .in11(r11),
        .in12(r12), .in13(r13), .in14(r14), .in15(r15),

        .in16(hi),
        .in17(lo),
        .in18(zhi),
        .in19(zlo),
        .in20(pc),
        .in21(mdr),
        .in22(in_port),
        .in23(c_signext),

        .in24(32'b0), .in25(32'b0), .in26(32'b0), .in27(32'b0),
        .in28(32'b0), .in29(32'b0), .in30(32'b0), .in31(32'b0),

        .out (bus_out)
    );

endmodule