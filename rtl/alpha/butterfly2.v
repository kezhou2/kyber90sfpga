module butterfly2(
    clk,
    rst,

    u,//input 12-bit
    t,
    w,

    s0,
    s1,

    sel //mode of operation NTT:1 INTT:0
);
//////////////////need-pipeline///

parameter WID = 12;
parameter SELWID = 1;
parameter DELAYUCT = 7;//delay pipeline
parameter DELAYUGS = 7;

///////////////////////////////////////////////////

input clk;
input rst;

input [WID-1:0] u;
input [WID-1:0] t;
input [WID-1:0] w;

input [SELWID-1:0]     sel; //mode of operation


output [WID-1:0] s0;
output [WID-1:0] s1;

//////////////////////////////////////////////////
//khai bao
wire [WID-1:0] multa,multb,modrslt,modhalf2;
wire [2*WID-1:0] multrslt;//mult is 24 bit

//////////////////////////////////////////////////

wire [WID-1:0] u1,t1,w1;

fflopx #(WID) ifflopx1 (clk,rst,u,u1);
fflopx #(WID) ifflopx2 (clk,rst,t,t1);
fflopx #(WID) ifflopx3 (clk,rst,w,w1);

wire [WID-1:0] udelay;

ffxkclkx #(DELAYUCT,WID) iffxkclkx1 (clk,rst,u1,udelay);

wire [WID-1:0] usel;

assign usel = sel? udelay : u1; //udelay?

/////////////////////////////////////////////////
//modular addition

wire [WID-1:0] addera,adderb,addrslt,modhalf1,modhalf1delay;

assign addera = usel;

assign adderb = sel? modrslt : t1;

poly_mod_add #(WID) ipoly_mod_add (addera,adderb,addrslt);

modhalfq imodhalfq1 (clk,rst,addrslt,modhalf1);

ffxkclkx #(DELAYUGS,WID) iffxkclkx2 (clk,rst,modhalf1,modhalf1delay);

/////////////////////////////////////////////////
//modular sub

wire [WID-1:0] suba,subb,subrslt;

assign suba = usel;

assign subb = sel? modrslt : t1;

poly_mod_diff #(WID) ipoly_mod_diff (suba,subb,subrslt);

//////////////////////////////////////////////////
//mult mod

assign multa = w1;

assign multb = sel? t1 : subrslt;

sim_mult isim_mult (clk,rst,multa,multb,multrslt);

k2red ik2red (clk,rst,multrslt,modrslt);

modhalfq imodhalfq2 (clk,rst,modrslt,modhalf2);

/////////////////////////////////////////////////
//output mux
wire [WID-1:0] s0ct,s0gs,s1ct,s1gs;

assign s0ct = addrslt;
assign s0gs = modhalf1delay;

assign s1ct = subrslt;
assign s1gs = modhalf2;

mux_xx1 #(WID) imux_xxout1 (s0gs,s0ct,sel,s0); //sel = 1 thì chon b
mux_xx1 #(WID) imux_xxout2 (s1gs,s1ct,sel,s1);

//////////////////
endmodule