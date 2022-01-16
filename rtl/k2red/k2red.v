`define SIMULATION

module k2red
(
    clk,
    rst,
    c,
    cred
);

//////////

//Based on K2RED algorithm 2 https://eprint.iacr.org/2021/563.pdf

/////////

parameter WID=24;
parameter WID2 = WID/2;
parameter DELAY = 1;

////////////////////////
input clk,rst;
input [WID-1:0] c;
output [WID2-1:0] cred;


/////////////////////////////////

`ifdef SYNTHESIS

wire [15:0] ch;
wire [15:0] cl;

assign cl = {8'b0,c[7:0]};
assign ch = c[23:8];

wire [15:0] subrs1;//rs = result
wire [15:0] addrs1;
wire [15:0] firstrs;

wire null1; //carry
//pre-shifting before add

wire [15:0] clx8;
wire [15:0] clx4;

assign clx8 = cl << 3;
assign clx4 = cl << 2;

wire [15:0] ch1;
wire [15:0] cl1;
wire [15:0] clx81;
wire [15:0] clx41;

fflopx #(16) ifflopx2(clk,rst,ch,ch1);
fflopx #(16) ifflopx3(clk,rst,cl,cl1);
fflopx #(16) ifflopx4(clk,rst,clx8,clx81);
fflopx #(16) ifflopx5(clk,rst,clx4,clx41);

//done shift

// first addition layer

full_sub #(16) ifullsub1 (clx81,ch1,subrs1,null1);
fulladder2f #(16) ifulladder2f1 (clx41,cl1,addrs1);

//second addtion
//fulladder2f #(16) ifulladder2f2 (subrs1,addrs1,firstrs);

assign firstrs = subrs1 + addrs1 - null1;

wire [15:0] firstrs1;

fflopx #(16) ifflopx6(clk,rst,firstrs,firstrs1);

//////second layer of shifting
wire [11:0] clp;
wire [11:0] chp;

assign chp = {{4{firstrs1[15]}},firstrs1[15:8]};
assign clp = {4'b0,firstrs1[7:0]};

//pre-shifting 2

wire [11:0] clpx8;
wire [11:0] clpx4;

assign clpx8 = clp << 3;
assign clpx4 = clp << 2;

wire [11:0] chp1;
wire [11:0] clp1;
wire [11:0] clpx81;
wire [11:0] clpx41;

fflopx #(WID2) ifflopx7(clk,rst,chp,chp1);
fflopx #(WID2) ifflopx8(clk,rst,clp,clp1);
fflopx #(WID2) ifflopx9(clk,rst,clpx8,clpx81);
fflopx #(WID2) ifflopx10(clk,rst,clpx4,clpx41);

/////second layer of addtion
wire [11:0] subrs2;//rs = result
wire [11:0] addrs2;
wire [11:0] finalrs;

wire null2; //carry

full_sub #(12) ifullsub2 (clpx81,chp1,subrs2,null2);
fulladder2f #(12) ifulladder2f3 (clpx41,clp1,addrs2);

//second addtion
wire [WID2-1:0] negativers1,negativers2,complers1,complers2;

fulladder2f #(12) ifulladder2f4 (subrs2,addrs2,finalrs);

wire [WID2-1:0] finalrs1;

ffxkclkx #(DELAY,WID2) iffxkclkx1 (clk,rst,finalrs,finalrs1);

wire null21;

ffxkclkx #(7,1) iffxkclkx2 (clk,rst,null2,null21); 

assign negativers1 = finalrs1 + 12'd3329;

assign negativers2 = finalrs1 - 12'd3329;

assign complers1 = finalrs1 + 12'd256;

assign complers2 = finalrs1 + 12'd256 - 12'd3329;

//assign complers2 = finalrs1 - 12'd3840;

wire checkflag;

assign checkflag = finalrs1 >= 12'd3329;

wire cond1,cond2,cond3;//,cond4;

assign cond1 = null2 & checkflag; //truong hop + dung

assign cond2 = !null2 & checkflag; //truong hop - dung

assign cond3 = null2 & !checkflag; //truong hop so lon

//wire cond31;

//ffxkclkx #(7,1) iffxkclkx400 (clk,rst,cond3,cond31); 

//assign cond4 = null21 & ;//cond31; //truong hop thut giua 2 ben so lon

assign cond5 = (complers1 >= 12'd3329)&(cond3);

wire [WID2-1:0] credtemp;

assign credtemp = cond5? complers2 : 
                (cond3)? complers1 :
                cond1? negativers1 :
                cond2? negativers2 : finalrs1;

fflopx #(WID2) ifflopx1 (clk,rst,credtemp,cred);

`elsif SIMULATION
wire [11:0] cred;
assign cred = (169*c)%3329;

ffxkclkx #(5,12) iffxkclkx54 (clk,rst,cred,c);

`endif

endmodule