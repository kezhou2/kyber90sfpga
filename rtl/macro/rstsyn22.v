////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : rstocn.v
// Description  : create sync reset per clock.
//
// Author       : pvvu@HW-PVVU
// Created On   : 
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module rstsyn22
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
input  [21:0]   clk;
input           scanmode;
input  [21:0]   rstmsk;
output [21:0]   orst_;

////////////////////////////////////////////////////////////////////////////////
// Output declarations

wire    [21:0]   orst_;


////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation


rstsyn01 rstm0  (rst_, clk[0],  scanmode, rstmsk[0],  orst_[0]);
rstsyn01 rstm1  (rst_, clk[1],  scanmode, rstmsk[1],  orst_[1]);
rstsyn01 rstm2  (rst_, clk[2],  scanmode, rstmsk[2],  orst_[2]);
rstsyn01 rstm3  (rst_, clk[3],  scanmode, rstmsk[3],  orst_[3]);
rstsyn01 rstm4  (rst_, clk[4],  scanmode, rstmsk[4],  orst_[4]);
rstsyn01 rstm5  (rst_, clk[5],  scanmode, rstmsk[5],  orst_[5]);
rstsyn01 rstm6  (rst_, clk[6],  scanmode, rstmsk[6],  orst_[6]);
rstsyn01 rstm7  (rst_, clk[7],  scanmode, rstmsk[7],  orst_[7]);
rstsyn01 rstm8  (rst_, clk[8],  scanmode, rstmsk[8],  orst_[8]);
rstsyn01 rstm9  (rst_, clk[9],  scanmode, rstmsk[9],  orst_[9]);
rstsyn01 rstm10 (rst_, clk[10], scanmode, rstmsk[10], orst_[10]);
rstsyn01 rstm11 (rst_, clk[11], scanmode, rstmsk[11], orst_[11]);
rstsyn01 rstm12 (rst_, clk[12], scanmode, rstmsk[12], orst_[12]);
rstsyn01 rstm13 (rst_, clk[13], scanmode, rstmsk[13], orst_[13]);
rstsyn01 rstm14 (rst_, clk[14], scanmode, rstmsk[14], orst_[14]);
rstsyn01 rstm15 (rst_, clk[15], scanmode, rstmsk[15], orst_[15]);
rstsyn01 rstm16 (rst_, clk[16], scanmode, rstmsk[16], orst_[16]);
rstsyn01 rstm17 (rst_, clk[17], scanmode, rstmsk[17], orst_[17]);
rstsyn01 rstm18 (rst_, clk[18], scanmode, rstmsk[18], orst_[18]);
rstsyn01 rstm19 (rst_, clk[19], scanmode, rstmsk[19], orst_[19]);
rstsyn01 rstm20 (rst_, clk[20], scanmode, rstmsk[20], orst_[20]);
rstsyn01 rstm21 (rst_, clk[21], scanmode, rstmsk[21], orst_[21]);


 
endmodule 

