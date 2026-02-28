`timescale 1ns/10ps

module tb_ram_fsm;
    // Define States
    parameter Default = 4'b0000, T0 = 4'b0001, T1 = 4'b0010, T2 = 4'b0011, 
              T3 = 4'b0100, T4 = 4'b0101, T5 = 4'b0110, T6 = 4'b0111, T7 = 4'b1000, Stop = 4'b1001;

    reg [3:0] Present_state = Default;

    // -- Datapath Inputs --
    reg clk, reset;
    reg [15:0] r_in;
    reg pc_in, ir_in, y_in, mar_in, hi_in, lo_in, zhi_in, zlo_in;
    reg pc_start; // Added based on previous context
    reg mdr_in, mdr_out, read, write; // Added write
    reg [4:0] alu_opcode;
    reg [31:0] mdatain;
    
    // Bus Control Inputs
    reg [15:0] r_out;
    reg hi_out, lo_out, zhi_out, zlo_out, pc_out;
    reg in_port_out, c_out;
    reg [31:0] in_port_value;
    reg [31:0] c_signext;

    // -- Datapath Outputs --
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
        .read(read), .write(write), // Ensure write is connected!
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

    // State Transition Logic
    always @(posedge clk) begin
        case (Present_state)
            Default: Present_state <= T0;
            T0: Present_state <= T1;
            T1: Present_state <= T2;
            T2: Present_state <= T3;
            T3: Present_state <= T4;
            T4: Present_state <= T5;
            T5: Present_state <= T6;
            T6: Present_state <= T7;
            T7: Present_state <= Stop;
            Stop: $stop; // Stop simulation
        endcase
    end

    // State Control Logic
    always @(Present_state) begin
        // default assignments (reset all signals to 0 to prevent latches)
        reset = 0;
        r_in = 0; r_out = 0;
        pc_in = 0; ir_in = 0; y_in = 0; mar_in = 0; hi_in = 0; lo_in = 0; zhi_in = 0; zlo_in = 0;
        pc_out = 0; hi_out = 0; lo_out = 0; zhi_out = 0; zlo_out = 0; pc_start = 0;
        mdr_in = 0; mdr_out = 0; read = 0; write = 0;
        alu_opcode = 0; mdatain = 0;
        in_port_out = 0; c_out = 0; in_port_value = 0; c_signext = 0;

        case (Present_state)
            Default: begin
                reset = 1;
            end

            T0: begin 
                // Just release reset
                reset = 0;
            end

            T1: begin 
                // Load Address 0x14 into MAR
                // Bus <- In_Port (0x14)
                // MAR <- Bus
                in_port_value = 32'h00000014;
                in_port_out = 1; 
                mar_in = 1;
            end

            T2: begin 
                // Load Data 0x88888888 into MDR
                // Bus <- In_Port (0x88...)
                // MDR <- Bus (read=0 selects Bus input)
                in_port_value = 32'h88888888;
                in_port_out = 1;
                mdr_in = 1;
                read = 0; 
            end

            T3: begin 
                // Write MDR contents to RAM
                // MAR holds 0x14, MDR holds 0x88...
                write = 1;
            end

            T4: begin 
                // Clear MDR to 0x00 to prove the read works
                in_port_value = 32'h00000000;
                in_port_out = 1;
                mdr_in = 1; 
                read = 0;
            end

            T5: begin 
                //Ask RAM for data
                read = 1;   
                mdr_in = 0; // Don't capture yet
            end

            T6: begin   // Insert a new state here
                read = 1;   // Keep reading
                mdr_in = 1; // capture it
            end

            T7: begin 
                // Output MDR to Bus for 
                mdr_out = 1;
            end

            Stop: begin
                // Hold state
            end
        endcase
    end

    // Waveform Dump
    initial begin
        $dumpfile("waves/p2/ram_test.vcd");
        $dumpvars(0, tb_ram_fsm);
    end
endmodule