module butterfly(
    clk,
    rst,

    a,//input 24-bit
    b,
    w,

    c0,
    c1,

    sel //mode of operation 1: CT 0: GS
);
//////////////////

parameter WID = 24;
parameter SELWID = 1;

//////////////////
input clk,
input rst,

input [WID-1:0] a0,//input 24-bit
input [WID-1:0]     a1,

input [WID-1:0]     b0,
input [WID-1:0]     b1,

input [SELWID-1:0]     sel //mode of operation

//////////////
//instant adder mult and sub

//wiring

//end-wiring

addsub iaddsub(
    .sub(),
    .a(),
    .b(),
    .o()
);