// Ra=ir[26:23] Rb=[22:19] Rc=[18:15]  C sign-extended from ir[18:0]
// jal_link_r12: JAL always writes PC+1 to R12 (ir Rb field ignored for that write).
module selectencode(
    input wire [31:0] irIn,
    input wire gra, grb, grc,
    input wire selectIn, selectOut,
    input wire BAout, //for 0s or reg
    input wire jal_link_r12,
    output wire [15:0] regOut,
    output wire [15:0] regIn,
    output wire [31:0] c_sign_extended
);

    wire [3:0] ra = irIn[26:23]; // given bit fields
    wire [3:0] rb = irIn[22:19];
    wire [3:0] rc = irIn[18:15];

    wire [3:0] selectedReg = gra ? ra :
                             grb ? rb :
                             grc ? rc : 4'b0000;

    wire [3:0] regInSel = (selectIn && jal_link_r12) ? 4'd12 : selectedReg;

    //4 bit selection into a 16 bit signal
    wire [15:0] decodedIn  = 16'h0001 << regInSel;
    wire [15:0] decodedOut = 16'h0001 << selectedReg;
    wire [31:0] c_signext = {{13{irIn[18]}}, irIn[18:0]};

    // these wires get connected to our actual register inout signals in datapath
    assign regIn  = selectIn  ? decodedIn : 16'h0000;
    assign regOut = (selectOut | BAout) ? decodedOut : 16'h0000;

    assign c_sign_extended = c_signext;

endmodule