module butterfly(
    clk,
    rst,

    a,//input 12-bit
    b,
    w,

    c,
    d,

    sel //mode of operation 1: NTT:0 INTT:1 BYPASS:2
);
//////////////////need-pipeline///

parameter WID = 12;
parameter SELWID = 2;
parameter DELAY = 3;//delay pipeline

///////////////////////////////////////////////////
input clk;
input rst;

input [WID-1:0] a;
input [WID-1:0] b;
input [WID-1:0] b;

input [SELWID-1:0]     sel //mode of operation


output [WID-1:0] c;
output [WID-1:0] d;
//////////////////////////////////////////////////

wire [WID-1:0] a0,a3,a4;
wire [WID-1:0] b0,b3,b4;
wire [WID-1:0] w0,w1;
wire [WID-1:0] apwb_fin,apb_fin,a_fin;
wire [WID-1:0] amwb_fin,ambw_fin,b_fin;
wire [WID-1:0] red_rslt,add_rslt,sub_rslt; 
wire [2*WID-1:0] mul_rslt;
wire [WID-1:0] mul1,mul2,adder1,adder2,diff1,diff2;

fflopx #(WID) ifflopx1(clk,rst,a,a0);
fflopx #(WID) ifflopx2(clk,rst,b,b0);
fflopx #(WID) ifflopx2(clk,rst,w,w0);

ffxkclkx #(DELAY,WID) iffxkclkx (clk,rst,a0,a3);
fflopx #(WID) ifflopx1(clk,rst,a3,a4);
ffxkclkx #(DELAY,WID) iffxkclkx (clk,rst,b0,b3);
fflopx #(WID) ifflopx1(clk,rst,b3,b4);
fflopx #(WID) ifflopx2(clk,rst,w0,w1);

/////////////////////////////////////////////////

assign diff1 = (sel==2'b00)? a3 : a0;
assign diff2 = (sel==2'b00)? red_rslt : b0;

assign adder1 = (sel==2'b00)? red_rslt : b3;
assign adder2 = a3;

assign mul1 = (sel==2'b00)? w0 : w1;
assign mul2 = (sel==2'b00)? v0 : diff_rslt;

//////////2-OUTPUT-mux///////////
//sel 2
assign a_fin = a4;
assign b_fin = b4;
//sel 1
assign apb_fin  = add_rslt;
assign ambw_fin = red_rslt;
//sel0
assign apwb_fin = add_rslt;
assign amwb_fin = diff_rslt;
//////////

sim_mult #(WID) isim_mult(mul1,mul2,mul_rslt);
k2red #(2*WID) ik2red (mul_rslt,red_rslt);
poly_mod_add #(WID) ipoly_mod_add (adder1,adder2,add_rslt);
poly_mod_diff #(WID) ipoly_mod_diff (diff1,diff2,diff_rslt);
ffxkclkx #(BYPASSDELAY,WID) iffxkclkx (clk,rst,b0,b_fin);
mux_xx2 #(WID) imux_xx21 (apwb_fin,apb_fin,a_fin,12'b0,sel,c);
mux_xx2 #(WID) imux_xx22 (amwb_fin,ambw_fin,b_fin,12'b0,sel,d);

//////////////////
endmodule