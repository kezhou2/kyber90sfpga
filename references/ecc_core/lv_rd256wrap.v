////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : lv_rd256wrap.v
// Description  : .
//
// Author       : PC@DESKTOP-9FI2JF9
// Created On   : Sun Apr 07 20:04:51 2019
// History (Date, Changed By)
// For SIMULATION ONLY,  use true hw random generator for real world usage.
// this is 4 tap LFSR at 256 254 251 246
//
////////////////////////////////////////////////////////////////////////////////

module lv_rd256wrap
    (
     clk,
     rst,
     randvl //pseudo random
     );
////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

parameter WID = 256;
parameter SEED = 256'd134799733323198995502561713907086292154532538166959272814710328655875;

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input     clk;
input    rst;
output [WID-1:0] randvl;

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

reg [WID-1:0]    randreg;

always@(posedge clk)
    begin
    if(rst)
        begin
        randreg <= SEED;
        end
    else
        begin
        randreg[255] <= randreg[0];//first tap 256
        randreg[254] <= randreg[255];
        randreg[253] <= randreg[254] ^ randreg[0];//second tap 254
        randreg[252] <= randreg[253];
        randreg[251] <= randreg[252];
        randreg[250] <= randreg[251] ^ randreg[0]; // third tap 251
        randreg[249] <= randreg[250];
        randreg[248] <= randreg[249];
        randreg[247] <= randreg[248];
        randreg[246] <= randreg[247];
        randreg[245] <= randreg[246] ^ randreg[0];
        randreg[244:0] <= randreg[245:1];
        end
    end
assign randvl = randreg;
endmodule 
