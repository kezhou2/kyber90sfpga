module butterfly(
    clk,
    rst,

    a,//input 24-bit
    b,
    w,

    c,
    d,

    sel //mode of operation 1: CT 0: GS
);
//////////////////

parameter WID = 24;
parameter SELWID = 1;

//////////////////
input clk;
input rst;

input [WID-1:0] a;
input [WID-1:0] b;
input [WID-1:0] b;

input [SELWID-1:0]     sel //mode of operation

output [WID-1:0] c;
output [WID-1:0] d;

//////////////FOR OPTIMIZE UPDATE
//instant adder mult and sub

//wiring

//end-wiring
/*
addsub iaddsub(
    .sub(),
    .a(),
    .b(),
    .o()
);
*/
///////// pipeline input/////////
wire [WID-1:0] a0;
wire [WID-1:0] b0;

fflopx #(WID) ifflopx1(clk,rst,a,a0);
fflopx #(WID) ifflopx2(clk,rst,b,b0);

///////////////

wire [WID-1:0] a0raw;
wire [WID-1:0] a0plus;
wire [WID-1:0] b0raw;
wire [WID-1:0] b0minus;

assign b0minus  = b0 - a0;
assign b0raw    = b0;
assign a0plus   = a0 + b0;
assign a0raw    = a0;

wire [WID-1:0] a1np;
wire [WID-1:0] b1np;

mux_xx1 #(WID) imuxx1 (a0raw,a0plus,sel,a1np);
mux_xx1 #(WID) imuxx2 (b0raw,b0minus,sel,b1np);

wire [WID-1:0] a1;
wire [WID-1:0] b1;

fflopx #(WID) ifflopx3(clk,rst,a1np,a1);
fflopx #(WID) ifflopx4(clk,rst,b1np,b1);

assign 
