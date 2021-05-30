////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : cpldintf_32.v
// Description  : .
//
// Author       : vkhung@HW-VKHUNG
// Created On   : Wed Oct 15 19:30:38 2003
// History (Date, Changed By) nvcuong@HW-NVCUONG Wed Oct 01 14:00:18 2008
// Changed by nvcuong@HW-NVCUONG Wed Oct 01 16:03:53 2008 with include:
//   + Change up_cs_ signal from wire logic to register signal for cleaning
////////////////////////////////////////////////////////////////////////////////

module cpldintf_32
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
input [15:0]    pdi;
output [15:0]   pdo;
output          pdoe, prdy, pint, pintoe;

output [23:0]   up_addr;
output          up_rd, up_wr, up_rnw, up_cs_;
output [31:0]   up_wrd;
input [31:0]    up_rdd;
input           up_rdy;
input           up_int, up_intoe;

////////////////////////////////////////////////////////////////////////////////
// Output declarations
reg             pint, prdy;
wire [31:0]     up_wrd;
wire [23:0]     up_addr;
wire [15:0]     pdo;
wire            pdoe, pintoe;
wire            up_rd, up_wr, up_rnw;
reg             up_cs_;


////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation
reg [15:0]      rdbuff_highword, wrbuff_lowword;
reg [12:0]      autogenrdy;
reg [15:0]      haddr, laddr;
reg             pcs1, pcs2, pcs3;

wire [15:0]     pdi;
wire            autogenrdy_inc, autordy;
wire            lowword_wrs, wrlowword_rdy;
wire            highword_rds;
wire            cs_ph1, cs_ph2, cs_ph3, up_cs;

always @(posedge sclk or negedge rst_)
    if (!rst_)
        begin
        pcs1 <= 1'b0;
        pcs2 <= 1'b0;
        pcs3 <= 1'b0;       
        end
    else if (!pcs)
        begin
        pcs1 <= 1'b0;
        pcs2 <= 1'b0;
        pcs3 <= 1'b0;       
        end
    else
        begin
        pcs1 <= pcs;
        pcs2 <= pcs1;
        pcs3 <= pcs2;       
        end     

assign cs_ph1 = pcs  & (!pcs1);
assign cs_ph2 = pcs1 & (!pcs2);
assign cs_ph3 = pcs2 & (!pcs3);

always @(posedge sclk or negedge rst_)
    if (!rst_)          haddr <= 16'h0;
    else if (cs_ph1)    haddr <= pdi;

always @(posedge sclk or negedge rst_)
    if (!rst_)          laddr <= 16'h0;
    else if (cs_ph2)    laddr <= pdi;

wire    read_cs,write_cs;        
assign  read_cs = cs_ph2 & !pdi[0] & !haddr[15];
assign  write_cs = cs_ph3 & laddr[0] & haddr[15];

always @ (posedge sclk or negedge rst_)
    begin
    if (!rst_)                      up_cs_ <= 1'b1;
    else if (!pcs)                  up_cs_ <= 1'b1;
    else if (read_cs | write_cs)    up_cs_ <= 1'b0;
    end

//assign  up_cs = (pcs2 & (!laddr[0]) & (!haddr[15])) |   // Rd Act @ Lo Word
//                (pcs2 & (laddr[0])  & (haddr[15]) ) ;   // Wr Act @ hi word
assign  up_rd = !haddr[15] & up_cs;
assign  up_wr = haddr[15] & up_cs;
assign  up_rnw = up_rd;
assign  up_cs = !up_cs_;

assign  up_addr = {haddr[8:0],laddr[15:1]}; // Word Base for CPLD
                                            // DWord Base for FPGA

assign  up_wrd = {pdi,wrbuff_lowword};

assign  lowword_wrs = cs_ph3 & haddr[15] & (!laddr[0]);

always @(posedge sclk or negedge rst_)
    if (!rst_)
        wrbuff_lowword <= 16'hCAFE;
    else if (lowword_wrs)
        wrbuff_lowword <= pdi;

assign  highword_rds = cs_ph3 & !haddr[15] & laddr[0];
always @(posedge sclk or negedge rst_)
    if (!rst_)
        rdbuff_highword <= 16'hCAFE;
    else if (up_rdy & up_rd)
        rdbuff_highword <= up_rdd[31:16];

// timeout
assign  autogenrdy_inc = (pcs & (autogenrdy < 13'hfff));

always @(posedge sclk or negedge rst_)
    if (!rst_)                  autogenrdy <= 13'h0;
    else if (autogenrdy_inc)    autogenrdy <= autogenrdy + 1'b1;
    else if (!pcs)              autogenrdy <= 13'h0;


assign  autordy = (autogenrdy == 13'hfff);
assign  pdo = autordy  ? 16'hCAFE        :
              laddr[0] ? rdbuff_highword : up_rdd[15:0];
assign  pdoe = pcs2 & (!haddr[15]);
 
always @(posedge sclk or negedge rst_)
    if (!rst_)                      
        prdy <= 1'b0;
    else if ((!pcs) & prdy)
        prdy <= 1'b0;
    else if (!(pcs1 & pcs2))
        prdy <= 1'b0;
    else if (pcs1)
        prdy <= lowword_wrs | highword_rds | up_rdy | prdy | autordy;
    else
        prdy <= 1'b0;

always @(posedge sclk or negedge rst_)
    if (!rst_)      pint <= 1'b0;
    else            pint <= up_int;

assign  pintoe = up_intoe;
endmodule