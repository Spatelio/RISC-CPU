`timescale 1ns/10ps

module datapath_or_tb;    
    parameter Default = 4'b0000, T0 = 4'b0001, T1 = 4'b0010, T2 = 4'b0011,
              T3 = 4'b0100, T4 = 4'b0101, T5 = 4'b0110, T6 = 4'b0111,
              T7 = 4'b1000, T8 = 4'b1001, T9 = 4'b1010, Stop = 4'b1011;
    
    reg [3:0] Present_state = Default;
     
    reg clk, reset;
    reg [15:0] r_in, r_out;
    reg pc_in, ir_in, y_in, mar_in, hi_in, lo_in, zhi_in, zlo_in;
    reg pc_out, hi_out, lo_out, zhi_out, zlo_out;
    reg mdr_in, mdr_out, read;
    reg [4:0] alu_opcode;
    reg [31:0] mdatain;

    // Simulation-only inputs for phase 2 ports not used in this test
    reg in_port_out;
    reg c_out;
    reg [31:0] in_port_value;
    reg [31:0] c_signext;

    // Outputs
    wire [31:0] bus_out;
    wire bus_valid, bus_multi;
    wire [31:0] mdr_q;

    // Instantiate Datapath
    datapath uut (
        .clk(clk),
        .reset(reset),
        .r_in(r_in),
        .pc_in(pc_in),
        .ir_in(ir_in),
        .y_in(y_in),
        .mar_in(mar_in),
        .hi_in(hi_in),
        .lo_in(lo_in),
        .zhi_in(zhi_in),
        .zlo_in(zlo_in),
        .alu_opcode(alu_opcode),
        .mdr_in(mdr_in),
        .mdr_out(mdr_out),
        .read(read),
        .mdatain(mdatain),
        .r_out(r_out),
        .hi_out(hi_out),
        .lo_out(lo_out),
        .zhi_out(zhi_out),
        .zlo_out(zlo_out),
        .pc_out(pc_out),
        .in_port_out(in_port_out),
        .c_out(c_out),
        .in_port_value(in_port_value),
        .c_signext(c_signext),
        .bus_out(bus_out),
        .bus_valid(bus_valid),
        .bus_multi(bus_multi),
        .mdr_q(mdr_q)
    );

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
            T7: Present_state <= T8;
            T8: Present_state <= T9;
            T9: Present_state <= Stop;
            Stop: $finish;
        endcase
    end
    
    always @(Present_state) begin
        case (Present_state)
            Default: begin
                reset = 1;
                r_in = 16'b0; r_out = 16'b0;
                pc_in = 0; ir_in = 0; y_in = 0; mar_in = 0;
                hi_in = 0; lo_in = 0; zhi_in = 0; zlo_in = 0;
                pc_out = 0; hi_out = 0; lo_out = 0; zhi_out = 0; zlo_out = 0;
                mdr_in = 0; mdr_out = 0; read = 0;
                alu_opcode = 5'b00000;
                mdatain = 32'b0;
                in_port_out = 0; c_out = 0;
                in_port_value = 32'b0; c_signext = 32'b0;
            end
            
            T0: reset = 0; // Release Reset
            
            T1: begin // Load 5 into MDR
                mdatain = 32'h00000005;
                read = 1; mdr_in = 1;
            end
            
            T2: begin // MDR writes to Bus, R5 reads from Bus
                read = 0; mdr_in = 0;
                mdr_out = 1; r_in[5] = 1;
            end
            
            T3: begin // Load 3 into MDR
                mdr_out = 0; r_in[5] = 0;
                mdatain = 32'h00000003; 
                read = 1; mdr_in = 1;
            end
            
            T4: begin // MDR writes to Bus, R6 reads from bus
                read = 0; mdr_in = 0;
                mdr_out = 1; r_in[6] = 1;
            end
            
            T5: begin // R6 -> Bus, Bus -> Y
                mdr_out = 0; r_in[6] = 0;
                r_out[5] = 1; y_in = 1; 
            end
            
            T6: begin // R6 -> Bus
                r_out[5] = 0; y_in = 0;
                r_out[6] = 1; 
            end
            
            T7: begin
                // Wait 
            end
            
            T8: begin // Capture ALU result into ZLO
                alu_opcode = 5'b00101; 
                zlo_in = 1;
            end
            
            T9: begin // ZLO writes to Bus, R7 reads from Bus
                zlo_in = 0; r_out[6] = 0; 
                zlo_out = 1; r_in[2] = 1; 
            end
            
            Stop: begin
                zlo_out = 0; r_in[2] = 0;
            end
        endcase
    end

    initial begin
        $dumpfile("waves/or.vcd"); // Name of the output waveform file
        $dumpvars(0, datapath_or_tb); // 0 dumps all signals in the module and below
    end
    
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end
endmodule