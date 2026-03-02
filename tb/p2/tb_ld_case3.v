`timescale 1ns/10ps

module tb_ld_case3;

    parameter Default = 5'd0,
              T_RESET = 5'd31,
              // Instruction 0: ldi R2, 0x57
              T0  = 5'd1,  T1  = 5'd2,  T2  = 5'd3,  T3  = 5'd4,
              T4  = 5'd5,  T5  = 5'd6,  T6  = 5'd7,
              Stop = 5'd18;

    reg [4:0] Present_state = Default;

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
        .hi_out(hi_out), .lo_out(lo_out),
        .zhi_out(zhi_out), .zlo_out(zlo_out),
        .in_port_data_in(in_port_data_in),
        .out_port_in(out_port_in),
        .out_port_data_out(out_port_data_out),
        .con_in(con_in),
        .con_ff_out(con_ff_out),
        .bus_out(bus_out), .mdr_q(mdr_q)
    );

    initial begin clk = 0; forever #10 clk = ~clk; end

    initial begin
        // Instruction 1: ldi R2, 0x65  (opcode=10010, Ra=2, Rb=0, C=0x65)
        uut.u_ram.memData[9'h000] = {5'b10010, 4'd7, 4'd0, 19'h065};
        uut.u_ram.memData[9'h065] = 32'h0000002B;
    end

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
            T6:       Present_state <= Stop;  // ldi done
            Stop:     $finish;
        endcase
    end

    always @(Present_state) begin
        {gra, grb, grc, rin, rout, ba_out}            = 6'b0;
        {pc_in, ir_in, y_in, mar_in, hi_in, lo_in}    = 6'b0;
        {zhi_in, zlo_in}                               = 2'b0;
        {mdr_in, mdr_out, read, write, pc_out, c_out}  = 6'b0;
        {in_port_out, out_port_in, con_in}             = 3'b0;
        {zlo_out, zhi_out, hi_out, lo_out}             = 4'b0;
        alu_opcode      = 5'b00000;
        reset           = 0;
        in_port_data_in = 32'b0;

        case (Present_state)
            Default:  reset = 1;
            T_RESET:  reset = 1;

            T0: begin
                pc_out     = 1;
                mar_in     = 1;
                alu_opcode = 5'b10000; // INC
                zlo_in     = 1;
            end
            T1: begin
                zlo_out = 1;
                pc_in   = 1;
                read    = 1;
            end
            T2: begin
                read   = 1;
                mdr_in = 1;
            end
            T3: begin
                mdr_out = 1;
                ir_in   = 1;
            end
            T4: begin
                grb    = 1;
                ba_out = 1;
                y_in   = 1;
            end
            T5: begin
                c_out      = 1;
                alu_opcode = 5'b00000; // ADD
                zlo_in     = 1;
            end
            // ldi: result goes straight to Ra (R7)
            T6: begin
                zlo_out = 1;
                gra     = 1;
                rin     = 1;
            end
        endcase
    end

    initial begin
        $dumpfile("waves/p2/ld_case3.vcd");
        $dumpvars(0, tb_ld_case3);
    end

endmodule