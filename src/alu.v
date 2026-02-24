module alu(
    input wire [31:0] A,          // Input from Y register
    input wire [31:0] B,          // Input from the bus
    input wire [4:0]  opcode,     // Operation code to select which operation to perform
    output reg [63:0] C           // 64-bit result (for multiplication and division)
);

    // Define operation codes
    parameter ADD    = 5'b00000; //tbd
    parameter SUB    = 5'b00001; //tbd
    parameter MUL    = 5'b00010; //tbd
    parameter DIV    = 5'b00011; //tbd
    parameter AND    = 5'b00100; //tbd
    parameter OR     = 5'b00101; //tbd
    parameter SHR    = 5'b00110; //tbd
    parameter SHRA   = 5'b00111; //tbd
    parameter SHIFTL = 5'b01000; //tbd
    parameter ROTR   = 5'b01001; //tbd
    parameter ROTL   = 5'b01010; //tbd
    parameter NEG    = 5'b01011; //tbd
    parameter NOT    = 5'b01100; //tbd

    // Wires for outputs from different functional units
    wire [31:0] add_result;
    wire [31:0] sub_result;
    wire [63:0] mul_result;
    wire [63:0] div_result;
    wire [31:0] and_result;
    wire [31:0] or_result;
    wire [31:0] neg_result;
    wire [31:0] not_result;
    wire [31:0] shr_result;
    wire [31:0] shra_result;
    wire [31:0] shiftl_result;
    wire [31:0] rotr_result;
    wire [31:0] rotl_result;

    // Instantiate adder module 
    adder add_unit(
        .A(A),
        .B(B),
        .sum(add_result)
    );

    // Instantiate subtractor module 
    subtractor sub_unit(
        .A(A),
        .B(B),
        .Result(sub_result)
    );

    // Instantiate multiplier module 
    mult mul_unit(
        .a(A),
        .b(B),
        .z(mul_result)
    );

    // Instantiate divider module 
    div div_unit(
        .dividend(A),
        .divisor(B),
        .z(div_result)
    );

    // Instantiate logical AND module 
    and_ and_unit(
        .A(A),
        .B(B),
        .C(and_result)
    );

    // Instantiate logical OR module 
    or_ or_unit(
        .A(A),
        .B(B),
        .C(or_result)
    );

    // Instantiate logical NOT module 
    not_ not_unit(
        .A(A),
        .C(not_result)
    );

    // Instantiate negate module 
    negate neg_unit(
        .A(A),
        .C(neg_result)
    );

    // Instantiate shift right module 
    shiftr shr_unit(
        .A(A),
        .B(B),  
        .C(shr_result)
    );

    // Instantiate shift right arithmetic module 
    shiftra shra_unit(
        .A(A),
        .B(B), 
        .C(shra_result)
    );

    // Instantiate shift left module 
    shiftl shiftl_unit(
        .A(A),
        .B(B),
        .C(shiftl_result)
    );

    // Instantiate rotate right module 
    rotr rotr_unit(
        .A(A),
        .B(B),
        .C(rotr_result)
    );

    // Instantiate rotate left module 
    rotl rotl_unit(
        .A(A),
        .B(B),
        .C(rotl_result)
    );

    // Select the appropriate output based on opcode
    always @(*) begin
        case(opcode)
            ADD:       C = {32'b0, add_result};
            SUB:       C = {32'b0, sub_result};
            MUL:       C = mul_result;        // 64 bits: {hi, lo}
            DIV:       C = div_result;        // 64 bits: {remainder, quotient}
            AND:       C = {32'b0, and_result};
            OR:        C = {32'b0, or_result};
            SHR:       C = {32'b0, shr_result};
            SHRA:      C = {32'b0, shra_result};
            SHIFTL:    C = {32'b0, shiftl_result};
            ROTR:      C = {32'b0, rotr_result};
            ROTL:      C = {32'b0, rotl_result};
            NEG:       C = {32'b0, neg_result};
            NOT:       C = {32'b0, not_result};
            default:   C = 64'b0;
        endcase
    end

endmodule