////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : rsteth.v
// Description  : create sync reset per clock.
//
// Author       : pvvu@HW-PVVU
// Created On   : 
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module rstsyn07
    (
     rst_,
     clk,
     scanmode,
     rstmsk,
     orst_
     );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations



////////////////////////////////////////////////////////////////////////////////
// Port declarations

input           rst_;
input  [6:0]    clk;
input           scanmode;
input  [6:0]    rstmsk;
output [6:0]    orst_;

////////////////////////////////////////////////////////////////////////////////
// Output declarations

wire    [6:0]   orst_;


////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation


rstsyn01 rstm0  (rst_, clk[0],  scanmode, rstmsk[0],  orst_[0]);
rstsyn01 rstm1  (rst_, clk[1],  scanmode, rstmsk[1],  orst_[1]);
rstsyn01 rstm2  (rst_, clk[2],  scanmode, rstmsk[2],  orst_[2]);
rstsyn01 rstm3  (rst_, clk[3],  scanmode, rstmsk[3],  orst_[3]);
rstsyn01 rstm4  (rst_, clk[4],  scanmode, rstmsk[4],  orst_[4]);
rstsyn01 rstm5  (rst_, clk[5],  scanmode, rstmsk[5],  orst_[5]);
rstsyn01 rstm6  (rst_, clk[6],  scanmode, rstmsk[6],  orst_[6]);

 
 
endmodule 

