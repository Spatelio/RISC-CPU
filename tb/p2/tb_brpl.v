`timescale 1ns/10ps

module tb_brpl;

    parameter Default = 5'd0,
              T_RESET = 5'd31,
              // Instruction brzr
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
            T6:       Present_state <= Stop;
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

            // PCout, MARin, IncPC, Zin
            T0: begin
                pc_out     = 1;
                mar_in     = 1;
                alu_opcode = 5'b10000; // INC
                zlo_in     = 1;
                force uut.u_regs.GEN_REGS[3].u_reg.q = 32'h0FFFFFFB;
            end
            // Zlowout, PCin, Read, Mdatain[31..0], MDRin
            T1: begin
                zlo_out = 1;
                pc_in   = 1;
                read    = 1;
                mdr_in  = 1;
            end
            // MDRout, IRin
            T2: begin
                mdr_out = 1;
                ir_in = 1;
            end
            T3: begin //Gra, Rout, CONin
                gra = 1;
                rout = 1;
                con_in = 1;
            end
            T4: begin //PCout, Yin
                pc_out = 1;
                y_in = 1;
            end
            T5: begin //Cout add, zin
                c_out = 1;
                alu_opcode = 5'b00000;
                zlo_in = 1;
            end 
            T6: begin //zlowout, con->pcin
                //maybe zlo only write if con = 1
                //pc only read if con =1
                zlo_out = con_ff_out;
                pc_in = con_ff_out;
            end
        endcase
    end

    initial begin
        $dumpfile("waves/p2/brpl.vcd");
        $dumpvars(0, tb_brpl);
    end

endmodule