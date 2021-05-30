//////////////////////////////////////////////////////////////////////////////////
//
//  Arrive Technologies
//
// Filename        : fflopxe.v
// Description     : variable size enable flip flop
//
// Author          : 
// Created On      : Tue Jul 29 17:56:53 2003
// History (Date, Changed By)
//
//////////////////////////////////////////////////////////////////////////////////
module fflopxe
    (
     clk,
     rst_,
     latch_en,
     idat,
     odat
     );

parameter WIDTH = 8;
parameter RESET_VALUE = {WIDTH{1'b0}};

input   clk, rst_, latch_en;
input   [WIDTH-1:0] idat;

output  [WIDTH-1:0] odat;
reg     [WIDTH-1:0] odat;

always @ (posedge clk or negedge rst_)
    begin
    if(!rst_) odat <= RESET_VALUE;
    else if (latch_en) odat <= idat;
    end

endmodule
