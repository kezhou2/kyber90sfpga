////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : montprowrap.v
// Description  : .
//
// Author       : hungnt@HW-NTHUNG
// Created On   : Thu Mar 07 13:39:47 2019
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////
module montprowrap
    (
     clk,
     rst,
     
     a,//input a
     b,//input b
     m,//input m
     r,//output result
     
     start, //enable
     vld
     );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations
`ifdef TEST
parameter WID = 4;
parameter CNTWID = 2;
parameter ZERO = 4'b0;
parameter IDLE = 1'b0;
parameter RUNNING = 1'b1;
`else
parameter WID = 256;
parameter CNTWID = 8;
parameter ZERO = 256'b0;
parameter IDLE = 1'b0;
parameter RUNNING = 1'b1;
`endif
////////////////////////////////////////////////////////////////////////////////
// Port declarations

input     clk;
input     rst;

input [WID-1:0] a;
input [WID-1:0] b;
input [WID-1:0] m;

output [WID-1:0] r;

input            start;
output           vld;

////////////////////////////////////////////////////////////////////////////////
// Output declarations

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

//controller FSM
reg              state;
reg [CNTWID-1:0] moncnt; //counter
reg              doneflag; //new flag fix done bug/fixing flag

wire             cntdone; //counter done flag
wire             isidle;//idle flag
wire             cntflg;//counter flag
wire             done;

assign           vld = doneflag;
assign           isidle = state == IDLE;
assign           done = isidle;//
assign           cntflg = !isidle;

//assign           cntdone = moncnt == -1'd1;
assign           cntdone = moncnt == -1'd1;

always@(posedge clk)
    begin
    if(rst)
        begin
        state <= IDLE;
        doneflag <= 1'b0;
        end
    else
        begin
        if(isidle)
            begin
            state <= start? RUNNING:IDLE;
            doneflag <= 1'b0;
            end
        else
            begin
            state <= cntdone? IDLE:RUNNING;
            doneflag <= cntdone? 1'b1 : 1'b0;
            end
        end
    end

//counter

always@(posedge clk)
    begin
    if(rst)
        begin
        moncnt <= ZERO;
        end
    else if(cntflg)
        begin
        moncnt <= moncnt + 1'b1;
        end
    else
        begin
        moncnt <= 0;
        end
    end

//shift control
//every clock

//moncore
wire [WID:0] corers;//core result of r

montpro #(WID,ZERO) imontpro
    (
     .clk(clk),
     .rst(rst),
     
     .a(a),//full bit of factor a
     .b(b),//full bit of factor b
     .m(m),//modulo
     
     //.shfta(), //shift reg ctrl a
     .ldnew(done),   //load reg a, reset r
     //.shftr(), //shift reg ctrl r
     
     .r(corers)//output
     );

//last substraction

wire [WID-1:0] lstrs; //last sub

assign         lstrs = (corers >= {1'b0,m})? (corers - {1'b0,m}) : corers; 

//output

assign         r = lstrs;

endmodule 
