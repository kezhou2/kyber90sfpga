////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : rstsyn.v
// Description  : create sync reset per clock.
//
// Author       : pvvu@HW-PVVU
// Created On   : 
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////
module rstsyn01
    (
     rst_,
     clk,
     scanmode,
     rstmsk,
     orst_
     );

input  rst_;
input  clk;
input  scanmode;
input  rstmsk;

output orst_;

wire   orst_;

reg [1:0] store;
always @(posedge clk or negedge rst_)
    begin
    if (!rst_) store <= 2'b00;
    else       store <= {store[0], rstmsk};
    end

//assign orst_ = scanmode ? rst_ : store[1];
atmux1 muxi(.a(rst_), .b(store[1]), .sela(scanmode), .o(orst_));

endmodule 

