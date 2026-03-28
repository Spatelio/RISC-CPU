// Ra=ir[26:23] Rb=[22:19] Rc=[18:15]  C sign-extended from ir[18:0]
module selectencode(
    input wire [31:0] irIn,
    input wire gra, grb, grc,
    input wire selectIn, selectOut,
    input wire BAout, //for 0s or reg
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

    //4 bit selection into a 16 bit signal
    wire [15:0] decoded = 16'h0001 << selectedReg;
    wire [31:0] c_signext = {{13{irIn[18]}}, irIn[18:0]};

    // these wires get connected to our actual register inout signals in datapath
    assign regIn  = selectIn  ? decoded : 16'h0000;
    assign regOut = (selectOut | BAout) ? decoded : 16'h0000;

    assign c_sign_extended = c_signext;

endmodule