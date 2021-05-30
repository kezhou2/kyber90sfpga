//////////////////////////////////////////////////////////////////////////////////
//
//  Arrive Technologies
//
// Filename        : fifoc_fshx.v (based on fifoctrl.v)
// Description     : Fifo control module. This macro controls write, read counters and
//                   fifofull, notempty signals. the memories of this fifo is outside.
//                   WITH FLUSHING
//
// Author          : lapnq@atvn.com.vn
// Created On      : Tue Jul 29 18:12:07 2003
// History (Date, Changed By)
//  Tue Aug 10 16:25:36 2004 ddduc@HW-DDDUC Adding FLUSHING feature
//  Tue Sep 30 13:20:23 2008 ddduc@HW-DDDUC Adding signals fifolen, read
//
//////////////////////////////////////////////////////////////////////////////////

module fifoc_fshx
    (
     clk,
     rst_,
     
     fiford,    // FIFO control
     fifowr,
     fifofsh,   // FIFO flush

     fifofull,  // high when fifo full
     notempty,  // high when fifo not empty
     fifolen,   

                // Connect to memories
     write,     // enable to write memories
     wraddr,    // write address of memories
     read,      // enable to read memories
     rdaddr     // read address of memories
     );

parameter ADDRBIT = 4;
parameter LENGTH = 16;

input   clk,
        rst_,
        fiford,
        fifowr,
        fifofsh;

output  fifofull,
        notempty;

output [ADDRBIT:0]  fifolen;

output  write;
output  read;

output [ADDRBIT-1:0] wraddr;
output [ADDRBIT-1:0] rdaddr;

reg     [ADDRBIT:0]   fifo_len;
reg     [ADDRBIT-1:0] wrcnt;

wire    [ADDRBIT-1:0] wraddr;
assign  wraddr = wrcnt;

wire    fifoempt;
assign  fifoempt    =   (fifo_len=={1'b0,{ADDRBIT{1'b0}}});

wire    notempty;
assign  notempty    =   !fifoempt;

wire    fifofull;
assign  fifofull    =   (fifo_len[ADDRBIT]);

wire    write;
assign  write       =   (fifowr& !fifofull);

wire    read;
assign  read        =   (fiford& !fifoempt);

wire    [ADDRBIT-1:0]   rdcnt;
assign  rdcnt       =   wrcnt - fifo_len[ADDRBIT-1:0];

wire    [ADDRBIT-1:0] rdaddr;
assign  rdaddr = rdcnt;

assign  fifolen = fifo_len;

always @(posedge clk or negedge rst_)
    begin
    if(!rst_) wrcnt <= {ADDRBIT{1'b0}};
    else if (fifofsh) wrcnt <= {ADDRBIT{1'b0}};
    else if (write) wrcnt   <= wrcnt  + 1'b1;
    end

always @(posedge clk or negedge rst_)
    begin
    if(!rst_) fifo_len  <= {1'b0,{ADDRBIT{1'b0}}};
    else if (fifofsh) fifo_len  <= {1'b0,{ADDRBIT{1'b0}}};
    else
        case({read,write})
        2'b01: fifo_len <= fifo_len + 1'b1;
        2'b10: fifo_len <= fifo_len - 1'b1;
        default: fifo_len <= fifo_len;
        endcase
    end

endmodule
