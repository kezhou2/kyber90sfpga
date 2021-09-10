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
// Thu Aug 09 11:21:02 2018, NGUYEN@WIN-1B3KG57AJQF change to sync ffx
//
//////////////////////////////////////////////////////////////////////////////////
module fflopx
    (
     clk,
     rst,
     idat,
     odat
     );

parameter WIDTH = 8;
parameter RESET_VALUE = {WIDTH{1'b0}};

input   clk, rst;

input  [WIDTH-1:0] idat;

output [WIDTH-1:0] odat;
reg    [WIDTH-1:0] odat;

always @ (posedge clk)
    begin
    if(rst) odat <= RESET_VALUE;
    else odat <= idat;
    end

endmodule
