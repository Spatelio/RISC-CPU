module encoder32to5 (
    input  wire [31:0] onehot,
    output reg  [4:0]  sel,
    output wire        valid,
    output wire        multi
);
    // valid is 1 if at least one bit is set
    assign valid = |onehot;

    // multi is 1 if more than one bit is set (detects bus contention)
    assign multi = (onehot != 32'b0) && ((onehot & (onehot - 32'b1)) != 32'b0);

    always @(*) begin
        // Default to 0 if no bits are set
        sel = 5'd0;

        // Priority logic: lowest index wins
        // This avoids 'x' propagation issues common with casex
        if      (onehot[0])  sel = 5'd0;
        else if (onehot[1])  sel = 5'd1;
        else if (onehot[2])  sel = 5'd2;
        else if (onehot[3])  sel = 5'd3;
        else if (onehot[4])  sel = 5'd4;
        else if (onehot[5])  sel = 5'd5;
        else if (onehot[6])  sel = 5'd6;
        else if (onehot[7])  sel = 5'd7;
        else if (onehot[8])  sel = 5'd8;
        else if (onehot[9])  sel = 5'd9;
        else if (onehot[10]) sel = 5'd10;
        else if (onehot[11]) sel = 5'd11;
        else if (onehot[12]) sel = 5'd12;
        else if (onehot[13]) sel = 5'd13;
        else if (onehot[14]) sel = 5'd14;
        else if (onehot[15]) sel = 5'd15;
        else if (onehot[16]) sel = 5'd16; // hi_out
        else if (onehot[17]) sel = 5'd17; // lo_out
        else if (onehot[18]) sel = 5'd18; // zhi_out
        else if (onehot[19]) sel = 5'd19; // zlo_out
        else if (onehot[20]) sel = 5'd20; // pc_out
        else if (onehot[21]) sel = 5'd21; // mdr_out
        else if (onehot[22]) sel = 5'd22; // in_port_out
        else if (onehot[23]) sel = 5'd23; // c_out
        else                 sel = 5'd0;
    end

endmodule