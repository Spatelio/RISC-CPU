module pc_unit (
    input  wire        clk,
    input  wire        reset,
    input  wire        pc_write, 
    input  wire [31:0] target_addr, // Address from a Branch or Jump
    input  wire        sel_target,  // Control signal: 0 for PC+4, 1 for Target
    output wire [31:0] pc_out
);

    wire [31:0] pc_plus_4;
    wire [31:0] pc_next;

    
    assign pc_plus_4 = pc_out + 4;

    assign pc_next = (sel_target) ? target_addr : pc_plus_4; //allows mem addr to pc to be assigned

    reg32 pc_reg (
        .clk(clk),
        .reset(reset),
        .wr_en(pc_write),
        .d(pc_next),
        .q(pc_out)
    );

endmodule