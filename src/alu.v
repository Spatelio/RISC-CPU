module alu(
    input wire [31:0] A,          // Input from Y register
    input wire [31:0] B,          // Input from the bus
    input wire [4:0]  opcode,     // Operation code to select which operation to perform
    output reg [63:0] C           // 64-bit result (for multiplication and division)
);

    // Define operation codes
    parameter ADD    = 5'b00000; 
    parameter SUB    = 5'b00001; 
    parameter MUL    = 5'b00010; 
    parameter DIV    = 5'b00011; 
    parameter AND    = 5'b00100; 
    parameter OR     = 5'b00101; 
    parameter SHR    = 5'b00110; 
    parameter SHRA   = 5'b00111; 
    parameter SHIFTL = 5'b01000; 
    parameter ROTR   = 5'b01001; 
    parameter ROTL   = 5'b01010; 
    parameter NEG    = 5'b01011; 
    parameter NOT    = 5'b01100; 

    // Wires for functional unit output
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

    // Instantiate unit modules
    
    adder add_unit(
        .A(A),
        .B(B),
        .sum(add_result)
    );


    subtractor sub_unit(
        .A(A),
        .B(B),
        .Result(sub_result)
    );


    mult mul_unit(
        .a(A),
        .b(B),
        .z(mul_result)
    );


    div div_unit(
        .dividend(A),
        .divisor(B),
        .res(div_result)
    );


    and_ and_unit(
        .A(A),
        .B(B),
        .C(and_result)
    );

 
    or_ or_unit(
        .A(A),
        .B(B),
        .C(or_result)
    );


    not_ not_unit(
        .A(A),
        .C(not_result)
    );


    negate neg_unit(
        .A(A),
        .C(neg_result)
    );


    shiftr shr_unit(
        .A(A),
        .B(B),  
        .C(shr_result)
    );


    shiftra shra_unit(
        .A(A),
        .B(B), 
        .C(shra_result)
    );

    shiftl shiftl_unit(
        .A(A),
        .B(B),
        .C(shiftl_result)
    );


    rotr rotr_unit(
        .A(A),
        .B(B),
        .C(rotr_result)
    );


    rotl rotl_unit(
        .A(A),
        .B(B),
        .C(rotl_result)
    );

    // Select the output based on opcode
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