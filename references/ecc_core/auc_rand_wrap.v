////////////////////////////////////////////////////////////////////////////////
//
// Ho Chi Minh City University of Technology
//
// Filename     : auc_rand_wrap
// Description  : .
//
// Author       : Vuong Dinh Hung (1511422)
// Created On   : Sun Apr 21 10:08:07 2019
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module auc_rand_wrap
    (
     clk,
     rst,
     // Input
     rand_en,
     rand_tnum,         // simulation only
     rand_curve,
     // Output
     rand_vld,
     //RAM control
     rand_wen,
     rand_wadd,
     rand_wdat
     );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations
`define             RTL_SIMULATION

parameter           WIDTH   = 256;
parameter           ADDR    = 5;

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input               clk;
input               rst;

input               rand_en;
input [WIDTH-1:0]   rand_tnum;
input               rand_curve;

output              rand_vld;

output              rand_wen;
output [ADDR-1:0]   rand_wadd;
output [WIDTH-1:0]  rand_wdat;

////////////////////////////////////////////////////////////////////////////////
// Output declarations

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

wire [WIDTH-1:0]    rand_din;

auc_rand
    #(
      .WIDTH(WIDTH),
      .ADDR(ADDR)
      ) iauc_rand
    (
     .clk(clk),
     .rst(rst),
     //Input
     .rand_en(rand_en),
     .rand_din(rand_din),
     .rand_curve(rand_curve),
     // Output
     .rand_vld(rand_vld),
     //RAM control
     .rand_wen(rand_wen),
     .rand_wadd(rand_wadd),
     .rand_wdat(rand_wdat)
     );

`ifdef  RTL_SIMULATION
assign              rand_din = rand_tnum;

`else
wire [WIDTH-1:0]    randvl;

lv_rd256wrap
    #(
      .WID(WIDTH)
      ) ilv_rs256wrap
    (
     .clk(clk),
     .rst(rst),
     .randvl(randvl)    // pseudo random
     );

assign              rand_din = randvl;

`endif

endmodule 
