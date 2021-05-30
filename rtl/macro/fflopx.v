//////////////////////////////////////////////////////////////////////////////////
//
//  Arrive Technologies
//
// Filename        : fflopx.v
// Description     : variable size flip flop
//
// Author          : ducdd@atvn.com.vn
// Created On      : Tue Jul 29 18:00:29 2003
// History (Date, Changed By)
//
//////////////////////////////////////////////////////////////////////////////////
module fflopx
    (
     clk,
     rst_,
     idat,
     odat
     );

parameter WIDTH = 8;
parameter RESET_VALUE = {WIDTH{1'b0}};

input   clk, rst_;

input  [WIDTH-1:0] idat;

output [WIDTH-1:0] odat;
reg    [WIDTH-1:0] odat;

always @ (posedge clk or negedge rst_)
    begin
    if(!rst_) odat <= RESET_VALUE;
    else odat <= idat;
    end

endmodule
