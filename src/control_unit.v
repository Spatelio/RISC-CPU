module control_unit(
    // Select and Encode Controls
    output  reg        gra, grb, grc,
    output  reg        rin, rout, ba_out, 

    // Remaining Phase 1 register enables
    output  reg        pc_in, ir_in, y_in, mar_in, 
    output  reg        hi_in, lo_in, zhi_in, zlo_in,
    output  reg        hi_out, lo_out,
    output  reg        pc_out,
    
    //for bus
    output  reg        zhi_out, zlo_out,
    output  reg [4:0]  alu_opcode, // Alias

    // MDR and RAM Controls
    output  reg        mdr_in, mdr_out, read, write,

    // I/O and Constant Controls
    output  reg        in_port_out, c_out,
    output  reg        out_port_in,

    // Outputs for simulation
    //conff io
    output  reg        con_in,

    // mdr_q: fetched word; insn latched in S_DECODE drives reg/immediate decode for all execute states.
    input  wire [31:0] mdr_q,
    output reg  [31:0] insn,
    input  wire        con_ff_out,
    input wire stop, //stop signal
    input wire reset, //reset signal
    input wire clk
);

    // ALU opcodes (match alu.v)
    localparam ALU_ADD  = 5'b00000;
    localparam ALU_SUB  = 5'b00001;
    localparam ALU_AND  = 5'b00010;
    localparam ALU_OR   = 5'b00011;
    localparam ALU_DIV  = 5'b01100;
    localparam ALU_MUL  = 5'b01101;
    localparam ALU_NEG  = 5'b01110;
    localparam ALU_NOT  = 5'b01111;
    localparam ALU_INC  = 5'b10000;

    // 6-bit state machine
    localparam S_RESET  = 6'd0;
    localparam S_FETCH0 = 6'd1;
    localparam S_FETCH1 = 6'd2;
    localparam S_FETCH2 = 6'd3;

    localparam S_R0 = 6'd4;
    localparam S_R1 = 6'd5;
    localparam S_R2 = 6'd6;

    localparam S_I0 = 6'd7;
    localparam S_I1 = 6'd8;
    localparam S_I2 = 6'd9;

    localparam S_MUL0 = 6'd10;
    localparam S_MUL1 = 6'd11;

    localparam S_DIV0 = 6'd12;
    localparam S_DIV1 = 6'd13;

    localparam S_NEG0 = 6'd14;
    localparam S_NEG1 = 6'd15;
    localparam S_NEG2 = 6'd16;

    localparam S_NOT0 = 6'd17;
    localparam S_NOT1 = 6'd18;
    localparam S_NOT2 = 6'd19;

    localparam S_LD0 = 6'd20;
    localparam S_LD1 = 6'd21;
    localparam S_LD2 = 6'd22;
    localparam S_LD3 = 6'd23;
    localparam S_LD4 = 6'd24;

    localparam S_LDI0 = 6'd25;
    localparam S_LDI1 = 6'd26;
    localparam S_LDI2 = 6'd27;

    localparam S_ST0 = 6'd28;
    localparam S_ST1 = 6'd29;
    localparam S_ST2 = 6'd30;
    localparam S_ST3 = 6'd31;
    localparam S_ST4 = 6'd32;

    localparam S_JAL0 = 6'd33;
    localparam S_JAL1 = 6'd34;

    localparam S_JR0 = 6'd35;

    localparam S_BR0 = 6'd36;
    localparam S_BR1 = 6'd37;
    localparam S_BR2 = 6'd38;
    localparam S_BR3 = 6'd39;

    localparam S_IN0 = 6'd40;
    localparam S_OUT0 = 6'd41;

    localparam S_MFHI0 = 6'd42;
    localparam S_MFLO0 = 6'd43;

    // One cycle after MDR→IR so ir[31:27] is valid before dispatch
    localparam S_DECODE = 6'd44;

    localparam S_HALT = 6'd45;

    // Primary opcode = ir[31:27] (same as SRC-ASM / alu R-type codes)
    parameter ADD    = 5'b00000;
    parameter SUB    = 5'b00001;
    parameter AND    = 5'b00010;
    parameter OR     = 5'b00011;
    parameter SHR    = 5'b00100;
    parameter SHRA   = 5'b00101;
    parameter SHL    = 5'b00110;
    parameter ROTR   = 5'b00111;
    parameter ROTL   = 5'b01000;
    parameter ADDI   = 5'b01001;
    parameter ANDI   = 5'b01010;
    parameter ORI    = 5'b01011;
    parameter DIV    = 5'b01100;
    parameter MUL    = 5'b01101;
    parameter NEG    = 5'b01110;
    parameter NOT    = 5'b01111;
    parameter LD     = 5'b10000;
    parameter LDI    = 5'b10001;
    parameter ST     = 5'b10010;
    parameter JAL    = 5'b10011;
    parameter JR     = 5'b10100;
    parameter BRANCH = 5'b10101;
    parameter IN     = 5'b10110;
    parameter OUT    = 5'b10111;
    parameter MFHI   = 5'b11000;
    parameter MFLO   = 5'b11001;
    parameter NOP    = 5'b11010;
    parameter HALT   = 5'b11011;

    reg [5:0] presentState = S_RESET;

    // Latch at end of fetch2 (same cycle IR/MDR hold the new word); do not use S_DECODE (ordering vs. state reg).
    always @(posedge clk, posedge reset) begin
        if (reset)
            insn <= 32'b0;
        else if (presentState == S_FETCH2)
            insn <= mdr_q;
    end

    function automatic [4:0] itype_alu_op;
        input [4:0] op;
        begin
            case (op)
                ADDI: itype_alu_op = ALU_ADD;
                ANDI: itype_alu_op = ALU_AND;
                ORI:  itype_alu_op = ALU_OR;
                default: itype_alu_op = ALU_ADD;
            endcase
        end
    endfunction

    // Next-state (decode) — combinational from presentState + ir
    reg [5:0] nextState;
    always @(*) begin
        nextState = presentState;
        case (presentState)
            S_RESET:  nextState = S_FETCH0;
            S_FETCH0: nextState = S_FETCH1;
            S_FETCH1: nextState = S_FETCH2;
            S_FETCH2: nextState = S_DECODE;
            S_DECODE: begin
                case (mdr_q[31:27])
                    ADD, SUB, AND, OR, SHR, SHRA, SHL, ROTR, ROTL: nextState = S_R0;
                    ADDI, ANDI, ORI: nextState = S_I0;
                    DIV: nextState = S_DIV0;
                    MUL: nextState = S_MUL0;
                    NEG: nextState = S_NEG0;
                    NOT: nextState = S_NOT0;
                    LD:  nextState = S_LD0;
                    LDI: nextState = S_LDI0;
                    ST:  nextState = S_ST0;
                    JAL: nextState = S_JAL0;
                    JR:  nextState = S_JR0;
                    BRANCH: nextState = S_BR0;
                    IN:  nextState = S_IN0;
                    OUT: nextState = S_OUT0;
                    MFHI: nextState = S_MFHI0;
                    MFLO: nextState = S_MFLO0;
                    NOP: nextState = S_FETCH0;
                    HALT: nextState = S_HALT;
                    default: nextState = S_FETCH0;
                endcase
            end

            S_R0:    nextState = S_R1;
            S_R1:    nextState = S_R2;
            S_R2:    nextState = S_FETCH0;

            S_I0:    nextState = S_I1;
            S_I1:    nextState = S_I2;
            S_I2:    nextState = S_FETCH0;

            S_MUL0:  nextState = S_MUL1;
            S_MUL1:  nextState = S_FETCH0;

            S_DIV0:  nextState = S_DIV1;
            S_DIV1:  nextState = S_FETCH0;

            S_NEG0:  nextState = S_NEG1;
            S_NEG1:  nextState = S_NEG2;
            S_NEG2:  nextState = S_FETCH0;

            S_NOT0:  nextState = S_NOT1;
            S_NOT1:  nextState = S_NOT2;
            S_NOT2:  nextState = S_FETCH0;

            S_LD0:   nextState = S_LD1;
            S_LD1:   nextState = S_LD2;
            S_LD2:   nextState = S_LD3;
            S_LD3:   nextState = S_LD4;
            S_LD4:   nextState = S_FETCH0;

            S_LDI0:  nextState = S_LDI1;
            S_LDI1:  nextState = S_LDI2;
            S_LDI2:  nextState = S_FETCH0;

            S_ST0:   nextState = S_ST1;
            S_ST1:   nextState = S_ST2;
            S_ST2:   nextState = S_ST3;
            S_ST3:   nextState = S_ST4;
            S_ST4:   nextState = S_FETCH0;

            S_JAL0:  nextState = S_JAL1;
            S_JAL1:  nextState = S_FETCH0;

            S_JR0:   nextState = S_FETCH0;

            S_BR0:   nextState = S_BR1;
            S_BR1:   nextState = S_BR2;
            S_BR2:   nextState = S_BR3;
            S_BR3:   nextState = S_FETCH0;

            S_IN0:   nextState = S_FETCH0;
            S_OUT0:  nextState = S_FETCH0;

            S_MFHI0: nextState = S_FETCH0;
            S_MFLO0: nextState = S_FETCH0;

            S_HALT:  nextState = S_HALT;

            default: nextState = S_FETCH0;
        endcase
    end

    always @(posedge clk, posedge reset) begin
        if (reset == 1'b1)
            presentState <= S_RESET;
        else
            presentState <= nextState;
    end

    // Control outputs — same micro-op style as tb/p2
    always @(*) begin
        gra = 1'b0; grb = 1'b0; grc = 1'b0;
        rin = 1'b0; rout = 1'b0; ba_out = 1'b0;
        pc_in = 1'b0; ir_in = 1'b0; y_in = 1'b0; mar_in = 1'b0;
        hi_in = 1'b0; lo_in = 1'b0; zhi_in = 1'b0; zlo_in = 1'b0;
        hi_out = 1'b0; lo_out = 1'b0;
        pc_out = 1'b0;
        zhi_out = 1'b0; zlo_out = 1'b0;
        alu_opcode = ALU_ADD;
        mdr_in = 1'b0; mdr_out = 1'b0; read = 1'b0; write = 1'b0;
        in_port_out = 1'b0; c_out = 1'b0;
        out_port_in = 1'b0;
        con_in = 1'b0;

        if (!reset) begin
            case (presentState)
                // Fetch (tb_addi / tb_ld_case1)
                S_FETCH0: begin
                    pc_out     = 1'b1;
                    mar_in     = 1'b1;
                    alu_opcode = ALU_INC;
                    zlo_in     = 1'b1;
                end
                S_FETCH1: begin
                    zlo_out = 1'b1;
                    pc_in   = 1'b1;
                    read    = 1'b1;
                    mdr_in  = 1'b1;
                end
                S_FETCH2: begin
                    mdr_out = 1'b1;
                    ir_in   = 1'b1;
                end

                // R-type: Grb,rout,Yin → Grc,rout,ALU,Zin → Zlowout,Gra,Rin
                S_R0: begin
                    grb  = 1'b1;
                    rout = 1'b1;
                    y_in = 1'b1;
                end
                S_R1: begin
                    grc        = 1'b1;
                    rout       = 1'b1;
                    alu_opcode = insn[31:27];
                    zlo_in     = 1'b1;
                end
                S_R2: begin
                    zlo_out = 1'b1;
                    gra     = 1'b1;
                    rin     = 1'b1;
                end

                // I-type (ADDI / ANDI / ORI)
                S_I0: begin
                    grb  = 1'b1;
                    rout = 1'b1;
                    y_in = 1'b1;
                end
                S_I1: begin
                    c_out      = 1'b1;
                    alu_opcode = itype_alu_op(insn[31:27]);
                    zlo_in     = 1'b1;
                end
                S_I2: begin
                    zlo_out = 1'b1;
                    gra     = 1'b1;
                    rin     = 1'b1;
                end

                // MUL (tb_mfhi T3–T4 execute)
                S_MUL0: begin
                    grb  = 1'b1;
                    rout = 1'b1;
                    y_in = 1'b1;
                end
                S_MUL1: begin
                    gra        = 1'b1;
                    rout       = 1'b1;
                    alu_opcode = ALU_MUL;
                    zlo_in     = 1'b1;
                    zhi_in     = 1'b1;
                    hi_in      = 1'b1;
                    lo_in      = 1'b1;
                end

                // DIV
                S_DIV0: begin
                    grb  = 1'b1;
                    rout = 1'b1;
                    y_in = 1'b1;
                end
                S_DIV1: begin
                    gra        = 1'b1;
                    rout       = 1'b1;
                    alu_opcode = ALU_DIV;
                    zlo_in     = 1'b1;
                    zhi_in     = 1'b1;
                    hi_in      = 1'b1;
                    lo_in      = 1'b1;
                end

                // NEG (datapath_neg style: Rb→Y, unary ALU, Z→Ra)
                S_NEG0: begin
                    grb  = 1'b1;
                    rout = 1'b1;
                    y_in = 1'b1;
                end
                S_NEG1: begin
                    alu_opcode = ALU_NEG;
                    zlo_in     = 1'b1;
                end
                S_NEG2: begin
                    zlo_out = 1'b1;
                    gra     = 1'b1;
                    rin     = 1'b1;
                end

                S_NOT0: begin
                    grb  = 1'b1;
                    rout = 1'b1;
                    y_in = 1'b1;
                end
                S_NOT1: begin
                    alu_opcode = ALU_NOT;
                    zlo_in     = 1'b1;
                end
                S_NOT2: begin
                    zlo_out = 1'b1;
                    gra     = 1'b1;
                    rin     = 1'b1;
                end

                // LD (tb_ld_case1)
                S_LD0: begin
                    grb    = 1'b1;
                    ba_out = 1'b1;
                    y_in   = 1'b1;
                end
                S_LD1: begin
                    c_out      = 1'b1;
                    alu_opcode = ALU_ADD;
                    zlo_in     = 1'b1;
                end
                S_LD2: begin
                    zlo_out = 1'b1;
                    mar_in  = 1'b1;
                end
                S_LD3: begin
                    read   = 1'b1;
                    mdr_in = 1'b1;
                end
                S_LD4: begin
                    mdr_out = 1'b1;
                    gra     = 1'b1;
                    rin     = 1'b1;
                end

                // LDI (tb_ld_case3)
                S_LDI0: begin
                    grb    = 1'b1;
                    ba_out = 1'b1;
                    y_in   = 1'b1;
                end
                S_LDI1: begin
                    c_out      = 1'b1;
                    alu_opcode = ALU_ADD;
                    zlo_in     = 1'b1;
                end
                S_LDI2: begin
                    zlo_out = 1'b1;
                    gra     = 1'b1;
                    rin     = 1'b1;
                end

                // ST (tb_st_case1)
                S_ST0: begin
                    grb    = 1'b1;
                    ba_out = 1'b1;
                    y_in   = 1'b1;
                end
                S_ST1: begin
                    c_out      = 1'b1;
                    alu_opcode = ALU_ADD;
                    zlo_in     = 1'b1;
                end
                S_ST2: begin
                    zlo_out = 1'b1;
                    mar_in  = 1'b1;
                end
                S_ST3: begin
                    gra    = 1'b1;
                    rout   = 1'b1;
                    mdr_in = 1'b1;
                end
                S_ST4: begin
                    write   = 1'b1;
                    mdr_out = 1'b1;
                end

                // JAL (tb_jal)
                S_JAL0: begin
                    pc_out = 1'b1;
                    grb    = 1'b1;
                    rin    = 1'b1;
                end
                S_JAL1: begin
                    gra    = 1'b1;
                    rout   = 1'b1;
                    pc_in  = 1'b1;
                end

                // JR (tb_jr)
                S_JR0: begin
                    gra    = 1'b1;
                    rout   = 1'b1;
                    pc_in  = 1'b1;
                end

                // Branch (tb_brzr)
                S_BR0: begin
                    gra    = 1'b1;
                    rout   = 1'b1;
                    con_in = 1'b1;
                end
                S_BR1: begin
                    pc_out = 1'b1;
                    y_in   = 1'b1;
                end
                S_BR2: begin
                    c_out      = 1'b1;
                    alu_opcode = ALU_ADD;
                    zlo_in     = 1'b1;
                end
                S_BR3: begin
                    zlo_out = con_ff_out;
                    pc_in   = con_ff_out;
                end

                // IN / OUT
                S_IN0: begin
                    gra         = 1'b1;
                    rin         = 1'b1;
                    in_port_out = 1'b1;
                end
                S_OUT0: begin
                    gra         = 1'b1;
                    rout        = 1'b1;
                    out_port_in = 1'b1;
                end

                S_MFHI0: begin
                    hi_out = 1'b1;
                    gra    = 1'b1;
                    rin    = 1'b1;
                end
                S_MFLO0: begin
                    lo_out = 1'b1;
                    gra    = 1'b1;
                    rin    = 1'b1;
                end

                default: ;
            endcase
        end
    end

endmodule
