
//phase 1 - Mdatain is driven by testbench

module datapath (
    input  wire        clk,
    input  wire        reset,

    // register write enables (Rin)
    input  wire [15:0] r_in,
    input  wire        pc_in,
    input  wire        ir_in,
    input  wire        y_in,
    input  wire        mar_in,
    input  wire        hi_in,
    input  wire        lo_in,
    input  wire        zhi_in,
    input  wire        zlo_in,
	 
	 //alu opcode 
	 input  wire [4:0]  alu_opcode,

    // MDR controls for phase 1
    input  wire        mdr_in, // MDRin
    input  wire        mdr_out, // MDRout - bus source control
    input  wire        read, // selects Mdatain into MDR
    input  wire [31:0] mdatain,

    // bus source controls =====
    input  wire [15:0] r_out,
    input  wire        hi_out,
    input  wire        lo_out,
    input  wire        zhi_out,
    input  wire        zlo_out,
    input  wire        pc_out,

    // for phase 2 logic and i/o
    input  wire        in_port_out,
    input  wire        c_out,
    input  wire [31:0] in_port_value,
    input  wire [31:0] c_signext,

    // simulkation outpuits
    output wire [31:0] bus_out, //BusMuxOut
    output wire        bus_valid,
    output wire        bus_multi,
    output wire [31:0] mdr_q //expose MDR contents
);

    // internal register wires
    wire [31:0] r0, r1, r2, r3, r4, r5, r6, r7;
    wire [31:0] r8, r9, r10, r11, r12, r13, r14, r15;
    wire [31:0] pc, ir, y, mar, hi, lo;
    wire [31:0] zhi, zlo;
	 
	 wire [63:0] alu_result;
	 
	 alu u_alu (
        .A(y),
        .B(bus_out),
        .opcode(alu_opcode),
        .C(alu_result)
    );

    // register block loads from bus_out
    registers u_regs (
        .clk   (clk),
        .reset (reset),
        .bus_in(bus_out),

        .r_in  (r_in),

        .pc_in (pc_in),
        .ir_in (ir_in),
        .y_in  (y_in),
        .mar_in(mar_in),
        .hi_in (hi_in),
        .lo_in (lo_in),

        .zhi_in(zhi_in),
        .zlo_in(zlo_in),

        .r0(r0), .r1(r1), .r2(r2), .r3(r3),
        .r4(r4), .r5(r5), .r6(r6), .r7(r7),
        .r8(r8), .r9(r9), .r10(r10), .r11(r11),
        .r12(r12), .r13(r13), .r14(r14), .r15(r15),

        .pc(pc), .ir(ir), .y(y), .mar(mar),
        .hi(hi), .lo(lo),

        .zhi(zhi), .zlo(zlo)
    );

    // MDR
    // MDR can load from bus_out or mdatain
    mdr u_mdr (
        .clk        (clk),
        .reset      (reset),
        .mdr_in     (mdr_in),
        .read       (read),
        .bus_mux_out(bus_out),
        .mdatain    (mdatain),
        .q          (mdr_q)
    );

    // bus
    bus u_bus (
        .r0(r0),   .r1(r1),   .r2(r2),   .r3(r3),
        .r4(r4),   .r5(r5),   .r6(r6),   .r7(r7),
        .r8(r8),   .r9(r9),   .r10(r10), .r11(r11),
        .r12(r12), .r13(r13), .r14(r14), .r15(r15),

        .hi(hi),
        .lo(lo),
        .zhi(zhi),
        .zlo(zlo),
        .pc(pc),
        .mdr(mdr_q),
        .in_port(in_port_value),
        .c_signext(c_signext),

        .r_out(r_out),
        .hi_out(hi_out),
        .lo_out(lo_out),
        .zhi_out(zhi_out),
        .zlo_out(zlo_out),
        .pc_out(pc_out),
        .mdr_out(mdr_out),
        .in_port_out(in_port_out),
        .c_out(c_out),

        .bus_out(bus_out),
        .bus_valid(bus_valid),
        .bus_multi(bus_multi)
    );

endmodule