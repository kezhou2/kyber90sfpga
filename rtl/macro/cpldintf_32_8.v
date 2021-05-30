////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : cpldintf_32.v
// Description  : .
//
// Author       : vkhung@HW-VKHUNG
// Created On   : Wed Oct 15 19:30:38 2003
// History (Date, Changed By)
//  - nvcuong@HW-NVCUONG Fri Oct 05 16:44:18 2007
//  - nvcuong@HW-NVCUONG Wed Oct 01 16:06:31 2008 include:
//    + Change up_cs_ signal from wire logic to register signal for cleaning
//    + Change pdo to register
//    + Use posedge of synchronized ACK from corepi to latch read data
//    + Change some others details and add comments for easy understanding
//  - edited on 2008/10/01 by nvcuong, checked on Wed Jul 29 10:37:01 2009
//    + totally changes
//
////////////////////////////////////////////////////////////////////////////////

module cpldintf_32_8
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
     up_rnw,
     up_cs_,
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
input [7:0]     pdi;
output [7:0]    pdo;
output          pdoe, prdy, pint, pintoe;

output [24:0]   up_addr;
output          up_rd, up_wr, up_rnw, up_cs_;
output [31:0]   up_wrd;
input [31:0]    up_rdd;
input           up_rdy;
input           up_int, up_intoe;

////////////////////////////////////////////////////////////////////////////////
// Output declarations
reg             pint, prdy;
wire [31:0]     up_wrd;
wire [24:0]     up_addr;
wire            pdoe, pintoe;
wire            up_rd, up_wr, up_rnw, up_cs_;


////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation
reg [15:0]      rdbuff_highword;
reg [23:0]      wrbuff_lowword;
reg [11:0]      autogenrdy;
reg [15:0]      haddr, laddr;
reg             pcs1, pcs2, pcs3,pcs4, pcs5, pcs6;

wire [7:0]      pdi;
wire            autogenrdy_inc;
wire            lowword_wrs1,lowword_wrs0, lowword_wrs2,wrlowword_rdy;
wire            highword_rds;
wire            cs_ph1,cs_ph2,cs_ph3,cs_ph4,cs_ph5,cs_ph6, up_cs;

always @(posedge sclk or negedge rst_)
    if (!rst_)
        begin
        pcs1 <= 1'b0;
        pcs2 <= 1'b0;
        pcs3 <= 1'b0;       
        pcs4 <= 1'b0;
        pcs5 <= 1'b0;
        pcs6 <= 1'b0;       
        end
    else if (!pcs)
        begin
        pcs1 <= 1'b0;
        pcs2 <= 1'b0;
        pcs3 <= 1'b0;       
        pcs4 <= 1'b0;
        pcs5 <= 1'b0;
        pcs6 <= 1'b0;       
        end
    else
        begin
        pcs1 <= pcs;
        pcs2 <= pcs1;
        pcs3 <= pcs2;       
        pcs4 <= pcs3;
        pcs5 <= pcs4;
        pcs6 <= pcs5;       
        end     

assign cs_ph1 = pcs  & (!pcs1);
assign cs_ph2 = pcs1 & (!pcs2);
assign cs_ph3 = pcs2 & (!pcs3);
assign cs_ph4 = pcs3 & (!pcs4);
assign cs_ph5 = pcs4 & (!pcs5);
assign cs_ph6 = pcs5 & (!pcs6);

always @(posedge sclk or negedge rst_)
    if (!rst_)          haddr <= 16'h0;
    else if (cs_ph1)    haddr[15:8] <= pdi[7:0];
    else if (cs_ph2)    haddr[7:0] <= pdi[7:0];

always @(posedge sclk or negedge rst_)
    if (!rst_)          laddr <= 16'h0;
    else if (cs_ph3)    laddr[15:8] <= pdi[7:0];
    else if (cs_ph4)    laddr[7:0] <= pdi[7:0]; 


assign  up_cs = (pcs5 & (!laddr[0]) & (!haddr[15])) |   // Rd Act @ Lo Word
                (pcs5 & (laddr[0])  & (haddr[15]) ) ;   // Wr Act @ hi word
assign  up_rd = !haddr[15] & up_cs;
assign  up_wr = haddr[15] & up_cs;
assign  up_rnw = up_rd;
assign  up_cs_ = !up_cs;

assign  up_addr = {haddr[9:0],laddr[15:1]}; // Word Base for CPLD
                                            // DWord Base for FPGA

assign  up_wrd = {pdi,wrbuff_lowword};

assign  lowword_wrs0 = cs_ph5 & haddr[15] & (!laddr[0]);
assign  lowword_wrs1 = cs_ph6 & haddr[15] & (!laddr[0]);
assign  lowword_wrs2 = cs_ph5 & haddr[15] & laddr[0];

always @(posedge sclk or negedge rst_)
    if (!rst_)
        wrbuff_lowword <= 24'hCAFE;
    else if (lowword_wrs0)
        wrbuff_lowword[7:0] <= pdi[7:0];
    else if (lowword_wrs1)
        wrbuff_lowword[15:8] <= pdi[7:0];
    else if (lowword_wrs2)
        wrbuff_lowword[23:16] <= pdi[7:0];
    
assign  highword_rds = cs_ph5 & !haddr[15] & laddr[0];

reg     up_rdy1;
always @ (posedge sclk or negedge rst_)
    if (!rst_)  up_rdy1 <= 1'b0;
    else        up_rdy1 <= up_rdy;
    
always @(posedge sclk or negedge rst_)
    if (!rst_)
        rdbuff_highword <= 16'hCAFE;
    else if (up_rdy1 & up_rd)
        rdbuff_highword <= up_rdd[31:16];

// timeout
assign  autogenrdy_inc = (pcs & (autogenrdy < 12'h7ff));

always @(posedge sclk or negedge rst_)
    if (!rst_)                  autogenrdy <= 12'h0;
    else if (autogenrdy_inc)    autogenrdy <= autogenrdy + 1'b1;
    else if (!pcs)              autogenrdy <= 12'h0;


reg     autordy;
always @ (posedge sclk or negedge rst_)
    if (!rst_)  autordy <= 1'b0;
    else        autordy <= (autogenrdy == 12'h7ff);

reg     nprdy;
wire     nprdy1,nprdy2;
fflopx #(2) pp2nprdy (sclk,rst_,{nprdy,nprdy1},{nprdy1,nprdy2});

wire [7:0]       npdo;
assign  npdo = nprdy & !nprdy1 ? (autordy ? 8'hFE : 
                                  laddr[0] ? rdbuff_highword[7:0] : 
                                  up_rdd[7:0]) :
               autordy ? 8'hCA : laddr[0] ? rdbuff_highword[15:8] : up_rdd[15:8];

assign  pdoe = pcs4 & (!haddr[15]);

always @(posedge sclk or negedge rst_)
    if (!rst_)                      
        nprdy <= 1'b0;
    else if (!pcs)
        nprdy <= 1'b0;
    else if (pcs4 & (lowword_wrs1 | highword_rds | up_rdy1 | autordy))
        nprdy <= 1'b1;

reg [7:0] pdo;
always @ (negedge sclk or negedge rst_)
    if (!rst_)
        begin
        pdo <= 8'd0;
        prdy <= 1'd0;
        end
    else
        begin
        pdo <= npdo;
        prdy <= nprdy;
        end

    
always @(posedge sclk or negedge rst_)
    if (!rst_)      pint <= 1'b0;
    else            pint <= up_int;

assign  pintoe = up_intoe;
endmodule