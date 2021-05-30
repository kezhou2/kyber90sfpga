////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : gendata.v
// Description  : .
//
// Author       : tdhcuong@HW-TDHCUONG
// Created On   : Sat Oct 23 07:59:36 2004
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module gendata
    (
     rst_,
     clk,

     testmode,      // 1 : testmode
     inserrprbs,    // insert error for prbs
     inserrpar,     // insert error for parity
     
     idat,
     odat,
     opar
     );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

parameter DATABIT = 32;
parameter INIT    = 15'h7fff;

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input                rst_;
input                clk;

input                testmode;
input                inserrprbs;
input                inserrpar;

input [DATABIT-1:0]  idat;
output [DATABIT-1:0] odat;
output               opar;

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

// gen data PRBS for testing
reg [14:0]  prbsreg;
always @ (posedge clk or negedge rst_)
    begin
    if(!rst_) prbsreg <= INIT;
    else prbsreg <= {prbsreg[10] ^ prbsreg[12],
                     prbsreg[9] ^ prbsreg[11],
                     prbsreg[8] ^ prbsreg[10],
                     prbsreg[7] ^ prbsreg[9],
                     prbsreg[6] ^ prbsreg[8],
                     prbsreg[5] ^ prbsreg[7],
                     prbsreg[4] ^ prbsreg[6],
                     prbsreg[3] ^ prbsreg[5],
                     prbsreg[2] ^ prbsreg[4],
                     prbsreg[1] ^ prbsreg[3],
                     prbsreg[0] ^ prbsreg[2],
                     prbsreg[1] ^ prbsreg[13] ^ prbsreg[14],
                     prbsreg[0] ^ prbsreg[12] ^ prbsreg[13],
                     prbsreg[11] ^ prbsreg[12] ^ prbsreg[13] ^ prbsreg[14],
                     prbsreg[10] ^ prbsreg[11] ^ prbsreg[12] ^ prbsreg[13]};
    end

wire    [149:0] data,data_err; //force err prbs
assign         data     = {10{prbsreg}};
assign         data_err = {data[149:1],data[0]^inserrprbs};

reg [DATABIT-1:0]  daprbs;
always @ (posedge clk or negedge rst_)
    begin
    if(!rst_) daprbs <= {DATABIT{1'b0}};
    else      daprbs <= data_err[DATABIT-1:0];
    end

// select data
assign  odat = testmode ? daprbs : idat;

// calculate parity
reg     opar;
always @(posedge clk or negedge rst_)
    begin
    if(!rst_)          opar <= 1'b0;
    else if(inserrpar) opar <= !(^(odat));
    else               opar <= ^(odat);
    end

endmodule 
