`timescale 1ns/10ps

module tb_mfhi;
    parameter Default  = 4'b0000,
              T_RESET  = 4'b1111,
              T0       = 4'b0001, T1 = 4'b0010, T2 = 4'b0011, T3 = 4'b0100,
              T4       = 4'b0101, A0 = 4'b0110, A1 = 4'b0111,
              A2       = 4'b1000, A3 = 4'b1001, Stop = 4'b1011;

    reg [3:0] Present_state = Default;

    reg clk, reset;
    reg gra, grb, grc, rin, rout, ba_out;
    reg pc_in, ir_in, y_in, mar_in, hi_in, lo_in, zhi_in, zlo_in;
    reg mdr_in, mdr_out, read, write, pc_out, c_out;
    reg in_port_out, out_port_in, con_in;
    reg [31:0] in_port_data_in;
    reg [4:0]  alu_opcode;
    reg zlo_out, zhi_out;
    reg hi_out, lo_out;

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
        .hi_out(hi_out), .lo_out(lo_out),
        .in_port_data_in(in_port_data_in),
        .out_port_in(out_port_in),
        .out_port_data_out(out_port_data_out),
        .con_in(con_in),
        .con_ff_out(con_ff_out),
        .bus_out(bus_out), .mdr_q(mdr_q)
    );

    initial begin clk = 0; forever #10 clk = ~clk; end

    always @(posedge clk) begin
        case (Present_state)
            Default:  Present_state <= T_RESET;
            T_RESET:  Present_state <= T0;
            T0:       Present_state <= T1;
            T1:       Present_state <= T2;
            T2:       Present_state <= T3;
            T3:       Present_state <= T4;
            T4:       Present_state <= A0;
            A0:       Present_state <= A1;
            A1:       Present_state <= A2;
            A2:       Present_state <= A3;
            A3:       Present_state <= Stop;
            Stop:     $finish;
        endcase
    end

    always @(Present_state) begin
        {gra, grb, grc, rin, rout, ba_out}            = 6'b0;
        {pc_in, ir_in, y_in, mar_in, hi_in, lo_in}    = 6'b0;
        {zhi_in, zlo_in}                               = 2'b0;
        {mdr_in, mdr_out, read, write, pc_out, c_out}  = 6'b0;
        {in_port_out, out_port_in, con_in}             = 3'b0;
        {zlo_out, zhi_out}                             = 2'b0;
        alu_opcode = 5'b00000;
        reset = 0;

        case (Present_state)
            Default:  reset = 1;
            T_RESET:  reset = 1;

            // PCout, MARin, IncPC, Zin
            T0: begin
                pc_out     = 1;
                mar_in     = 1;
                alu_opcode = 5'b10000; // INC
                zlo_in     = 1;
                force uut.u_regs.GEN_REGS[7].u_reg.q = 32'h0A00000A;
                force uut.u_regs.GEN_REGS[4].u_reg.q = 32'h08000007;
            end
            // Zlowout, PCin, Read, Mdatain[31..0], MDRin
            T1: begin
                zlo_out = 1;
                pc_in   = 1;
                read    = 1;
                mdr_in  = 1;
            end
            // MDRout, IRin
            T2: begin
                mdr_out = 1;
                ir_in = 1;
            end
            // Grb, rout, Yin
            T3: begin
                grb    = 1;
                rout = 1;
                y_in   = 1;
            end

            // A to bus, Mult, Zin, and hi lo in
            T4: begin
                alu_opcode = 5'b01101;
                gra = 1;
                rout = 1;
                zlo_in = 1;
                zhi_in = 1;
                hi_in = 1;
                lo_in = 1;
            end
            //now pull next instruction
            A0: begin
                pc_out     = 1;
                mar_in     = 1;
                alu_opcode = 5'b10000; // INC
                zlo_in     = 1;
            end
            A1: begin
                zlo_out = 1;
                pc_in   = 1;
                read    = 1;
                mdr_in  = 1;
            end
            // MDRout, IRin
            A2: begin
                mdr_out = 1;
                ir_in = 1;
            end
            // hi_out gra, rin should get hi regs value into r
            A3: begin
                hi_out = 1;
                gra = 1;
                rin = 1;
            end
        endcase
    end

    initial begin
        $dumpfile("waves/p2/mfhi.vcd");
        $dumpvars(0, tb_mfhi);
    end

endmodule