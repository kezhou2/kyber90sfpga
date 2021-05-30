////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : convclk_grayffwr.v
// Description  : 
//      Fifo control with read and write @ diffrent clk domain
//      without losing data if depend on full and notempty signals 
//
//      A set of 1) convclk_grayffctrl.v - this is a sample cover
//               2) convclk_grayffwr.v - this is used in write clock domain
//               3) convclk_grayffrd.v - this is used in read clock domain
//
// Author       : Cao Trang Minh Tu
// Created On   : Mon Sep 08 14:39:59 2008
// History (Date, Changed By)
//
//  Origin developed by Nguyen Van Cuong, Tue Nov 21 16:16:20 2006
//      Maximum scale between 2 clk is 31 times
//      LEN >= 5 + 4*(wclk/rclk), with 4*(wclk/rclk) is integer  
//      eg: 4*(wclk/rclk) = 4.9 ~ 4 => LEN >= 5+4
//
//  Fri Sep 26 16:44:48 2008, ddduc
//      Reviewed and sanity check for macro use
//
////////////////////////////////////////////////////////////////////////////////

module convclk_grayffwr
    (
     wrclk,
     wrrst_,

     fifowr,
     fifoflush,
     fifofull,
     half_full,
     wrfifolen,
     wrpnt_gray,     //use to synchronize @ rdclk
     
     write,
     wraddr,

     // Read pointer @ rdclk
     rdpnt_gray
     );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations
parameter   ADDRB = 4;

////////////////////////////////////////////////////////////////////////////////
// Port declarations
input               wrclk;
input               wrrst_;

input               fifowr;
input               fifoflush;
output              fifofull;
output              half_full;  // for detailed internal status
output [ADDRB:0]    wrfifolen;  // for detailed internal status
output [ADDRB:0]    wrpnt_gray;

output              write;
output [ADDRB-1:0]  wraddr;

input [ADDRB:0]     rdpnt_gray;

////////////////////////////////////////////////////////////////////////////////
// Output declarations


////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

//synchronize read pointer
reg [ADDRB:0]       rdpnt_gray1,rdpnt_gray2;
always @ ( posedge wrclk or negedge wrrst_ )
    if(~wrrst_)
        begin
        rdpnt_gray1  <= {(ADDRB+1){1'b0}};
        rdpnt_gray2  <= {(ADDRB+1){1'b0}};
        end
    else
        begin
        rdpnt_gray1  <= rdpnt_gray;
        rdpnt_gray2  <= rdpnt_gray1;      
        end

reg [ADDRB:0] rdpnt_bin;    //read pointer after decode Gray code
integer       i;
always @ (rdpnt_gray2)
    begin
    for (i=0;i<(ADDRB+1);i=i+1)
    rdpnt_bin[i] = ^(rdpnt_gray2[ADDRB:0]>>i);
    end

//--------------------------------------------------
reg     [ADDRB:0]   wrpnt_bin;

//
wire                fifofull;
assign              fifofull    = (wrpnt_bin[ADDRB]^rdpnt_bin[ADDRB]) &
                                  (wrpnt_bin[ADDRB-1:0] == rdpnt_bin[ADDRB-1:0]);

wire [ADDRB:0]      sublen;
assign              sublen      = wrpnt_bin[ADDRB:0] - rdpnt_bin[ADDRB:0];

wire                half_full;
assign              half_full   = fifofull | sublen[ADDRB-1];

wire [ADDRB:0]      wrfifolen;
assign              wrfifolen   = sublen;

wire                write;
assign              write       = fifowr & (~fifofull);

wire [ADDRB-1:0]    wraddr;
assign              wraddr      = wrpnt_bin[ADDRB-1:0];

always @ ( posedge wrclk or negedge wrrst_ )
    if(~wrrst_)
        begin
        wrpnt_bin   <= {(ADDRB+1){1'b0}};
        end
    else
        begin
        if (fifoflush) wrpnt_bin <= {(ADDRB+1){1'b0}};
        else if (write) wrpnt_bin <= wrpnt_bin + 1'b1;      
        end

// Change wrcnt into gray code (so that only 1 bit change per posedge wclk)
// Ex: G_wrcnt[1:0] = 00 | 01 | 11 | 10

reg [ADDRB:0]       wrpnt_gray; //Gray Encode
always @ ( posedge wrclk or negedge wrrst_ )
    if(~wrrst_)
        begin
        wrpnt_gray   <= {(ADDRB+1){1'b0}};
        end
    else
        begin
        wrpnt_gray  <= wrpnt_bin ^ {1'b0,wrpnt_bin[ADDRB:1]};
        end


endmodule 
