////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : mondata.v
// Description  : .
//
// Author       : tdhcuong@HW-TDHCUONG
// Created On   : Thu Nov 04 09:41:57 2004
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module mondata
    (
     clk,
     rst_,
     
     idat,
     ival,
     ipar,
     
     errprbs,   // error prbs
     errpar     // error parity
     );

////////////////////////////////////////////////////////////////////////////////
// parameter

parameter DATABIT  = 32;
parameter PRBS_INI = 15'h0EE0;

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input     rst_;
input     clk;

input [DATABIT-1:0] idat;
input               ival;
input               ipar;

output              errprbs;
output              errpar;

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

reg [DATABIT-1:0]   idat1;
reg                 ipar1;
always @(posedge clk or negedge rst_)
    begin
    if(!rst_)
        begin
        idat1 <= {DATABIT{1'b0}};
        ipar1 <= 1'b0;
        end
    else
        begin
        idat1 <= idat;
        ipar1 <= ipar;
        end
    end
        
// check PRBS
reg [14:0]      prbsgen;
wire [14:0]     prbsin;
assign          prbsin  = {prbsgen[10] ^ prbsgen[12],
                           prbsgen[9] ^ prbsgen[11],
                           prbsgen[8] ^ prbsgen[10],
                           prbsgen[7] ^ prbsgen[9],
                           prbsgen[6] ^ prbsgen[8],
                           prbsgen[5] ^ prbsgen[7],
                           prbsgen[4] ^ prbsgen[6],
                           prbsgen[3] ^ prbsgen[5],
                           prbsgen[2] ^ prbsgen[4],
                           prbsgen[1] ^ prbsgen[3],
                           prbsgen[0] ^ prbsgen[2],
                           prbsgen[1] ^ prbsgen[13] ^ prbsgen[14],
                           prbsgen[0] ^ prbsgen[12] ^ prbsgen[13],
                           prbsgen[11] ^ prbsgen[12] ^ prbsgen[13] ^ prbsgen[14],
                           prbsgen[10] ^ prbsgen[11] ^ prbsgen[12] ^ prbsgen[13]};

wire [149:0]    predict;
assign          predict = {10{prbsgen}};

wire            errdata;
assign          errdata = ival & !(idat1 == predict[DATABIT-1:0]);

always @ ( posedge clk or negedge rst_ )
    if (!rst_)    prbsgen <= PRBS_INI;
    else if(ival) prbsgen <= errdata ? PRBS_INI : prbsin;

reg errprbs;
always @(posedge clk or negedge rst_)
    begin
    if(!rst_) errprbs <= 1'b0;
    else      errprbs <= errdata;
    end
        
// check parity
reg parcal;
always @(posedge clk or negedge rst_)
    begin
    if(!rst_) parcal <= 1'b0;
    else parcal <= ^(idat1);
    end

reg  errpar;
always @(posedge clk or negedge rst_)
    begin
    if(!rst_) errpar <= 1'b0;
    else      errpar <= !(parcal == ipar1);
    end

endmodule 
