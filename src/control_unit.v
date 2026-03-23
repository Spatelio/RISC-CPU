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

    //primary inputs
    input wire[31:0] ir, //whole ir
    input wire con_ff_out, //conditions
    input wire stop, //stop signal
    input wire reset //reset signal
);

    // INSTRUCTION OPCODES (Bits 31:27)
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

    // Start the FSM

endmodule