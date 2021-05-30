////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : cpldintf_16.v
// Description  : .
//
// Author       : vkhung@HW-VKHUNG
// Created On   : Wed Oct 15 19:30:38 2003
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module cpldintf_16
    (
     rst_,
     sclk,
     
     pcs,
     pdi,
     pdo,
     pdoe,
     prdy,
     pint,
     pintoe,

     
     up_addr,
     up_rd,
     up_wr,
     up_cs,
     up_rds,
     up_wrs,
     
     up_wrd,
     up_rdd,
     
     up_rdy,
     up_int,
     up_intoe
     
     );

////////////////////////////////////////////////////////////////////////////////
// Port declarations
input           rst_, sclk;
input           pcs;
input [15:0]    pdi;
output [15:0]   pdo;
output          pdoe, prdy, pint, pintoe;

output [24:0]   up_addr;
output          up_rd, up_wr, up_cs, up_wrs, up_rds;
output [15:0]   up_wrd;
input [15:0]    up_rdd;
input           up_rdy, up_int, up_intoe;

////////////////////////////////////////////////////////////////////////////////
// Output declarations
reg             prdy,  pint;

wire [24:0]     up_addr;
wire [15:0]     pdo, up_wrd;
wire            pdoe, pintoe;
wire            up_rd, up_wr, up_cs, up_wrs, up_rds;

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation
reg [15:0]      haddr, laddr;
reg             pcs1, pcs2, pcs3, pcs4;

wire            cs_ph1, cs_ph2, cs_ph4;

always @(posedge sclk or negedge rst_)
    if (!rst_)
        begin
        pcs1 <= 1'b0;
        pcs2 <= 1'b0;
        pcs3 <= 1'b0;
        pcs4 <= 1'b0;       
        end
    else if ((!pcs) & prdy)
        begin
        pcs1 <= 1'b0;
        pcs2 <= 1'b0;
        pcs3 <= 1'b0;
        pcs4 <= 1'b0;       
        end  
    else
        begin
        pcs1 <= pcs;
        pcs2 <= pcs1;
        pcs3 <= pcs2;
        pcs4 <= pcs3;
        end     

assign  cs_ph1 = pcs  & (!pcs1);
assign  cs_ph2 = pcs1 & (!pcs2);
assign  cs_ph4 = pcs3 & (!pcs4);

always @(posedge sclk or negedge rst_)
    if (!rst_)          haddr <= 16'h0;
    else if (cs_ph1)    haddr <= pdi;

always @(posedge sclk or negedge rst_)
    if (!rst_)          laddr <= 16'h0;
    else if (cs_ph2)    laddr <= pdi;

assign  up_rd = !haddr[15];
assign  up_wr = haddr[15];
assign  up_addr = {haddr[8:0],laddr};
assign  up_cs = pcs3;
assign  up_wrs = up_wr & cs_ph4;
assign  up_rds = up_rd & cs_ph4;
assign  up_wrd = pdi;
assign  pdo = up_rdd;
assign  pdoe = pcs3 & up_rd;

always @(posedge sclk or negedge rst_)
    if (!rst_)                      
        prdy <= 1'b0;
    else if (!pcs & prdy)
        prdy <= 1'b0;
    else if (!(pcs1 & pcs2 & pcs3 & pcs4))  
        prdy <= 1'b0;
    else if (pcs3)
        prdy <= up_rdy | prdy;
    else
        prdy <= 1'b0;

always @(posedge sclk or negedge rst_)
    if (!rst_)      pint <= 1'b0;
    else            pint <= up_int;

assign  pintoe = up_intoe;
endmodule