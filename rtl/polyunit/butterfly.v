module butterfly(
    clk,
    rst,

    a0,//input 24-bit
    a1,

    b0,
    b1,

    c0,//output
    c1,
    
    d0,
    d1,

    sel //mode of operation
);
//////////////////

parameter WID = 24;
parameter SELWID = 9;
//////////////////
input clk,
input rst,

input [WID-1:0] a0,//input 24-bit
input [WID-1:0]     a1,

input [WID-1:0]     b0,
input [WID-1:0]     b1,

    c0,//output
    c1,
    
    d0,
    d1,

input [SELWID-1:0]     sel //mode of operation