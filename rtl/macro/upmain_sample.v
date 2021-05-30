////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : upmain.v
// Description  : .
//
// Author       : ddduc@HW-DDDUC
// Created On   : Fri Feb 13 19:05:01 2004
// History (Date, Changed By)
//  Fri Oct 24 17:29:24 2008, ddduc@HW-DDDUC
//      This sample adds logic MUX for CPU data out instead of logic OR.
//
////////////////////////////////////////////////////////////////////////////////

module upmain
    (
     //-GLOBAL--------------------------
     rst_,
     clk311,
     clk155,
     clk208,
     
     //-CPU INTERFACE-------------------
     eupa,       
     eupce_,
     euprnw,
     eupdi,
     eupdo,
     eupack,
     eupint,

     //-COMMON SIGNAL-------------------
     
     //-INTERNAL CPU BUS----------------
     // COMMON    
     upa,
     upactive,
     updi,

     // @311
     uprs_311,
     upws_311,
     
     // @155
     uprs_155,
     upws_155,
     
     // @208
     uprs_208,
     upws_208,

     // CPU ENABLE
     upen_xdemap_311,
     upen_xdemap_155,
     upen_xdemap_208,
     upen_xplp_311,
     upen_xplp_155,
     upen_xplp1,
     upen_xplp2,
     upen_xif,
     upen_pmap_311,
     upen_pmap_155,
     upen_pplp_311,
     upen_pplp_155,
     upen_pif,
     
     // INPUT
     updo_xdemap_311,
     uprdy_xdemap_311,
     upint_xdemap_311,
     updo_xdemap_155,
     uprdy_xdemap_155,
     upint_xdemap_155,
     updo_xdemap_208,
     uprdy_xdemap_208,
     upint_xdemap_208,
     updo_xplp_311,
     uprdy_xplp_311,
     upint_xplp_311,
     updo_xplp_155,
     uprdy_xplp_155,
     upint_xplp_155,
     updo_xif,
     uprdy_xif,
     upint_xif,

     updo_pmap_311,
     uprdy_pmap_311,
     upint_pmap_311,
     updo_pmap_155,
     uprdy_pmap_155,
     upint_pmap_155,
     updo_pplp_311,
     uprdy_pplp_311,
     upint_pplp_311,
     updo_pplp_155,
     uprdy_pplp_155,
     upint_pplp_155,
     updo_pif,
     uprdy_pif,
     upint_pif,

     // JTAG
     scanmode

     );

////////////////////////////////////////////////////////////////////////////////
// Port declarations

     //-GLOBAL--------------------------
input           rst_;       // global active low reset signal
input           clk311;     // system clk
input           clk155;     // system clk
input           clk208;     //

     //-CPU INTERFACE-------------------
input [23:0]    eupa;       // cpu address       
input           eupce_;     // cpu chip select
input           euprnw;     // cpu read assertion
input [31:0]    eupdi;      // cpu data in
output [31:0]   eupdo;      // cpu data out
output          eupack;     // cpu ACK
output          eupint;     // cpu interrupt

     //-COMMON SIGNAL-------------------
     
     //-INTERNAL CPU BUS----------------
     // COMMON    
output [23:0]   upa;
output          upactive;
output [31:0]   updi;

     // @311
output          uprs_311;
output          upws_311;
     
     // @155
output          uprs_155;
output          upws_155;
     
     // @208
output          uprs_208;
output          upws_208;
     
     // CPU ENABLE
output          upen_xdemap_311;
output          upen_xdemap_155;
output          upen_xdemap_208;
output          upen_xplp_311;
output          upen_xplp_155;
output          upen_xplp1;
output          upen_xplp2;
output          upen_xif;
output          upen_pmap_311;
output          upen_pmap_155;
output          upen_pplp_311;
output          upen_pplp_155;
output          upen_pif;

     // INPUT
input [31:0]    updo_xdemap_311;
input           uprdy_xdemap_311;
input           upint_xdemap_311;
input [31:0]    updo_xdemap_155;
input           uprdy_xdemap_155;
input           upint_xdemap_155;
input [31:0]    updo_xdemap_208;
input           uprdy_xdemap_208;
input           upint_xdemap_208;
input [31:0]    updo_xplp_311;
input           uprdy_xplp_311;
input           upint_xplp_311;
input [31:0]    updo_xplp_155;
input           uprdy_xplp_155;
input           upint_xplp_155;
input [31:0]    updo_xif;
input           uprdy_xif;
input           upint_xif;

input [31:0]    updo_pmap_311;
input           uprdy_pmap_311;
input           upint_pmap_311;
input [31:0]    updo_pmap_155;
input           uprdy_pmap_155;
input           upint_pmap_155;
input [31:0]    updo_pplp_311;
input           uprdy_pplp_311;
input           upint_pplp_311;
input [31:0]    updo_pplp_155;
input           uprdy_pplp_155;
input           upint_pplp_155;
input [31:0]    updo_pif;
input           uprdy_pif;
input           upint_pif;

input           scanmode;
         
////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation
wire            uprs;
wire            upws;
wire            upen_main;

// CPU
assign upa      = eupa;
assign updi     = eupdi;


// @311
wire            eupce311_;
rwsgen rwsgen311 (clk311,rst_,eupce_,euprnw,upws_311,uprs_311,scanmode);

// @155
wire            eupce155_;
rwsgen rwsgen155 (clk155,rst_,eupce_,euprnw,upws_155,uprs_155,scanmode);

// @208
wire            eupce208_;
rwsgen rwsgen208 (clk208,rst_,eupce_,euprnw,upws_208,uprs_208,scanmode);

// Decode CPU address
wire            upen_xdemap;
wire            upen_xplp;
wire            upen_pmap;
wire            upen_pplp;
assign upen_main    = upa[23:21] == 3'b000;
assign upen_xdemap  = upa[23:21] == 3'b000;
assign upen_xplp    = upa[23:21] == 3'b001;
assign upen_xplp1   = (upa[23:21] == 3'b001) & (upa[20:19] == 2'b01);
assign upen_xplp2   = (upa[23:21] == 3'b001) & (upa[20:19] == 2'b10);
assign upen_xif     = upa[23:21] == 3'b010;
assign upen_pmap    = upa[23:21] == 3'b100;
assign upen_pplp    = upa[23:21] == 3'b101;
assign upen_pif     = upa[23:21] == 3'b110;

assign upen_xdemap_311  = upen_xdemap & (upa[20:19] == 2'b00);
assign upen_xdemap_155  = upen_xdemap & (upa[20:19] == 2'b01);
assign upen_xdemap_208  = upen_xdemap & (upa[20:19] == 2'b10);
assign upen_xplp_311    = upen_xplp & (!upa[20]);
assign upen_xplp_155    = upen_xplp & upa[20];
assign upen_pmap_311    = upen_pmap & (!upa[20]);
assign upen_pmap_155    = upen_pmap & upa[20];
assign upen_pplp_311    = upen_pplp & (!upa[20]);
assign upen_pplp_155    = upen_pplp & upa[20];


// Mux inputs
wire            upint_311,upint_155,upint_208,upint_main;
wire            uprdy_311,uprdy_155,uprdy_208,uprdy_main;
wire [31:0]     updo_311,updo_155,updo_208,updo_main;

assign upint_main   = 1'b0;
assign uprdy_main   = 1'b0;
assign updo_main    = 32'b0;

assign upint_311    = upint_xdemap_311 | upint_xplp_311 | 
                      upint_pmap_311   | upint_pplp_311 | upint_pif |
                      upint_main;

// This style is used in AT4848 and AT2450, we want to use a multiplexer to prevent 
// the one block can generate wrong RDY or DATA effecting other blocks
//
assign uprdy_311    = upen_xdemap_311   ? uprdy_xdemap_311  :
                      upen_xplp_311     ? uprdy_xplp_311    :
                      upen_pmap_311     ? uprdy_pmap_311    :
                      upen_pplp_311     ? uprdy_pplp_311    :
                      upen_pif          ? uprdy_pif         :
                                          uprdy_main;
assign updo_311     = upen_xdemap_311   ? updo_xdemap_311   :
                      upen_xplp_311     ? updo_xplp_311     :
                      upen_pmap_311     ? updo_pmap_311     :
                      upen_pplp_311     ? updo_pplp_311     :
                      upen_pif          ? updo_pif          :
                                          updo_main;
//assign uprdy_311    = uprdy_xdemap_311 | uprdy_xplp_311 |
//                      uprdy_pmap_311   | uprdy_pplp_311 | uprdy_pif |
//                      uprdy_main;
//assign updo_311     = updo_xdemap_311  | updo_xplp_311  |
//                      updo_pmap_311    | updo_pplp_311  | updo_pif  |
//                      uprdy_main;


assign upint_155    = upint_xdemap_155 | upint_xplp_155 |
                      upint_pmap_155   | upint_pplp_155;

// This style is used in AT4848 and AT2450, we want to use multiplexer to prevent 
// the one block can generate wrong RDY or DATA effecting other blocks
//
assign uprdy_155    = upen_xdemap_155   ? uprdy_xdemap_155  :
                      upen_xplp_155     ? uprdy_xplp_155    :
                      upen_pmap_155     ? uprdy_pmap_155    :
                                          uprdy_pplp_155;
assign updo_155     = upen_xdemap_155   ? updo_xdemap_155   :
                      upen_xplp_155     ? updo_xplp_155     :
                      upen_pmap_155     ? updo_pmap_155     :
                                          updo_pplp_155;
//assign uprdy_155    = uprdy_xdemap_155 | uprdy_xplp_155 |
//                      uprdy_pmap_155   | uprdy_pplp_155;
//assign updo_155     = updo_xdemap_155  | updo_xplp_155  |
//                      updo_pmap_155    | updo_pplp_155;


assign upint_208    = upint_xdemap_208 | upint_xif;

// This style is used in AT4848 and AT2450, we want to use a multiplexer to prevent 
// the one block can generate wrong RDY or DATA effecting other blocks


assign uprdy_208    = upen_xdemap_208   ? uprdy_xdemap_208  :
                                          uprdy_xif;
assign updo_208     = upen_xdemap_208   ? updo_xdemap_208   :
                                          updo_xif;
//assign uprdy_208    = uprdy_xdemap_208 | uprdy_xif;
//assign updo_208     = updo_xdemap_208  | updo_xif;



// Generate cpu ready
wire [2:0]  uprdygen;
rdygen rdygen311 (rst_,clk311,eupce_,scanmode,uprdy_311,uprdygen[0]);
rdygen rdygen115 (rst_,clk155,eupce_,scanmode,uprdy_155,uprdygen[1]);
rdygen rdygen208 (rst_,clk208,eupce_,scanmode,uprdy_208,uprdygen[2]);

wire        eupack;
assign eupack       = |uprdygen;

// Send interrupt and data out
wire        eupint;
assign eupdo    = updo_311 | updo_155 | updo_208;
assign eupint   = upint_311 | upint_155 | upint_208;

//
assign upactive = 1'b0;


endmodule 
