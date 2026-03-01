`timescale 1ns/10ps

module tb_ld;
    // States
    parameter Default = 4'b0000,
          T0      = 4'b0001, T1 = 4'b0010, T2 = 4'b0011, T3 = 4'b0100,
          T4      = 4'b0101, T5 = 4'b0110, T6 = 4'b0111, T7 = 4'b1000,
          T8      = 4'b1001, T9 = 4'b1010, Stop = 4'b1011;

    reg [3:0] Present_state = Default;

    // control
    reg clk, reset;
    reg gra, grb, grc, rin, rout, ba_out;
    reg pc_in, ir_in, y_in, mar_in, hi_in, lo_in, zhi_in, zlo_in;
    reg mdr_in, mdr_out, read, write, pc_out, c_out;
    
    // I/O & CON Signals
    reg in_port_out;
    reg out_port_in;
    reg con_in;
    reg [31:0] in_port_data_in;
    
    reg [4:0] alu_opcode;
    reg zlo_out, zhi_out;

    //outputs
    wire [31:0] bus_out;
    wire [31:0] mdr_q;
    wire [31:0] out_port_data_out;
    wire        con_ff_out;

    // Instantiate Datapath
    datapath uut (
        .clk(clk), .reset(reset),
        .gra(gra), .grb(grb), .grc(grc), .rin(rin), .rout(rout), .ba_out(ba_out),
        .pc_in(pc_in), .ir_in(ir_in), .y_in(y_in), .mar_in(mar_in),
        .hi_in(hi_in), .lo_in(lo_in), .zhi_in(zhi_in), .zlo_in(zlo_in),
        .alu_opcode(alu_opcode),
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

    // Clock Generation
    initial begin clk = 0; forever #10 clk = ~clk; end

    // set ram instruction
    initial begin
    // 1. Initialize RAM with the LD instruction at the PC's address (e.g., address 0)
    // Format: [Opcode][Ra][Rb][Offset] -> Example: LD R7, 0x65(R0)
    // Assuming PC starts at 0, place the encoded instruction there:
        uut.u_ram.memData[9'h000] = 32'b00000_0111_0000_000000000001100101; 

    // 2. Initialize the target data at address 0x65
        uut.u_ram.memData[9'h65] = 32'h00000084; 

    // 3. Initialize the PC to 0 to start the fetch from the correct location
        uut.u_regs.u_pc.q = 32'h00000000; 
    end
    // State Transition
    always @(posedge clk) begin
        if (reset) Present_state <= Default;
        else begin
            case (Present_state)
                Default:     Present_state <= T0;
                T0:    Present_state <= T1;
                T1:   Present_state <= T2;
                T2:  Present_state <= T3;
                T3:  Present_state <= T4;
                T4:   Present_state <= T5;
                T5:      Present_state <= T6;
                T6: Present_state <= T7;
                T7:   Present_state <= T8;
                T8:   Present_state <= T9;
                T9:   Present_state <= Stop;
                Stop: $finish;
            endcase
        end
    end

    // Control Logic
    always @(Present_state) begin
    // Reset all controls to 0 at the start of each state
    {gra, grb, grc, rin, rout, ba_out} = 0;
    {pc_in, ir_in, y_in, mar_in, hi_in, lo_in, zhi_in, zlo_in} = 0;
    {mdr_in, mdr_out, read, write, pc_out, c_out} = 0;
    {in_port_out, out_port_in, con_in} = 0;
    {zlo_out, zhi_out} = 0;
    alu_opcode = 5'b00000; 
    reset = 0;

    case (Present_state)
        Default: reset = 1;

        // --- Instruction Fetch Phase ---
        // --- Instruction Fetch Phase ---
        T0: begin 
            // 1. Send PC to Memory Address Register (MAR)
            pc_out = 1; 
            mar_in = 1; 
            
            // 2. Increment PC: PC -> Bus -> ALU (INC) -> Zlo
            // Note: We reuse pc_out here. 
            alu_opcode = 5'b10000; // Opcode for INC
            zlo_in = 1;            // Latch result into Z-low
        end

        T1: begin 
            // 3. Read from Memory
            read = 1; 

            // 4. Update PC: Zlo -> Bus -> PC
            zlo_out = 1; 
            pc_in = 1; 
        end

        T2: begin 
            // 5. Capture Instruction in MDR
            read = 1; 
            mdr_in = 1; 
        end
        T3: begin 
            mdr_out = 1; ir_in = 1; 
        end

        // --- Instruction Execution Phase (ld) ---
        T4: begin // Get Base Register Address (R_bus = Rb)
            grb = 1; ba_out = 1; y_in = 1;
        end
        T5: begin // Add C (offset) to Y
            c_out = 1; alu_opcode = 5'b00000; // Assuming 00011 is ADD
            zlo_in = 1;
        end
        T6: begin // Move Effective Address to MAR
            zlo_out = 1; mar_in = 1;
        end
        T7: begin // Start RAM Read for Data
            read = 1;
        end
        T8: begin // Capture Data into MDR, then write to Reg
            read = 1; mdr_in = 1;
        end
        T9: begin // Move Data from MDR to Register Ra
            mdr_out = 1; gra = 1; rin = 1;
        end
    endcase
    end

    initial begin
        $dumpfile("waves/p2/ld.vcd");
        $dumpvars(0, tb_ld);
    end
endmodule