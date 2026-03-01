`timescale 1ns/10ps

module tb_new_add;
    // States
    parameter Default     = 4'b0000,
              T0_Reset    = 4'b0001,
              T1_LoadIR   = 4'b0010,
              T2_Init_R2  = 4'b0011, // Initialize R2 (Operand C)
              T3_Init_R4  = 4'b0100, // Initialize R4 (Operand B)
              T4_Load_Y   = 4'b0101, // Move R4 to Y
              T5_Add      = 4'b0110, // Add R2 to Y, store in Z
              T6_Store_R7 = 4'b0111, // Store Z into R7
              Stop        = 4'b1000;

    reg [3:0] Present_state = Default;

    //  Control Signals 
    reg clk, reset;
    reg gra, grb, grc, rin, rout, ba_out;
    reg pc_in, ir_in, y_in, mar_in, hi_in, lo_in, zhi_in, zlo_in;
    reg pc_start, mdr_in, mdr_out, read, write, pc_out, in_port_out, c_out;
    reg [31:0] in_port_value;

    reg zlo_out, zhi_out;

    //  Outputs 
    wire [31:0] bus_out;
    wire [31:0] mdr_q;

    // Instantiate Datapath
    datapath uut (
        .clk(clk), .reset(reset),
        .gra(gra), .grb(grb), .grc(grc), .rin(rin), .rout(rout), .ba_out(ba_out),
        .pc_in(pc_in), .ir_in(ir_in), .y_in(y_in), .mar_in(mar_in),
        .hi_in(hi_in), .lo_in(lo_in), .zhi_in(zhi_in), .zlo_in(zlo_in),
        .pc_start(pc_start),
        .mdr_in(mdr_in), .mdr_out(mdr_out), .read(read), .write(write),
        .in_port_out(in_port_out), .c_out(c_out), .in_port_value(in_port_value),
        .bus_out(bus_out), .mdr_q(mdr_q),
        .zlo_out(zlo_out), .zhi_out(zhi_out)
    );

    // Clock Generation
    initial begin clk = 0; forever #10 clk = ~clk; end

    // State Transition Logic
    always @(posedge clk) begin
        if (reset) Present_state <= Default;
        else begin
            case (Present_state)
                Default:     Present_state <= T0_Reset;
                T0_Reset:    Present_state <= T1_LoadIR;
                T1_LoadIR:   Present_state <= T2_Init_R2;
                T2_Init_R2:  Present_state <= T3_Init_R4;
                T3_Init_R4:  Present_state <= T4_Load_Y;
                T4_Load_Y:   Present_state <= T5_Add;
                T5_Add:      Present_state <= T6_Store_R7;
                T6_Store_R7: Present_state <= Stop;
                Stop:        $finish;
            endcase
        end
    end

    // Control Logic
    always @(Present_state) begin
        // 1. Clear all control signals to 0 to prevent latches
        {gra, grb, grc, rin, rout, ba_out} = 0;
        {pc_in, ir_in, y_in, mar_in, hi_in, lo_in, zhi_in, zlo_in} = 0;
        {pc_start, mdr_in, mdr_out, read, write, pc_out, in_port_out, c_out} = 0;
        {zlo_out, zhi_out} = 0;
        in_port_value = 0;
        reset = 0; // Default reset state

        case (Present_state)
            Default: reset = 1; // Assert reset
            T0_Reset: reset = 0; // De-assert reset

            // 
            // Set IR instruction and load it into the IR register
            // Instruction: ADD R7, R4, R2 
            // Encoding: Op=00000, Ra=0111(7), Rb=0100(4), Rc=0010(2)
            // 
            T1_LoadIR: begin
                // Drive the instruction onto the bus via InPort simulation
                in_port_value = {5'b00000, 4'd7, 4'd4, 4'd2, 15'b0}; 
                in_port_out = 1; 
                ir_in = 1; // Latch into IR
            end

            T2_Init_R2: begin
                in_port_value = 32'h00000005; 
                in_port_out = 1;
                grc = 1; 
                rin = 1; 
            end

            T3_Init_R4: begin
                in_port_value = 32'h0000000A; // Load value 10
                in_port_out = 1;
                grb = 1; // Selects R4
                rin = 1;
            end

            T4_Load_Y: begin
                grb = 1;  // Select R4
                rout = 1; // Output to Bus
                y_in = 1; // Latch into Y
            end

            T5_Add: begin
                grc = 1;         // Select R2
                rout = 1;        // Output to Bus 
                //these should get results without alu opcode being set now
                zhi_in = 1;      // Latch High bits (if 64-bit result)
                zlo_in = 1;      // Latch Low bits (Result)
            end

            T6_Store_R7: begin
                zlo_out = 1; // Put ALU output (Z register) onto the bus
                gra = 1;     // Select R7 (Destination)
                rin = 1;     // Write from Bus to R7
            end
        endcase
    end

    initial begin
        $dumpfile("waves/p2/new_add.vcd");
        $dumpvars(0, tb_new_add);
    end
endmodule