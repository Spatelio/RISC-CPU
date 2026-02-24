`timescale 1ns/10ps

module shift_rotate_tb;
    parameter Default = 4'b0000, T0 = 4'b0001, T1 = 4'b0010, T2 = 4'b0011,
              T3 = 4'b0100, T4 = 4'b0101, T5 = 4'b0110, Stop = 4'b0111;

    reg [3:0] Present_state = Default;

    reg [31:0] A, B;
    reg [4:0] opcode;
    wire [63:0] C;

    alu dut (
        .A(A),
        .B(B),
        .opcode(opcode),
        .C(C)
    );

    // opcode values
    localparam SHR  = 5'b00110;
    localparam SHRA = 5'b00111;
    localparam SHL  = 5'b01000;
    localparam ROTR = 5'b01001;
    localparam ROTL = 5'b01010;

    // fake clock
    reg clk;
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    always @(posedge clk) begin
        case (Present_state)
            Default: Present_state <= T0;
            T0: Present_state <= T1;
            T1: Present_state <= T2;
            T2: Present_state <= T3;
            T3: Present_state <= T4;
            T4: Present_state <= T5;
            T5: Present_state <= Stop;
            Stop: $stop;
        endcase
    end

    always @(Present_state) begin
        case (Present_state)
            Default: begin
                A = 32'b0; B = 32'b0; opcode = 5'b0;
            end

            // SHR: A >> 4
            T0: begin
                A = 32'h8000_000F;
                B = 32'd4;
                opcode = SHR;
            end

            T1: begin
                if (C[31:0] !== (32'h8000_000F >> 4)) begin
                    $display("FAIL(SHR): expected %h got %h", (32'h8000_000F >> 4), C[31:0]);
                    $stop;
                end else $display("PASS(SHR): %h", C[31:0]);
            end

            // signed >>> 4 preserve sign
            T2: begin
                A = 32'hF000_0000;     //negative
                B = 32'd4;
                opcode = SHRA;
            end

            T3: begin
                if (C[31:0] !== ($signed(32'hF000_0000) >>> 4)) begin
                    $display("FAIL(SHRA): expected %h got %h", ($signed(32'hF000_0000) >>> 4), C[31:0]);
                    $stop;
                end else $display("PASS(SHRA): %h", C[31:0]);
            end

            // SHL: A << 3
            T4: begin
                A = 32'h0000_0001;
                B = 32'd3;
                opcode = SHL;
            end

            T5: begin
                if (C[31:0] !== (32'h0000_0001 << 3)) begin
                    $display("FAIL(SHL): expected %h got %h", (32'h0000_0001 << 3), C[31:0]);
                    $stop;
                end else $display("PASS(SHL): %h", C[31:0]);

                A = 32'h8000_0001;
                B = 32'd1;

                opcode = ROTR;
                #1;
                if (C[31:0] !== ((32'h8000_0001 >> 1) | (32'h8000_0001 << 31))) begin
                    $display("FAIL(ROTR)");
                    $stop;
                end else $display("PASS(ROTR): %h", C[31:0]);

                opcode = ROTL;
                #1;
                if (C[31:0] !== ((32'h8000_0001 << 1) | (32'h8000_0001 >> 31))) begin
                    $display("FAIL(ROTL)");
                    $stop;
                end else $display("PASS(ROTL): %h", C[31:0]);
            end

            Stop: begin end
        endcase
    end
endmodule