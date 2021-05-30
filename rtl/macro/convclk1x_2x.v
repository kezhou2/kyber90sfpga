////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : convclk1x_2x.v
// Description  : macro to convert data from clk1x to its double cycle clk2x.
//                It is required that clk1x is 90 degree delay compared to clk2x
//
// Author       : bqngoc@HW-BQNGOC
// Created On   : Fri Nov 19 13:27:24 2004
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module convclk1x_2x
    (
     rst1x_,
     rst2x_,
     clk2x,
     clk1x,

     scanmode,

     sync1x,
     data1x,

     sync2x,
     data2x
     );

parameter WIDTH = 8;

////////////////////////////////////////////////////////////////////////////////
// Port declarations
input   rst2x_,
        rst1x_,
        clk2x,
        clk1x;

input   scanmode;

input   sync1x;
input   [WIDTH-1:0]   data1x;

output  sync2x;
output  [WIDTH-1:0]   data2x;

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

//                      _____       _____       _____       _____      
// clk2x          _____|     |_____|     |_____|     |_____|     |
//                            ___________             ___________ 
// clk1x          ___________|           |___________|           |
//                            ___________             ___________ 
// phase_one_1x   ___________|           |___________|           |
//                _____             ___________             ___________ 
// phase_one_1xr       |___________|           |___________|           |
//                            _______________________ 
// sync1x         ___________|                       |____________
//                            _______________________ 
// data1x         -----------|_______________________|------------
//                                              ___________ 
// sync2x         _____________________________|           |____________
//                                              ___________ 
// data2x         -----------------------------|___________|------------


// clk1x signal is muxed with test pin in scanmode
wire                phase_one_1xr;

phasedet_ck1x   phasedet_ck1xi
    (
     .rst1x_    (rst1x_),
     .rst2x_    (rst2x_),
     .clk2x     (clk2x),
     .clk1x     (clk1x),

     .scanmode  (scanmode),

     .phaseout  (phase_one_1xr)
     );

reg     sync2x;
always @ (posedge clk2x or negedge rst2x_)
    begin
    if(!rst2x_) sync2x <= 1'b0;
    else if(phase_one_1xr) sync2x <= sync1x;
    else sync2x <= 1'b0;
    end

wire    [WIDTH-1:0]   data2x;
fflopxe #(WIDTH) dpp1x2x (clk2x, rst2x_, phase_one_1xr, data1x, data2x);

endmodule