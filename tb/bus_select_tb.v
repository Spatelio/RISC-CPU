`timescale 1ns/10ps

module bus_select_tb;
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

    reg in_port_out, c_out;
    reg [31:0] in_port_value;
    reg [31:0] c_signext;

    wire [31:0] bus_out;
    wire bus_valid, bus_multi;
    wire [31:0] mdr_q;

    datapath uut (
        .clk(clk), .reset(reset),

        .r_in(r_in),
        .pc_in(pc_in), .ir_in(ir_in), .y_in(y_in), .mar_in(mar_in),
        .hi_in(hi_in), .lo_in(lo_in), .zhi_in(zhi_in), .zlo_in(zlo_in),

        .alu_opcode(alu_opcode),

        .mdr_in(mdr_in), .mdr_out(mdr_out), .read(read), .mdatain(mdatain),

        .r_out(r_out),
        .hi_out(hi_out), .lo_out(lo_out),
        .zhi_out(zhi_out), .zlo_out(zlo_out),
        .pc_out(pc_out),

        .in_port_out(in_port_out), .c_out(c_out),
        .in_port_value(in_port_value), .c_signext(c_signext),

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
            Stop: $stop;
        endcase
    end

    always @(Present_state) begin
        case (Present_state)
            Default: begin
                reset = 1;
                r_in = 16'b0; r_out = 16'b0;
                pc_in=0; ir_in=0; y_in=0; mar_in=0;
                hi_in=0; lo_in=0; zhi_in=0; zlo_in=0;
                pc_out=0; hi_out=0; lo_out=0; zhi_out=0; zlo_out=0;
                mdr_in=0; mdr_out=0; read=0;
                alu_opcode=5'b0;
                mdatain=32'b0;

                in_port_out=0; c_out=0;
                in_port_value=32'hDEAD_BEEF;
                c_signext=32'h0000_00AA;
            end

            T0: reset = 0;

            // preload R1 = 0x11111111 via MDR->bus->R1
            T1: begin
                mdatain = 32'h1111_1111;
                read = 1; mdr_in = 1;
            end
            T2: begin
                read = 0; mdr_in = 0;
                mdr_out = 1; r_in[1] = 1;
            end
            T3: begin
                mdr_out = 0; r_in[1] = 0;
            end

            // preload PC = 0x22222222 via MDR->bus->PC
            T4: begin
                mdatain = 32'h2222_2222;
                read = 1; mdr_in = 1;
            end
            T5: begin
                read = 0; mdr_in = 0;
                mdr_out = 1; pc_in = 1;
            end
            T6: begin
                mdr_out = 0; pc_in = 0;
            end

            // check R1out drives bus
            T7: begin
                r_out[1] = 1;
            end

            // check PCout drives bus
            T8: begin
                r_out[1] = 0;
                if (bus_out !== 32'h1111_1111) begin
                    $display("FAIL(BUS): R1out expected %h got %h", 32'h1111_1111, bus_out);
                    $stop;
                end else $display("PASS(BUS): R1out drove bus = %h", bus_out);

                pc_out = 1;
            end

            // check InPort and C sources + bus_multi
            T9: begin
                pc_out = 0;
                if (bus_out !== 32'h2222_2222) begin
                    $display("FAIL(BUS): PCout expected %h got %h", 32'h2222_2222, bus_out);
                    $stop;
                end else $display("PASS(BUS): PCout drove bus = %h", bus_out);

                in_port_out = 1;
            end

            Stop: begin
                in_port_out = 0;
                if (bus_out !== 32'hDEAD_BEEF) begin
                    $display("FAIL(BUS): InPort expected %h got %h", 32'hDEAD_BEEF, bus_out);
                    $stop;
                end else $display("PASS(BUS): In.Port drove bus = %h", bus_out);

                c_out = 1;
                #1;
                if (bus_out !== 32'h0000_00AA) begin
                    $display("FAIL(BUS): Cout expected %h got %h", 32'h0000_00AA, bus_out);
                    $stop;
                end else $display("PASS(BUS): Cout drove bus = %h", bus_out);

                // assert two sources together
                r_out[1] = 1;
                #1;
                if (bus_multi !== 1'b1) begin
                    $display("FAIL(BUS): expected bus_multi=1 when multiple outs asserted");
                    $stop;
                end else $display("PASS(BUS): bus_multi asserted when two sources enabled");

                c_out = 0;
                r_out[1] = 0;
            end
        endcase
    end

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end
endmodule