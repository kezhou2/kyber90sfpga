////////////////////////////////////////////////////////////////////////////////
//
// Ho Chi Minh City University of Technology
//
// Filename     : ecc_core.v
// Description  : .
//
// Author       : Vuong Dinh Hung (1511422)
// Created On   : Fri May 03 17:17:55 2019
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module ecc_core
    (
     clk,
     rst,
     // IP core
     din,       //3*WID
     mode,
     start,
     dout,
     status,
     // Simulation random number
     test_num
     );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

`define             RTL_SIMULATION
`define             RWSAMECLK

parameter           WIDTH   = 256;
parameter           ADDR    = 5;
parameter           WINDOW  = 4;
parameter           CBIT    = 8;
parameter           DEPTH   = 1<<ADDR;
parameter           CURWID  = 255;
parameter           OPWID   = 4;


////////////////////////////////////////////////////////////////////////////////
// Port declarations

input               clk;
input               rst;

// IP core
input [3*WIDTH-1:0] din;
input [2:0]         mode; // MSB indicates EC
input               start;
output [WIDTH-1:0]  dout;
output [1:0]        status;

input [WIDTH-1:0]   test_num;

////////////////////////////////////////////////////////////////////////////////
// Output declarations

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

wire [WIDTH-1:0]    auc_dat;
wire [OPWID-1:0]    auc_mode;   // MSB indicates EC
wire                auc_start;
wire [WIDTH-1:0]    auc_rslt;
wire [1:0]          auc_status;

mainctrl
    #(
      .WIDTH(WIDTH)
      ) imainctrl
    (
     .clk(clk),
     .rst(rst),
     // IP core
     .din(din),                 //3*WID
     .mode(mode),
     .start(start),
     .dout(dout),
     .status(status),
     // AUC controller
     .auc_dat(auc_dat),
     .auc_start(auc_start),
     .auc_mode(auc_mode),
     .auc_rslt(auc_rslt),
     .auc_status(auc_status)
     );

//================================================

wire [WIDTH-1:0]    au_dat1;
wire [WIDTH-1:0]    au_dat2;
wire                au_carry;
wire                au_start;
wire [OPWID-1:0]    au_opcode;
wire                au_swapop;
wire                au_swapvl;
wire [WIDTH-1:0]    au_rswap;
wire [WIDTH-1:0]    au_rslt;
wire                au_vld;

auc_wrap
    #(
      .WIDTH(WIDTH),
      .ADDR(ADDR),
      .WINDOW(WINDOW),
      .CBIT(CBIT),
      .DEPTH(DEPTH)
      ) iauc_wrap
    (
     .clk(clk),
     .rst(rst),
     // Main control - AUC
     .auc_dat(auc_dat),
     .auc_start(auc_start),
     .auc_mode(auc_mode),
     .auc_rslt(auc_rslt),
     .auc_status(auc_status),
     // AUC - AU
     .au_dat1(au_dat1),
     .au_dat2(au_dat2),
     .au_carry(au_carry),
     .au_start(au_start),
     .au_opcode(au_opcode),
     .au_swapop(au_swapop),
     .au_swapvl(au_swapvl),
     .au_rslt(au_rslt),
     .au_rswap(au_rswap),
     .au_vld(au_vld),
     // Simulation random number
     .test_num(test_num)
     );

//================================================

aluwrap
    #(
    .WID(WIDTH)
      ) ialuwrap        
    (   
     .clk(clk),
     .rst(rst),
     .status(),                 //00 01 10 11 idle computing done error

     .a(au_dat1),               //INV only input
     .b(au_dat2),
     .c(au_carry),              //cin for FA
     .en(au_start),             //start ops
     .swapop(au_swapop),
     .swapvl(au_swapvl),
     .opcode(au_opcode),        //[1:0]00 01 10 fa mul inv
     //[2] 1 X255 0 P256
     //[3] 1 N 0 P
     
     .r(au_rslt),               //result
     .rswap(au_rswap),
     .vld(au_vld)
     );

endmodule 
