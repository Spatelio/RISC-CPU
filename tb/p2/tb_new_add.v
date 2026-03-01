`timescale 1ns/10ps

module tb_new_add;
    // States
    parameter Default     = 4'b0000,
              T0_Reset    = 4'b0001,
              T1_LoadIR   = 4'b0010,
              T2_Init_R2  = 4'b0011,
              T3_Init_R4  = 4'b0100,
              T4_Load_Y   = 4'b0101,
              T5_Add      = 4'b0110,
              T6_Store_R7 = 4'b0111,
              T7_Output_r7 = 4'b1000,
              Stop        = 4'b1001;

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

    // State Transition
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
                T6_Store_R7: Present_state <= T7_Output_r7;
                T7_Output_r7: Present_state <= Stop;
                Stop:        $finish;
            endcase
        end
    end

    // Control Logic
    always @(Present_state) begin
        // Reset controls
        {gra, grb, grc, rin, rout, ba_out} = 0;
        {pc_in, ir_in, y_in, mar_in, hi_in, lo_in, zhi_in, zlo_in} = 0;
        {mdr_in, mdr_out, read, write, pc_out, c_out} = 0;
        {in_port_out, out_port_in, con_in} = 0;
        {zlo_out, zhi_out} = 0;
        alu_opcode = 5'b00000;
        // Don't clear in_port_data_in here, as it needs to persist across states
        reset = 0;

        case (Present_state)
            Default: reset = 1; 

            // T0: Reset active. 
            // PRE-LOAD the Input Port with the Instruction for T1
            T0_Reset: begin
                reset = 0;
                // Prepare Instruction: ADD R7, R4, R2 (Op=0, Ra=7, Rb=4, Rc=2)
                in_port_data_in = {5'b00000, 4'd7, 4'd4, 4'd2, 15'b0}; 
            end

            T1_LoadIR: begin
                in_port_out = 1; // Put Instruction on Bus
                ir_in = 1;       // Latch into IR
                
                // Prepare Data for next step: 5
                in_port_data_in = 32'h00000005; 
            end

            T2_Init_R2: begin
                in_port_out = 1; // Put 5 on Bus
                grc = 1;         // Select R2
                rin = 1;         // Write R2
                
                // Prepare Data for next step: 10
                in_port_data_in = 32'h0000000A; 
            end

            T3_Init_R4: begin
                in_port_out = 1; // Put 10 on Bus
                grb = 1;         // Select R4
                rin = 1;         // Write R4
            end

            // T4: Move R4 to Y
            T4_Load_Y: begin
                grb = 1; 
                rout = 1; 
                y_in = 1; 
            end

            // T5: ADD R2 + Y -> Z
            T5_Add: begin
                grc = 1; 
                rout = 1; 
                alu_opcode = 5'b00000; 
                zhi_in = 1;      
                zlo_in = 1;      
            end

            // T6: Store Result -> R7
            T6_Store_R7: begin
                zlo_out = 1; 
                gra = 1; 
                rin = 1; 
            end
            T7_Output_r7: begin //to test outport logic
                gra = 1;
                rout = 1;
                out_port_in = 1;
            end
        endcase
    end

    initial begin
        $dumpfile("waves/p2/new_add.vcd");
        $dumpvars(0, tb_new_add);
    end
endmodule