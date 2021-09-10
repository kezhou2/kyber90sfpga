////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : full_sub.v
// Description  : normalized exponent to normal form
//
// Author       : hungnt@HW-NTHUNG
// Created On   : Tue Nov 06 16:45:08 2018
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module full_sub
    (
     a,
     b,
     sub,
	c
     );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

parameter WIDTH = 9;

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input [WIDTH-1:0] a,b;

output [WIDTH-1:0] sub;
output       c;

////////////////////////////////////////////////////////////////////////////////
// Output declarations

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

wire [WIDTH-1:0] notb;

assign notb = ~b;

wire [WIDTH:0] subc;

assign subc[0] = 1'b1;

wire [WIDTH-1:0] subrs;

genvar i;
generate
for(i = 0; i<WIDTH; i = i+1)
    begin : FAgen
    full_adder fai
            (
             .a(a[i]),
             .b(notb[i]),
             .c_i(subc[i]),
             .sum(subrs[i]),
             .c_o(subc[i+1])
             );
    end
endgenerate

assign sub = subrs;
assign c = subc[WIDTH];

endmodule 
