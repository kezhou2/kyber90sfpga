////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : cla.v
// Description  : .
//
// Author       : hungnt@HW-NTHUNG
// Created On   : Tue Nov 06 16:45:08 2018
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module cla
    (
     a,
     b,
     sum,
     c
     );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

parameter WID = 6;

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input [WID-1:0] a,b;

output [WID-1:0] sum;
output       c;

////////////////////////////////////////////////////////////////////////////////
// Output declarations

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

wire [WID:0] w_c;
wire [WID-1:0] w_g,w_p,w_s;

genvar i;

generate
for(i = 0; i<WID; i = i+1)
    begin : FAgen
    full_adder fai
            (
             .a(a[i]),
             .b(b[i]),
             .c_i(w_c[i]),
             .sum(w_s[i]),
             .c_o()
             );
    end
endgenerate

genvar j;
generate
    for (j=0;j<WID;j=j+1)
        begin : clgen
        assign w_g[j] = a[j] & b[j];
        assign w_p[j] = a[j] | b[j];
        assign w_c[j+1] = w_g[j] | (w_p[j] & w_c[j]);
        end
endgenerate

assign         w_c[0] = 1'b0;

assign         sum = w_s;
assign         c = w_c[WID];

endmodule 
