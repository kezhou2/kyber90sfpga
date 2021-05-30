//////////////////////////////////////////////////////////////////////////////////
//
//  Arrive Technologies
//
// Filename        : fifox.v
// Description     : The fifo use registers as a memorie.
//
// Author          : ngocbq@atvn.com.vn
// Created On      : Wed Jul 30 09:49:23 2003
// History (Date, Changed By)
//  Wed Oct 01 13:27:19 2008, ddduc@HW-DDDUC,
//      add fifolen output
//      add parameter FIFODOUT_NOLATCH to latch fifodout
//      replace pohfifo into memfifo
// 
//////////////////////////////////////////////////////////////////////////////////
module fifox
    (
     clk,
     rst_,
     fiford,        // fifo read signal
     fifowr,        // fifo write signal
     fifodin,       // fifo data in
     fifofull,      // fifo full signal, high when fifo is full
     fifolen,       // fifo len
     notempty,      // fifo not empty signal, high when fifo is not empty
     fifodout       // fifo data out
     );

parameter ADDRBIT = 4;
parameter LENGTH = 16;
parameter WIDTH = 8;
parameter FIFODOUT_NOLATCH = 1'b1;

input   clk,
        rst_,
        fiford,
        fifowr;

input [WIDTH-1:0] fifodin;

output  fifofull,
        notempty;

output [ADDRBIT:0] fifolen;

output  [WIDTH-1:0] fifodout;


reg     [WIDTH-1:0]     memfifo [LENGTH-1:0];
reg     [ADDRBIT:0]     fifo_len;
reg     [ADDRBIT-1:0]   wrcnt;

wire    fifoempt;
assign  fifoempt    =   (fifo_len=={1'b0,{ADDRBIT{1'b0}}});

wire    notempty;
assign  notempty    =   !fifoempt;

wire    fifofull;
assign  fifofull    =   (fifo_len[ADDRBIT]);

assign  fifolen     =   fifo_len;

wire    write;
assign  write       =   (fifowr& !fifofull);

wire    read;
assign  read        =   (fiford& !fifoempt);

wire    [ADDRBIT-1:0]   rdcnt;
assign  rdcnt       =   wrcnt - fifo_len[ADDRBIT-1:0];

integer     i;
always @(posedge clk or negedge rst_)
    begin
    if(!rst_) for(i=0; i<LENGTH; i=i+1) memfifo[i] <= {WIDTH{1'b0}};
    else if(write) memfifo[wrcnt] <= fifodin;
    end


always @(posedge clk or negedge rst_)
    begin
    if(!rst_)       wrcnt <= {ADDRBIT{1'b0}};
    else if(write)  wrcnt    <= wrcnt  + 1'b1;
    end

always @(posedge clk or negedge rst_)
    begin
    if(!rst_) fifo_len  <= {1'b0,{ADDRBIT{1'b0}}};
    else
        case({read,write})
        2'b01: fifo_len <= fifo_len + 1'b1;
        2'b10: fifo_len <= fifo_len - 1'b1;
        default: fifo_len <= fifo_len;
        endcase
    end

reg     [WIDTH-1:0] fifodout;
always @(posedge clk or negedge rst_)
    begin
    if(!rst_) fifodout <= {WIDTH{1'b0}};
    else if(read) fifodout <= memfifo[rdcnt];
    //else fifodout <= {WIDTH{1'b0}};
    else if(FIFODOUT_NOLATCH) fifodout <= {WIDTH{1'b0}};
    end

endmodule // fifox
