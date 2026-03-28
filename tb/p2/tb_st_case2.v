`timescale 1ns/10ps

module tb_st_case2;
    parameter Default  = 4'b0000,
              T_RESET  = 4'b1111,
              T0       = 4'b0001, T1 = 4'b0010, T2 = 4'b0011, T3 = 4'b0100,
              T4       = 4'b0101, T5 = 4'b0110, T6 = 4'b0111,
              T7       = 4'b1000, Stop = 4'b1011;

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

    datapath_manual uut (
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

    initial begin clk = 0; forever #10 clk = ~clk; end

    always @(posedge clk) begin
        case (Present_state)
            Default:  Present_state <= T_RESET;
            T_RESET:  Present_state <= T0;
            T0:       Present_state <= T1;
            T1:       Present_state <= T2;
            T2:       Present_state <= T3;
            T3:       Present_state <= T4;
            T4:       Present_state <= T5;
            T5:       Present_state <= T6;
            T6:       Present_state <= T7;
            T7:       Present_state <= Stop;
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
                force uut.u_regs.GEN_REGS[6].u_reg.q = 32'h00000063; //set that value
            end
            // Zlowout, PCin, Read, Mdatain[31..0], MDRin
            T1: begin
                zlo_out = 1;
                pc_in   = 1;
                read    = 1;
                mdr_in  = 1;
            end
            // MDRout, IRin (end of fetch)
            T2: begin
                mdr_out = 1;
                ir_in = 1;
            end
            // Grb, BAout, Yin (still compute offsets)
            T3: begin
                grb    = 1;
                ba_out = 1;
                y_in   = 1; //this is now the addr to store to
            end

            // Cout, ADD, Zin (so 3 and 4 can stay)
            T4: begin
                c_out      = 1;
                alu_opcode = 5'b00000; // ADD
                zlo_in     = 1;
            end
            // Zlowout, MARin (mar now points to addr to store to)
            T5: begin
                zlo_out = 1;
                mar_in  = 1;
            end
            // A -> bus -> mdr
            T6: begin
                gra = 1;
                rout = 1;
                mdr_in = 1;
            end
            // MDRout, write enable
            T7: begin
                write = 1;
                mdr_out = 1;
            end
            Stop: begin
                // Check if the memory at 0x1F contains the value of R6 (0x63)
                if (uut.u_ram.memData[9'h082] === 32'h00000063) begin
                    $display("PASSED: Memory at 0x82 correctly contains 0x63"); 
                end else begin
                    $display("FAILED: Memory at 0x82 contains %h (expected 0x63)", uut.u_ram.memData[9'h082]);
                end
                $finish;
            end
        endcase
    end

    initial begin
        $dumpfile("waves/p2/st_case2.vcd");
        $dumpvars(0, tb_st_case2);
    end

endmodule