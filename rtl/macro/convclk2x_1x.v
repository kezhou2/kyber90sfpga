////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : convclk2x_1x.v
// Description  : macro to convert data from clk2x to its haft cycle clk1x.
//                It is required that clk1x is 90 degree delay compared to clk2x
//
// Author       : bqngoc@HW-BQNGOC
// Created On   : Fri Nov 19 13:27:24 2004
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module convclk2x_1x
    (
     rst1x_,
     rst2x_,
     clk2x,
     clk1x,

     scanmode,

     sync2x,
     data2x,
     
     sync1x,
     data1x,

     phaseout
     );

parameter WIDTH = 8;

////////////////////////////////////////////////////////////////////////////////
// Port declarations
input   rst1x_,
        rst2x_,
        clk2x,
        clk1x;

input   scanmode;

input   sync2x;
input   [WIDTH-1:0]   data2x;

output  sync1x;
output  [WIDTH-1:0]   data1x;

output                phaseout;

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation


////////////////////- in case (sync2xp&phase_one_1xr == 1) -///////////////////
//                    ___     ___     ___     ___     ___     ___      
// clk2x          ___|   |___|   |___|   |___|   |___|   |___|   |
//                        _______         _______         _______ 
// clk1x          _______|       |_______|       |_______|       |
//                        _______         _______         _______ 
// phase_one_1x   _______|       |_______|       |_______|       |
//                ___         _______         _______         _____ 
// phase_one_1xr     |_______|       |_______|       |_______|     
//                            _______ 
// sync2xp        ___________|       |____________
//                            _______ 
// data2xp       ------------|_______|------------
//                                    _______ 
// sync2xp1              ____________|       |____________
//                                    _______ 
// data2xp1              ------------|_______|------------
//                                                            
// selphase1              ________________________________________
//                                    _______________ 
// sync2x_1x                _________|               |____________
//                                    _______________ 
// data2x_1x                ---------|_______________|------------
//                                        _______________ 
// sync1x                     ___________|               |____________
//                                        _______________ 
// data1x                     -----------|_______________|------------
//
////////////////////////////////////////////////////////////////////////////////

////////////////////- in case (sync2xp1&phase_one_1xr == 1) -///////////////////
//                    ___     ___     ___     ___     ___     ___      
// clk2x          ___|   |___|   |___|   |___|   |___|   |___|   |
//                        _______         _______         _______ 
// clk1x          _______|       |_______|       |_______|       |
//                        _______         _______         _______ 
// phase_one_1x   _______|       |_______|       |_______|       |
//                ___         _______         _______         _____ 
// phase_one_1xr     |_______|       |_______|       |_______|     
//                                    _______ 
// sync2xp                ___________|       |____________
//                                    _______ 
// data2xp               ------------|_______|------------
//                                            _______ 
// sync2xp1                      ____________|       |____________
//                                            _______ 
// data2xp1                      ------------|_______|------------
//                               _________________________________    
// selphase1                                                          
//                                                    _______________ 
// sync2x_1x                                _________|               |_________
//                                                    _______________ 
// data2x_1x                                ---------|_______________|---------
//                                                        _______________ 
// sync1x                                     ___________|               |_____
//                                                        _______________ 
// data1x                                     -----------|_______________|-----
//
////////////////////////////////////////////////////////////////////////////////

// clk1x signal is muxed with test pin in scanmode

wire                  phase_one_1xr;

phasedet_ck1x   phasedet_ck1xi
    (
     .rst1x_    (rst1x_),
     .rst2x_    (rst2x_),
     .clk2x     (clk2x),
     .clk1x     (clk1x),

     .scanmode  (scanmode),

     .phaseout  (phase_one_1xr)
     );

// pipeline input 
wire    sync2xp;
wire    [WIDTH-1:0]   data2xp;
fflopx #(WIDTH+1) ipp(clk2x, rst2x_, {sync2x, data2x}, {sync2xp, data2xp});

// pipeline one more for capture incase sync2xp is not at phase_one_1x
wire    sync2xp1;
wire    [WIDTH-1:0]   data2xp1;
fflopx #(WIDTH+1) ipp1(clk2x, rst2x_, {sync2xp, data2xp}, {sync2xp1, data2xp1});

// select which phase to capture data
reg     selphase1;
always @ (posedge clk2x or negedge rst2x_)
    begin
    if(!rst2x_) selphase1 <= 1'b0;
    else if(sync2xp & phase_one_1xr) selphase1 <= 1'b0;
    else if(sync2xp1 & phase_one_1xr) selphase1 <= 1'b1;
    end

// sync signal to clk1x
reg     sync2x_1x;
always @ (posedge clk2x or negedge rst2x_)
    begin
    if(!rst2x_) sync2x_1x <= 1'b0;
    else if(selphase1)
        begin
        if(phase_one_1xr) sync2x_1x <= sync2xp1;
        end
    else
        begin
        if(phase_one_1xr) sync2x_1x <= sync2xp;
        end
    end

reg     [WIDTH-1:0]   data2x_1x;
always @ (posedge clk2x or negedge rst2x_)
    begin
    if(!rst2x_) data2x_1x <= {WIDTH{1'b0}};
    else if(selphase1)
        begin
        if(phase_one_1xr) data2x_1x <= data2xp1;
        end
    else
        begin
        if(phase_one_1xr) data2x_1x <= data2xp;
        end
    end

// capture data and sync at clk1x
reg     sync1x;
always @ (posedge clk1x or negedge rst1x_)
    begin
    if(!rst1x_) sync1x <= 1'b0;
    else sync1x <= sync2x_1x;
    end

reg     [WIDTH-1:0]   data1x;
always @ (posedge clk1x or negedge rst1x_)
    begin
    if(!rst1x_) data1x <= {WIDTH{1'b0}};
    else data1x <= data2x_1x;
    end

assign phaseout = selphase1;

endmodule