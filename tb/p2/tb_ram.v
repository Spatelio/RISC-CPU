/**`timescale 1ns/10ps

module tb_ram;
    // Define States
    parameter Default = 4'b0000, T0 = 4'b0001, T1 = 4'b0010, T2 = 4'b0011, 
              T3 = 4'b0100, T4 = 4'b0101, T5 = 4'b0110, T6 = 4'b0111, T7 = 4'b1000,
              T8 = 4'b1001, T9 = 4'b1010, T10 = 4'b1011, T11 = 4'b1100, T12 = 4'b1101, 
              T13 = 4'b1110, Stop = 4'b1111;

    reg [3:0] Present_state = Default;

    // Datapath Signals 
    reg clk, reset;
    reg [15:0] r_in;
    reg pc_in, ir_in, y_in, mar_in, hi_in, lo_in, zhi_in, zlo_in;
    reg pc_start; 
    reg mdr_in, mdr_out, read, write; 
    reg [4:0] alu_opcode;
    reg [31:0] mdatain;
    
    reg [15:0] r_out;
    reg hi_out, lo_out, zhi_out, zlo_out, pc_out;
    reg in_port_out, c_out;
    reg [31:0] in_port_value;
    reg [31:0] c_signext;

    wire [31:0] bus_out;
    wire bus_valid, bus_multi;
    wire [31:0] mdr_q;

    // Instantiate Datapath
    datapath uut (
        .clk(clk), .reset(reset),
        .r_in(r_in), .pc_in(pc_in), .ir_in(ir_in), .y_in(y_in), 
        .mar_in(mar_in), .hi_in(hi_in), .lo_in(lo_in), 
        .zhi_in(zhi_in), .zlo_in(zlo_in), .pc_start(pc_start),
        .alu_opcode(alu_opcode),
        .mdr_in(mdr_in), .mdr_out(mdr_out), 
        .read(read), .write(write), 
        .mdatain(mdatain),
        .r_out(r_out), .hi_out(hi_out), .lo_out(lo_out), 
        .zhi_out(zhi_out), .zlo_out(zlo_out), .pc_out(pc_out),
        .in_port_out(in_port_out), .c_out(c_out),
        .in_port_value(in_port_value), .c_signext(c_signext),
        .bus_out(bus_out), .bus_valid(bus_valid), .bus_multi(bus_multi), .mdr_q(mdr_q)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // State Transition 
    always @(posedge clk) begin
        case (Present_state)
            Default: Present_state <= T0;
            T0:      Present_state <= T1;
            T1:      Present_state <= T2;
            T2:      Present_state <= T3;
            T3:      Present_state <= T4;
            T4:      Present_state <= T5;
            T5:      Present_state <= T6;
            T6:      Present_state <= T7;
            T7:      Present_state <= T8;  
            T8:      Present_state <= T9;
            T9:      Present_state <= T10;
            T10:     Present_state <= T11;
            T11:     Present_state <= T12;
            T12:     Present_state <= T13;
            T13:     Present_state <= Stop;
            Stop:    $finish; 
        endcase
    end

    // State Control Logic
    always @(Present_state) begin
        // default assignments
        reset = 0; r_in = 0; r_out = 0;
        pc_in = 0; ir_in = 0; y_in = 0; mar_in = 0; hi_in = 0; lo_in = 0; zhi_in = 0; zlo_in = 0;
        pc_out = 0; hi_out = 0; lo_out = 0; zhi_out = 0; zlo_out = 0; pc_start = 0;
        mdr_in = 0; mdr_out = 0; read = 0; write = 0;
        alu_opcode = 0; mdatain = 0;
        in_port_out = 0; c_out = 0; in_port_value = 0; c_signext = 0;

        case (Present_state)
            Default: reset = 1;

            T0: reset = 0;

            // Write Value 1 (0x88888888 to 0x14) 
            T1: begin in_port_value = 32'h00000014; in_port_out = 1; mar_in = 1; end
            T2: begin in_port_value = 32'h88888888; in_port_out = 1; mdr_in = 1; read = 0; end
            T3: begin write = 1; end

            // Write Value 2 (0xAAAAAAAA to 0x18) 
            T4: begin in_port_value = 32'h00000018; in_port_out = 1; mar_in = 1; end
            T5: begin in_port_value = 32'hAAAAAAAA; in_port_out = 1; mdr_in = 1; read = 0; end
            T6: begin write = 1; end

            //  Read Value 1 (from 0x14) 
            T7: begin in_port_value = 32'h00000014; in_port_out = 1; mar_in = 1; end
            T8: begin read = 1; end // Request data
            T9: begin read = 1; mdr_in = 1; end // Capture data
            T10: begin mdr_out = 1; end // Show on bus

            //  Read Value 2 (from 0x18) 
            T11: begin in_port_value = 32'h00000018; in_port_out = 1; mar_in = 1; end
            T12: begin read = 1; end // Request data
            T13: begin read = 1; mdr_in = 1; end // Capture data
            
            Stop: begin mdr_out = 1; end // Show final value on bus
        endcase
    end

    initial begin
        $dumpfile("waves/p2/loadstore.vcd");
        $dumpvars(0, tb_ram);
    end
endmodule **/