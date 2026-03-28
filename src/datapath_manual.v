// Manual-control datapath (Phase 1 / old testbenches): drive all control inputs from the TB.
module datapath_manual (
    input  wire        clk,
    input  wire        reset,

    input  wire        gra, grb, grc,
    input  wire        rin, rout, ba_out,

    input  wire        pc_in, ir_in, y_in, mar_in, 
    input  wire        hi_in, lo_in, zhi_in, zlo_in,
    input  wire        hi_out, lo_out,
    input  wire        pc_out,
    
    input  wire        zhi_out, zlo_out,
    input  wire [4:0]  alu_opcode,

    input  wire        mdr_in, mdr_out, read, write,

    input  wire        in_port_out, c_out,
    input  wire [31:0] in_port_data_in,
    input  wire        out_port_in,
    output wire [31:0] out_port_data_out,

    output wire [31:0] bus_out,
    output wire [31:0] mdr_q,
    input  wire        con_in,
    output wire        con_ff_out

);

    wire [15:0] internal_r_in;
    wire [15:0] internal_r_out;
    wire [31:0] ir_val;

    wire [31:0] r0, r1, r2, r3, r4, r5, r6, r7;
    wire [31:0] r8, r9, r10, r11, r12, r13, r14, r15;
    wire [31:0] pc, y, mar, hi, lo, zhi, zlo;
    wire [63:0] alu_result;
    wire [31:0] ram_data_out;

    wire [31:0] c_sign_extended;

    selectencode u_select_encode (
        .irIn(ir_val),
        .gra(gra), .grb(grb), .grc(grc),
        .selectIn(rin),
        .selectOut(rout), 
        .BAout(ba_out),
        .jal_link_r12(1'b0), // integrated CPU uses control_unit; manual TBs drive grb/grc/gra
        .regIn(internal_r_in),
        .regOut(internal_r_out),
        .c_sign_extended(c_sign_extended)
    );

    wire [31:0] in_port_q;

    reg32 u_inport(
        .clk(clk),
        .reset(reset),
        .wr_en(1'b1),
        .d(in_port_data_in),
        .q(in_port_q)
    );

    reg32 u_outport(
        .clk(clk),
        .reset(reset),
        .wr_en(out_port_in),
        .d(bus_out),
        .q(out_port_data_out)
    );

    registers u_regs (
        .clk(clk), .reset(reset), .bus_in(bus_out),
        .r_in(internal_r_in),
        .ir_in(ir_in), .y_in(y_in), .mar_in(mar_in),
        .hi_in(hi_in), .lo_in(lo_in), .zhi_in(zhi_in), .zlo_in(zlo_in),
        .alu_in(alu_result),
        .ba_out(ba_out),
        .r0(r0), .r1(r1), .r2(r2), .r3(r3), .r4(r4), .r5(r5), .r6(r6), .r7(r7),
        .r8(r8), .r9(r9), .r10(r10), .r11(r11), .r12(r12), .r13(r13), .r14(r14), .r15(r15),
        .pc(pc), .ir(ir_val), .y(y), .mar(mar), .hi(hi), .lo(lo), .zhi(zhi), .zlo(zlo),
        .pc_in(pc_in)
    );

    conff u_conff (
        .bus_in(bus_out),
        .irIn(ir_val[20:19]),
        .con_in(con_in),
        .clk(clk),
        .reset(reset),
        .q(con_ff_out)
    );

    mdr u_mdr (
        .clk(clk), .reset(reset), .mdr_in(mdr_in), .read(read),
        .bus_mux_out(bus_out), .mdatain(ram_data_out), .q(mdr_q)
    );

    ram u_ram(
        .clk(clk), .read(read), .write(write),
        .dataIn(mdr_q), .dataOut(ram_data_out), .addrIn(mar[8:0]) 
    );

    bus u_bus (
        .r0(r0), .r1(r1), .r2(r2), .r3(r3),
        .r4(r4), .r5(r5), .r6(r6), .r7(r7),
        .r8(r8), .r9(r9), .r10(r10), .r11(r11),
        .r12(r12), .r13(r13), .r14(r14), .r15(r15),
        .hi(hi), .lo(lo), .zhi(zhi), .zlo(zlo), .pc(pc), .mdr(mdr_q),
        .in_port(in_port_q), .c_signext(c_sign_extended),
        .r_out(internal_r_out),
        .hi_out(hi_out), .lo_out(lo_out), .zhi_out(zhi_out), .zlo_out(zlo_out),
        .pc_out(pc_out), .mdr_out(mdr_out), .in_port_out(in_port_out), .c_out(c_out),
        .bus_out(bus_out)
    );

    alu u_alu (.A(y), .B(bus_out), .opcode(alu_opcode), .C(alu_result));

endmodule
