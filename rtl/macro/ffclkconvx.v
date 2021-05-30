//////////////////////////////////////////////////////////////////////////////////
//
//  Arrive Technologies
//
// Filename        : ffclkconvx.v
// Description     : Fifo clock converter control module. this macro uses to synchronize
//                   two data stream @ different clk domain.
//
// Author          : lapnq@atvn.com.vn
// Created On      : Tue Jul 29 18:12:07 2003
// History (Date, Changed By)
//
//////////////////////////////////////////////////////////////////////////////////

module ffclkconvx
    (
     wrclk,     // clk of data write
     rdclk,     // clk of data read
     rst_,

     winsize,   // window size threshold to slip
     forceslip, // force slip buffer
     
                // Connect to memories
     wraddr,    // @+wrclk write address of memories
     rdaddr     // @+rdclk read address of memories
     );

parameter ADDRBIT = 4;
parameter WIN_WIDTH = 2;

parameter OFFSET = 2'd2; // the number clk cycle need to synchronize.
parameter RDCNT_RST = {1'b1,{ADDRBIT-1{1'b0}}};
parameter RDCNT_SLP = RDCNT_RST + OFFSET;
input   wrclk;
input   rdclk;

input   rst_;

input [WIN_WIDTH -1 :0] winsize;

input   forceslip;

output [ADDRBIT-1:0] wraddr;
output [ADDRBIT-1:0] rdaddr;

reg     [ADDRBIT-1:0]   wrcnt;

wire    [ADDRBIT-1:0] wraddr;
assign  wraddr = wrcnt;

reg     [ADDRBIT-1:0]   rdcnt;

wire    [ADDRBIT-1:0] rdaddr;
assign  rdaddr = rdcnt;

always @(posedge wrclk or negedge rst_)
    begin
    if(!rst_) wrcnt <= {ADDRBIT{1'b0}};
    else if (forceslip) wrcnt <= {ADDRBIT{1'b0}};
    else wrcnt  <= wrcnt  + 1'b1;
    end

wire     sync;
assign   sync = ~wrcnt[ADDRBIT-1];

reg [1:0] shiftsync;
always @(posedge rdclk or negedge rst_)
    begin
    if (!rst_) shiftsync <= 2'b00;
    else shiftsync <= {shiftsync[0],sync};
    end
wire    syncedg;
assign  syncedg = {shiftsync,sync} == 3'b011;

wire [ADDRBIT-1:0] window; // The current window size (entry count)
assign             window = rdcnt - OFFSET ;

wire [ADDRBIT-1:0] size; 
assign size = window[ADDRBIT-1] ? (winsize + window[ADDRBIT-2:0]) :
                                  (window - winsize);

wire   slipped;
assign slipped = syncedg & size[ADDRBIT-1];

always @(posedge rdclk or negedge rst_)
    begin
    if(!rst_) rdcnt <= RDCNT_RST;
    else if (forceslip) rdcnt <= RDCNT_RST;
    else if (slipped) rdcnt <= RDCNT_SLP;
    else rdcnt <= rdcnt + 1'b1;
    end

endmodule
