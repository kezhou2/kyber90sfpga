////////////////////////////////////////////////////////////////////////////////
//
// Ho Chi Minh City University of Technology
//
// Filename     : auc_rand.v
// Description  : .
//
// Author       : Vuong Dinh Hung (1511422)
// Created On   : Mon Apr 15 14:56:52 2019
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module auc_rand
    (
     clk,
     rst,
     //Input
     rand_en,
     rand_din,
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

parameter           WIDTH   = 256;
parameter           ADDR    = 5;

localparam          INIT    = 0;

localparam          X_G     = 0;
localparam          Y_G     = 1;
localparam          X_3G    = 2;
localparam          Y_3G    = 3;
localparam          Z_3G    = 4;
localparam          X_5G    = 5;
localparam          Y_5G    = 6;
localparam          Z_5G    = 7;
localparam          X_7G    = 8;
localparam          Y_7G    = 9;
localparam          Z_7G    = 10;

localparam          K_NUM   = 11;
localparam          K_INV   = 12;
localparam          R_NUM   = 13;
localparam          S_NUM   = 14;
localparam          X_KG    = 15;
localparam          HASH    = 16;
localparam          PKEY    = 17;
localparam          ZRRAM   = 18;   // NEED FIX
localparam          ONERAM  = 19;   // NEED FIX

localparam          TEMP0   = 20;
localparam          TEMP1   = 21;
localparam          TEMP2   = 22;
localparam          TEMP3   = 23;
localparam          TEMP4   = 24;
localparam          TEMP5   = 25;
localparam          TEMP6   = 26;   
localparam          TEMP7   = 27;
localparam          TEMP8   = 28;

localparam          S_RP    = 29;
localparam          S_RPH   = 30;
localparam          BLNK    = 31;

localparam          ORD_w   = 256'hFFFFFFFF_00000000_FFFFFFFF_FFFFFFFF_BCE6FAAD_A7179E84_F3B9CAC2_FC632551;
localparam          ORD_M   = 1<<252 + 128'h14de_f9de_a2f7_9cd6_5812_631a_5cf5_d3ed;


////////////////////////////////////////////////////////////////////////////////
// Port declarations

input               clk;
input               rst;

input               rand_en;
input [WIDTH-1:0]   rand_din;
input               rand_curve;

output              rand_vld;

output              rand_wen;
output [ADDR-1:0]   rand_wadd;
output [WIDTH-1:0]  rand_wdat;

////////////////////////////////////////////////////////////////////////////////
// Output declarations

wire                rand_vld;

wire                rand_wen;
wire [ADDR-1:0]     rand_wadd;
wire [WIDTH-1:0]    rand_wdat;

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

reg [WIDTH-1:0]     random;
reg                 vld;

wire                rbg_w;
assign              rbg_w = random > (ORD_w - 2);

wire                rbg_m;
assign              rbg_m = random > (ORD_M - 2);

wire                retake;
assign              retake = (~rand_curve & rbg_w) | (rand_curve & rbg_m);

reg                 correct;

reg                 rand_en_sticky;
always @(posedge clk)
    begin
    if (rst)
        rand_en_sticky  <= 1'b0;
    else if (rand_en)
        rand_en_sticky  <= 1'b1;
    else if (vld)
        rand_en_sticky  <= 1'b0;
    else
        rand_en_sticky  <= 1'b0;
    end

always @(posedge clk)
    begin
    if (rst)
        begin
        random  <= INIT;
        vld     <= 1'b0;
        correct <= 1'b0;
        end
    else if (rand_en)
        begin
        random  <= rand_din;
        vld     <= 1'b0;
        correct <= 1'b0;
        end
    else if (retake & rand_en_sticky)
        begin
        random  <= rand_din;
        vld     <= 1'b0;
        correct <= 1'b0;
        end
    else if (~correct & rand_en_sticky)
        begin
        random  <= random + 1'b1;
        vld     <= 1'b1;
        correct <= 1'b1;
        end
    else
        begin
        random  <= random;
        vld     <= 1'b0;
        correct <= correct;
        end
    end

wire                vld1;
fflopx #(1) ifflopx (clk, rst, vld, vld1);

assign              rand_vld    = rand_wen;

assign              rand_wen    = ~vld1 & vld;
assign              rand_wadd   = K_NUM;
assign              rand_wdat   = random;

endmodule 
