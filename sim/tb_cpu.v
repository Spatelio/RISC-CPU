`timescale 1ns/10ps

// Integrated CPU simulation: datapath + control unit, memory from cases/tb_cpu.hex (copied to currentcase.hex by run script).
module tb_cpu;

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

        // Enough time for: reset→fetch×N, LDI, ADDI, HALT (control holds in S_HALT)
        #200000;

        if (uut.u_regs.r7 === 32'h0000005A)
            $display("PASS: R7 = 0x5A (ldi R4=0x63, addi R7,R4,-9)");
        else
            $display("FAIL: R7 = %h (expected 0x0000005A)", uut.u_regs.r7);

        $finish;
    end

    initial begin
        $dumpfile("tb_cpu.vcd");
        $dumpvars(0, tb_cpu);
    end

endmodule
