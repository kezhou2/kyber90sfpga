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
input [WID-1:0] w;

input [SELWID-1:0]     sel; //mode of operation


output [WID-1:0] c;
output [WID-1:0] d;

//////////////////////////////////////////////////

wire [WID-1:0] a0,a3,a4;
wire [WID-1:0] b0,b3,b4;
wire [WID-1:0] w0,w1;
wire [WID-1:0] apwb_fin,apb_fin,a_fin;
wire [WID-1:0] amwb_fin,ambw_fin,b_fin;
wire [WID-1:0] red_rslt,add_rslt,diff_rslt; 
wire [2*WID-1:0] mul_rslt;
wire [WID-1:0] mula,mulb,addera,adderb,diffa,diffb;
wire [WID-1:0] mula1,mulb1,addera1,adderb1,diffa1,diffb1;

fflopx #(WID) ifflopx1(clk,rst,a,a0);
fflopx #(WID) ifflopx2(clk,rst,b,b0);
fflopx #(WID) ifflopx3(clk,rst,w,w0);

ffxkclkx #(DELAY,WID) iffxkclkx1 (clk,rst,a0,a3);
fflopx #(WID) ifflopx4(clk,rst,a3,a4);
ffxkclkx #(DELAY,WID) iffxkclkx2 (clk,rst,b0,b3);
fflopx #(WID) ifflopx5(clk,rst,b3,b4);
fflopx #(WID) ifflopx6(clk,rst,w0,w1);

wire [WID-1:0] cmux,dmux;

/////////////////////////////////////////////////

assign diffa = (sel==2'b00)? a3 : a0;
assign diffb = (sel==2'b00)? red_rslt : b0;

assign addera = (sel==2'b00)? red_rslt : b3;
assign adderb = a3;

assign mula = (sel==2'b00)? w0 : w1;
assign mulb = (sel==2'b00)? b0 : diff_rslt;

fflopx #(WID) ifflopx7(clk,rst,diffa,diffa1);
fflopx #(WID) ifflopx8(clk,rst,diffb,diffb1);
fflopx #(WID) ifflopx9(clk,rst,addera,addera1);
fflopx #(WID) ifflopx10(clk,rst,adderb,adderb1);
fflopx #(WID) ifflopx11(clk,rst,mula,mula1);
fflopx #(WID) ifflopx12(clk,rst,mulb,mulb1);
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

sim_mult #(WID) isim_mult(clk,rst,mula1,mulb1,mul_rslt);
k2red #(2*WID) ik2red (clk,rst,mul_rslt,red_rslt);
poly_mod_add #(WID) ipoly_mod_add (addera1,adderb1,add_rslt);
poly_mod_diff #(WID) ipoly_mod_diff (diffa1,diffb1,diff_rslt);
mux_xx2 #(WID) imux_xx21 (apwb_fin,apb_fin,a_fin,12'b0,sel,cmux);
mux_xx2 #(WID) imux_xx22 (amwb_fin,ambw_fin,b_fin,12'b0,sel,dmux);

assign c = cmux;
assign d = dmux;

//////////////////
endmodule