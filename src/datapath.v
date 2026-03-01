module datapath (
    input  wire        clk,
    input  wire        reset,

    // Select and Encode Controls (Replacing old r_in/r_out)
    input  wire        gra, grb, grc,
    input  wire        rin, rout, ba_out, 

    // Remaining Phase 1 register enables
    input  wire        pc_in, ir_in, y_in, mar_in, 
    input  wire        hi_in, lo_in, zhi_in, zlo_in,
    input  wire        pc_start,
    
    // for alu
    input  wire        zhi_out, zlo_out,

    // MDR and RAM Controls
    input  wire        mdr_in, mdr_out, read, write,

    // I/O and Constant Controls
    input  wire        in_port_out, c_out,
    input  wire [31:0] in_port_value,

    // Outputs for simulation
    output wire [31:0] bus_out,
    output wire [31:0] mdr_q
);

    // Internal wires for register selection
    wire [15:0] internal_r_in;
    wire [15:0] internal_r_out;
    wire [31:0] ir_val; // To feed the decoder from IR register

    // internal register signals
    wire [31:0] r0, r1, r2, r3, r4, r5, r6, r7;
    wire [31:0] r8, r9, r10, r11, r12, r13, r14, r15;
    wire [31:0] pc, y, mar, hi, lo, zhi, zlo;
    wire [63:0] alu_result;
    wire [31:0] ram_data_out;

    // Select and Encode Logic Instance
    selectencode u_select_encode (
        .irIn(ir_val),          // Connected to output of IR register
        .gra(gra), .grb(grb), .grc(grc),
        .selectIn(rin),         // Driven by control unit/TB
        .selectOut(rout), 
        .BAout(ba_out), 
        .regIn(internal_r_in),  // Feeds u_regs.r_in
        .regOut(internal_r_out) // Feeds u_bus.r_out
    );

    // Sign Extension Logic
    // Constant C is in IR[18:0], bit 18 is the sign bit 
    wire [31:0] c_signext = {{13{ir_val[18]}}, ir_val[18:0]};

    // Register Block
    registers u_regs (
        .clk(clk), .reset(reset), .bus_in(bus_out),
        .r_in(internal_r_in),   // Driven by decoder
        .ir_in(ir_in), .y_in(y_in), .mar_in(mar_in),
        .hi_in(hi_in), .lo_in(lo_in), .zhi_in(zhi_in), .zlo_in(zlo_in),
        .alu_in(alu_result),
        .r0(r0), .r1(r1), .r2(r2), .r3(r3), .r4(r4), .r5(r5), .r6(r6), .r7(r7),
        .r8(r8), .r9(r9), .r10(r10), .r11(r11), .r12(r12), .r13(r13), .r14(r14), .r15(r15),
        .pc(pc), .ir(ir_val), .y(y), .mar(mar), .hi(hi), .lo(lo), .zhi(zhi), .zlo(zlo)
    );

    // Memory Subsystem
    mdr u_mdr (
        .clk(clk), .reset(reset), .mdr_in(mdr_in), .read(read),
        .bus_mux_out(bus_out), .mdatain(ram_data_out), .q(mdr_q)
    );

    ram u_ram(
        .clk(clk), .read(read), .write(write),
        .dataIn(mdr_q), .dataOut(ram_data_out), .addrIn(mar[8:0]) 
    );

    // Bus with BAout Logic
    // When BAout is high and R0 is selected, the bus receives 0 
    wire [31:0] r0_gated = (ba_out && internal_r_out[0]) ? 32'b0 : r0;

    bus u_bus (
        .r0(r0_gated), .r1(r1), .r2(r2), .r3(r3), // r0 replaced with gated version
        .r4(r4), .r5(r5), .r6(r6), .r7(r7),
        .r8(r8), .r9(r9), .r10(r10), .r11(r11),
        .r12(r12), .r13(r13), .r14(r14), .r15(r15),
        .hi(hi), .lo(lo), .zhi(zhi), .zlo(zlo), .pc(pc), .mdr(mdr_q),
        .in_port(in_port_value), .c_signext(c_signext),
        .r_out(internal_r_out), // Driven by decoder
        .hi_out(hi_out), .lo_out(lo_out), .zhi_out(zhi_out), .zlo_out(zlo_out),
        .pc_out(pc_out), .mdr_out(mdr_out), .in_port_out(in_port_out), .c_out(c_out),
        .bus_out(bus_out)
    );

    // ALU instance remains the same
    alu u_alu (.A(y), .B(bus_out), .opcode(ir_val[31:27]), .C(alu_result));

endmodule