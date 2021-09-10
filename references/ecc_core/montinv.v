////////////////////////////////////////////////////////////////////////////////
//
// Ho Chi Minh City University of Technology
//
// Filename     : montinv.v
// Description  : .
//
// Author       : Vuong Dinh Hung (1511422)
// Created On   : Wed Mar 06 14:52:37 2019
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module montinv
    (
     clk,
     rst,
     din,
     mod,
     en,
     inv,
     vld
     );

////////////////////////////////////////////////////////////////////////////////
// parameter declarations

parameter WIDTH = 256;
parameter CWID  = 10;

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input     clk;
input     rst;
input [WIDTH-1:0] din;
input [WIDTH-1:0] mod;
input             en;

output [WIDTH-1:0] inv;
output             vld;

////////////////////////////////////////////////////////////////////////////////
// Output declarations

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

wire [WIDTH-1:0]   ainv;
wire [CWID-1:0]    exp;
wire               p1vld;   // phase 1 valid

montinvp1   #(WIDTH, CWID) phase1
    (
     .clk(clk),
     .rst(rst),
     .din(din),
     .mod(mod),
     .en(en),
     .ainv(ainv),
     .exp(exp),
     .vld(p1vld)
     );

montinvp2   #(WIDTH, CWID) phase2
    (
     .clk(clk),
     .rst(rst),
     .ainv(ainv),
     .mod(mod),
     .exp(exp),
     .en(p1vld),
     .inv(inv),
     .vld(vld)
     );

endmodule 