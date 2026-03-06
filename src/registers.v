module registers (
    input  wire        clk,
    input  wire        reset,

    // datapath input
    input  wire [31:0] bus_in,
    //alu input
    input wire [63:0] alu_in,
    // gen purp regs write enables
    input  wire [15:0] r_in, //r_in[i] loads Ri from bus_in

    // special reg write enables
    input  wire        pc_in,
    input  wire        ir_in,
    input  wire        y_in,
    input  wire        mar_in,
    input  wire        hi_in,
    input  wire        lo_in,

    // Z register write enables
    input  wire        zhi_in,
    input  wire        zlo_in,

    input wire ba_out,

    // outputs
    output wire [31:0] r0,
    output wire [31:0] r1,
    output wire [31:0] r2,
    output wire [31:0] r3,
    output wire [31:0] r4,
    output wire [31:0] r5,
    output wire [31:0] r6,
    output wire [31:0] r7,
    output wire [31:0] r8,
    output wire [31:0] r9,
    output wire [31:0] r10,
    output wire [31:0] r11,
    output wire [31:0] r12,
    output wire [31:0] r13,
    output wire [31:0] r14,
    output wire [31:0] r15,

    output wire [31:0] pc,
    output wire [31:0] ir,
    output wire [31:0] y,
    output wire [31:0] mar,
    output wire [31:0] hi,
    output wire [31:0] lo,

    output wire [31:0] zhi,
    output wire [31:0] zlo
);

	// internal register array
    wire [31:0] R [0:15];

    wire [31:0] r0_internal_q;

    reg32 u_reg0 (
        .clk   (clk),
        .reset (reset),
        .wr_en (r_in[0]),
        .d     (bus_in),
        .q     (r0_internal_q)
    );

    assign R[0] = (ba_out) ? 32'b0 : r0_internal_q;

    genvar i;
    generate
        for (i = 1; i < 16; i = i + 1) begin : GEN_REGS
            reg32 u_reg (
                .clk   (clk),
                .reset (reset),
                .wr_en    (r_in[i]),
                .d     (bus_in),
                .q     (R[i])
            );
        end
    endgenerate

    // namimg array outputs
    assign r0  = R[0];
    assign r1  = R[1];
    assign r2  = R[2];
    assign r3  = R[3];
    assign r4  = R[4];
    assign r5  = R[5];
    assign r6  = R[6];
    assign r7  = R[7];
    assign r8  = R[8];
    assign r9  = R[9];
    assign r10 = R[10];
    assign r11 = R[11];
    assign r12 = R[12];
    assign r13 = R[13];
    assign r14 = R[14];
    assign r15 = R[15];

    // Special registers
    reg32 u_ir  (.clk(clk), .reset(reset), .wr_en(ir_in),  .d(bus_in), .q(ir));
    reg32 u_y   (.clk(clk), .reset(reset), .wr_en(y_in),   .d(bus_in), .q(y));
    reg32 u_mar (.clk(clk), .reset(reset), .wr_en(mar_in), .d(bus_in), .q(mar));
    reg32 u_hi  (.clk(clk), .reset(reset), .wr_en(hi_in),  .d(alu_in[63:32]), .q(hi));
    reg32 u_lo  (.clk(clk), .reset(reset), .wr_en(lo_in),  .d(alu_in[31:0]), .q(lo));
    reg32 u_pc  (.clk(clk), .reset(reset), .wr_en(pc_in), .d(bus_in),  .q(pc));

    // Z register split (ZHI/ZLO)
    reg32 u_zhi (.clk(clk), .reset(reset), .wr_en(zhi_in), .d(alu_in[63:32]), .q(zhi));
    reg32 u_zlo (.clk(clk), .reset(reset), .wr_en(zlo_in), .d(alu_in[31:0]),  .q(zlo));
   

endmodule