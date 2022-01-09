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
parameter SELWID = 2; //bypass
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

wire [WID-1:0] u1,t1,w1,w4;
wire [SELWID-1:0] sel1,sel10;

fflopx #(WID) ifflopx1 (clk,rst,u,u1);
fflopx #(WID) ifflopx2 (clk,rst,t,t1);
fflopx #(WID) ifflopx3 (clk,rst,w,w1);
ffxkclkx #(3,WID) iffxkclkx17 (clk,rst,w1,w4);
fflopx #(SELWID) ifflopx4 (clk,rst,sel,sel1);
ffxkclkx #(13,2) iffxkclkx5 (clk,rst,sel1,sel10);

wire [WID-1:0] udelay;

ffxkclkx #(DELAYUCT,WID) iffxkclkx1 (clk,rst,u1,udelay);

/////////////////////////////////////////////////
//modular addition

wire [WID-1:0] addera,adderb,addrslt,modhalf1,modhalf1delay;

assign addera = sel1[0]? udelay : u1;

assign adderb = sel1[0]? modrslt : t1;

poly_mod_add #(WID) ipoly_mod_add (clk,rst,addera,adderb,addrslt);//2

modhalfq imodhalfq1 (clk,rst,addrslt,modhalf1);//2

ffxkclkx #(DELAYUGS,WID) iffxkclkx2 (clk,rst,modhalf1,modhalf1delay);

/////////////////////////////////////////////////
//modular sub

wire [WID-1:0] suba,subb,subrslt;

assign suba = sel1[0]? udelay : u1;

assign subb = sel1[0]? modrslt : t1;

poly_mod_diff #(WID) ipoly_mod_diff (clk,rst,suba,subb,subrslt);

//////////////////////////////////////////////////
//mult mod

assign multa = sel1[0]? w1 : w4;

assign multb = sel1[0]? t1 : subrslt;

sim_mult isim_mult (clk,rst,multa,multb,multrslt); //2

k2red ik2red (clk,rst,multrslt,modrslt); //5

modhalfq imodhalfq2 (clk,rst,modrslt,modhalf2); //2

/////////////////////////////////////////////////
//output mux
wire [WID-1:0] s0ct,s0gs,s1ct,s1gs,s0ctdelay,s1ctdelay;

assign s0ct = addrslt;//8 clk + 2
assign s0gs = modhalf1delay;//10 clk

assign s1ct = subrslt;//8clk + 2
assign s1gs = modhalf2;//10 clk

wire [WID-1:0] s0o,s1o;

ffxkclkx #(2,WID) iffxkclkx10 (clk,rst,s0ct,s0ctdelay);
ffxkclkx #(2,WID) iffxkclkx11 (clk,rst,s1ct,s1ctdelay);

mux_xx1 #(WID) imux_xxout1 (s0gs,s0ctdelay,sel10[0],s0o); //sel = 1 thì chon b
mux_xx1 #(WID) imux_xxout2 (s1gs,s1ctdelay,sel10[0],s1o);

//////////////////
wire [WID-1:0] u10; //13 clk
wire [WID-1:0] t10;

ffxkclkx #(12,WID) iffxkclkx12 (clk,rst,u1,u10);
ffxkclkx #(12,WID) iffxkclkx14 (clk,rst,t1,t10);

assign s0 = sel10[1]? u10 : s0o;
assign s1 = sel10[1]? t10 : s1o;

//////////////////
endmodule