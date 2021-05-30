////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : fifoc_anylenx.v
// Description  : This control fifo supports any length of fifo. The memories of
// This fifo is out side.
//
// Author       : nqlap@HW-NQLAP
// Created On   : Mon Nov 17 11:01:31 2003
// History (Date, Changed By)
//  Sun Sep 12 20:08:00 2004 ddduc@HW-DDDUC Adding flush signal
//  Tue Sep 30 14:14:54 2008 ddduc@HW-DDDUC Adding mem_re signal
//  
////////////////////////////////////////////////////////////////////////////////

module fifoc_anylenx
    (
     clk,
     rst_,

     // FIFO control
     fifowr,
     fiford,
     fifofsh,

     notempty,
     full,
     fifolen,

     // Memories interface
     mem_we,
     mem_wa,
     mem_re,
     mem_ra
    );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations
parameter LENGTH = 16;
parameter ADDRBIT = 4;

////////////////////////////////////////////////////////////////////////////////
// Port declarations
input clk;
input rst_;

// FIFO control
input fifowr;
input fiford;
input fifofsh;

output notempty;
output full;
output [ADDRBIT:0]  fifolen;

output mem_we;
output mem_re;
output [ADDRBIT-1:0] mem_wa;
output [ADDRBIT-1:0] mem_ra;
      
////////////////////////////////////////////////////////////////////////////////
// Output declarations


////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation
reg [ADDRBIT:0] fifolen;
reg [ADDRBIT-1:0] rdcnt;

wire [ADDRBIT:0] sumcnt;
assign           sumcnt = rdcnt + fifolen;
wire [ADDRBIT:0] over;
assign           over = sumcnt - LENGTH;
wire [ADDRBIT-1:0] wrcnt;
assign             wrcnt = over[ADDRBIT] ? sumcnt[ADDRBIT-1:0] : over[ADDRBIT-1:0];

wire    notempty;
assign  notempty = |fifolen;

//wire [ADDRBIT:0] checklen;
//assign           checklen = LENGTH - fifolen;
wire    checklen;
assign  checklen = LENGTH == fifolen;

wire    read;
assign  read = notempty & fiford;

wire    write;
assign  write = fifowr & (~full);

wire    full;
//assign  full = fifolen[ADDRBIT] | checklen[ADDRBIT];
assign  full = fifolen[ADDRBIT] | checklen;

wire [ADDRBIT-1:0] rdcntmax;
assign             rdcntmax = LENGTH - 1'b1;

wire    rdcntcry;
assign  rdcntcry = rdcnt == rdcntmax;

always @(posedge clk or negedge rst_)
    begin
    if (!rst_) rdcnt <= {ADDRBIT{1'b0}};
    else if (fifofsh) rdcnt <= {ADDRBIT{1'b0}};  
    else if (read) rdcnt <= rdcntcry ? {ADDRBIT{1'b0}} : rdcnt + 1'b1;
    end

always @(posedge clk or negedge rst_)
    begin
    if (!rst_) fifolen <= {1'b0,{ADDRBIT{1'b0}}};
    else if (fifofsh) fifolen <= {1'b0,{ADDRBIT{1'b0}}};
    else 
        begin
        case ({read,write})
            2'b01: fifolen <= fifolen + 1'b1;
            2'b10: fifolen <= fifolen - 1'b1;
            default: fifolen <= fifolen;
        endcase
        end
    end

wire [ADDRBIT-1:0] mem_wa;
assign             mem_wa = wrcnt;
wire [ADDRBIT-1:0] mem_ra;
assign             mem_ra = rdcnt;
wire               mem_we;
assign             mem_we = write;
wire               mem_re;
assign             mem_re = read;


// For Test Only
/*
reg [ADDRBIT:0]    lengmax;
always @(posedge clk or negedge rst_)
    begin
    if (!rst_) lengmax <= 0;
    else if (fifolen > lengmax) lengmax <= fifolen;
    end

reg [ADDRBIT:0]    entrycount;
always @(posedge clk or negedge rst_)
    begin
    if (!rst_) entrycount <= 0;
    else if (testtop.sync) entrycount <= 0;
    else if (write) entrycount <= entrycount + 1'b1;
    end
*/
endmodule 
