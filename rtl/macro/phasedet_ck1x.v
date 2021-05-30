////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : phasedet_ck1x.v
// Description  : .
//
// Author       : lqcuong@atvn.com.vn
// Created On   : Fri Mar 23 17:46:14 2007
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module phasedet_ck1x
    (
     rst1x_,
     rst2x_,
     clk2x,
     clk1x,

     scanmode,

     phaseout
     );

////////////////////////////////////////////////////////////////////////////////
// Port declarations
input   rst1x_,
        rst2x_,
        clk2x,
        clk1x;

input   scanmode;

output  phaseout;

////////////////////////////////////////////////////////////////////////////////
// Output declarations

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

//                      _____       _____       _____       _____       _____       _____       _____       _____       _____
// clk2x          _____|     |_____|     |_____|     |_____|     |_____|     |_____|     |_____|     |_____|     |_____|     |
//                            ___________             ___________             ___________             ___________             __    
// clk1x          ___________|           |___________|           |___________|           |___________|           |___________|
//                            _____                   _____
// q1x            ___________|     |_________________|     |___ 
//                                  ___________             ___________             ___________             ___________
// phaseout                  ______|           |___________|           |___________|           |___________|           |___________|  


reg     phaseout;
wire    rstq1x_;

atmux1 scmux
    (
     .a     (rst1x_),
     .b     ((!phaseout) & rst1x_),
     .sela  (scanmode),
     .o     (rstq1x_)
     );

reg     q1x;
always @(posedge clk1x or negedge rstq1x_)
    if(!rstq1x_)    q1x <= 1'b0;
    else            q1x <= 1'b1;


always @(posedge clk2x or negedge rst2x_)
    if(!rst2x_) phaseout    <= 1'b0;
    else        phaseout    <= q1x;
    

endmodule 
