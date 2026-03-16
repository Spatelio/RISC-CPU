`timescale 1ns/10ps

module tb_jal;
    parameter Default  = 4'b0000,
              T_RESET  = 4'b1111,
              T0       = 4'b0001,
              T1       = 4'b0010,
              T2       = 4'b0011,
              T3       = 4'b0100,
              T4       = 4'b0101,
              Stop     = 4'b1011;

    reg [3:0] Present_state = Default;

    reg clk, reset;
    reg gra, grb, grc, rin, rout, ba_out;
    reg pc_in, ir_in, y_in, mar_in, hi_in, lo_in, zhi_in, zlo_in;
    reg mdr_in, mdr_out, read, write, pc_out, c_out;
    reg in_port_out, out_port_in, con_in;
    reg [31:0] in_port_data_in;
    reg [4:0]  alu_opcode;
    reg zlo_out, zhi_out;

    wire [31:0] bus_out;
    wire [31:0] mdr_q;
    wire [31:0] out_port_data_out;
    wire        con_ff_out;

    datapath uut (
        .clk(clk), .reset(reset),
        .gra(gra), .grb(grb), .grc(grc), .rin(rin), .rout(rout), .ba_out(ba_out),
        .pc_in(pc_in), .ir_in(ir_in), .y_in(y_in), .mar_in(mar_in),
        .hi_in(hi_in), .lo_in(lo_in), .zhi_in(zhi_in), .zlo_in(zlo_in),
        .alu_opcode(alu_opcode),
        .pc_out(pc_out),
        .mdr_in(mdr_in), .mdr_out(mdr_out), .read(read), .write(write),
        .in_port_out(in_port_out), .c_out(c_out),
        .zhi_out(zhi_out), .zlo_out(zlo_out),
        .in_port_data_in(in_port_data_in),
        .out_port_in(out_port_in),
        .out_port_data_out(out_port_data_out),
        .con_in(con_in),
        .con_ff_out(con_ff_out),
        .bus_out(bus_out), .mdr_q(mdr_q)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        // jal R4
        // opcode = 10011, Ra = 4
        // Rb = 12 is used here only so grb+rin can target R12 in this TB
        uut.u_ram.memData[9'h010] = {5'b10011, 4'd4, 4'd12, 19'd0};
    end

    always @(posedge clk) begin
        case (Present_state)
            Default: Present_state <= T_RESET;
            T_RESET: Present_state <= T0;
            T0:      Present_state <= T1;
            T1:      Present_state <= T2;
            T2:      Present_state <= T3;
            T3:      Present_state <= T4;
            T4:      Present_state <= Stop;
            Stop:    $stop;
        endcase
    end

    always @(Present_state) begin
        {gra, grb, grc, rin, rout, ba_out}             = 6'b0;
        {pc_in, ir_in, y_in, mar_in, hi_in, lo_in}     = 6'b0;
        {zhi_in, zlo_in}                                = 2'b0;
        {mdr_in, mdr_out, read, write, pc_out, c_out}  = 6'b0;
        {in_port_out, out_port_in, con_in}             = 3'b0;
        {zlo_out, zhi_out}                              = 2'b0;
        alu_opcode = 5'b00000;
        reset = 0;
        in_port_data_in = 32'h00000000;

        case (Present_state)
            Default: begin
                reset = 1;
            end

            T_RESET: begin
                reset = 1;
            end

            // T0: PCout, MARin, IncPC, Zin
            T0: begin
                pc_out     = 1;
                mar_in     = 1;
                alu_opcode = 5'b10000; // INC
                zlo_in     = 1;

                // preload for jal R4 demo
                force uut.u_regs.GEN_REGS[4].u_reg.q  = 32'h000000FF; // jump target
                force uut.u_regs.GEN_REGS[12].u_reg.q = 32'h00000000; // old RA
                force uut.u_regs.u_pc.q               = 32'h00000010; // starting PC
                #1;
                release uut.u_regs.GEN_REGS[4].u_reg.q;
                release uut.u_regs.GEN_REGS[12].u_reg.q;
                release uut.u_regs.u_pc.q;
            end

            // T1: Zlowout, PCin, Read, MDRin
            T1: begin
                zlo_out = 1;
                pc_in   = 1;
                read    = 1;
                mdr_in  = 1;
            end

            // T2: MDRout, IRin
            T2: begin
                mdr_out = 1;
                ir_in   = 1;
            end

            // T3: save return address into R12
            // using grb cause this TB places 12 in the Rb field
            T3: begin
                pc_out = 1;
                rin    = 1;
                grb    = 1;
            end

            // T4: Gra, Rout, PCin  => PC <- R4
            T4: begin
                gra   = 1;
                rout  = 1;
                pc_in = 1;
            end
        endcase
    end

endmodule