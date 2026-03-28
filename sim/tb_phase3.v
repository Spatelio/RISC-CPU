`timescale 1ns/10ps

// Runs cases/phase3.hex (copy to currentcase.hex before vvp). Long enough for full program + subA + halt.
module tb_phase3;

    reg         clk;
    reg         reset;
    reg         stop;
    reg  [31:0] in_port_data_in;

    wire [31:0] bus_out;
    wire [31:0] mdr_q;
    wire [31:0] out_port_data_out;
    wire        con_ff_out;

    datapath uut (
        .clk(clk),
        .reset(reset),
        .stop(stop),
        .in_port_data_in(in_port_data_in),
        .out_port_data_out(out_port_data_out),
        .bus_out(bus_out),
        .mdr_q(mdr_q),
        .con_ff_out(con_ff_out)
    );

    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        stop            = 1'b0;
        in_port_data_in = 32'b0;
        reset           = 1'b1;
        #25;
        reset = 1'b0;
        // ~42 insns * ~12+ cycles; margin for jal/subA
        #800000;
        $display("--- Phase 3 snapshot (see lab comments for expected values) ---");
        $display("PC  = %h  R12 = %h  (return addr often 0x29)", uut.u_regs.pc, uut.u_regs.r12);
        $display("R0  = %h  R1  = %h  R2  = %h  R3  = %h", uut.u_regs.r0, uut.u_regs.r1, uut.u_regs.r2, uut.u_regs.r3);
        $display("R4  = %h  R5  = %h  R6  = %h  R7  = %h", uut.u_regs.r4, uut.u_regs.r5, uut.u_regs.r6, uut.u_regs.r7);
        $display("mem[0x89] = %h  mem[0xA3] = %h", uut.u_ram.memData[9'h089], uut.u_ram.memData[9'h0A3]);
        $finish;
    end

    // Optional: iverilog +DUMP_PHASE3=1 to avoid huge VCDs by default
    `ifdef DUMP_PHASE3
    initial begin
        $dumpfile("tb_phase3.vcd");
        $dumpvars(1, tb_phase3);
    end
    `endif

endmodule
