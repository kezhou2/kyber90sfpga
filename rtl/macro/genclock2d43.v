////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : genclock2d43.v
// Description  : Generates clock 2.43MHz from 19.44MHz with Frame sync
//                Developing based on genclock4d86.v
//
// Author       : hw-ndthanh
// Created On   : Fri Jan 12 14:17:48 2007
// History (Date, Changed By)
//  + Mon Mar 19 10:56:35 2007: shift clk4 phase from 270 to 180 
//              for the same with europa, by hw-ndthanh
//
////////////////////////////////////////////////////////////////////////////////

// Update: Mon Mar 19 10:58:30 2007
////////////////////////////////////////////////////////////////////////////////
// Input requirements
// In mode sync4m, It has one high pulse and three low pulses in sequence
//                     __    __    __    __    __
// clk19        __//__|  |__|  |__|  |__|  |__|  |__|
//                     _____                   _____
// bp_fmsync    __//__|     |_________________|     |____
//
// In mode sync2m, It has one high pulse and seven low pulses in sequence
//                     __    __    __    __    __    __    __    __    __    __
// clk19        __//__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |
//                     _____                                           _____
// bp_fmsync    __//__|     |_________________________________________|     |_
//                     _____  _____  _____  _____  _____  _____  _____  _____  _____  
//                       7  \/  0  \/  1  \/  2  \/  3  \/  4  \/  5  \/  6  \/  7  
// cnt2                _____/\_____/\_____/\_____/\_____/\_____/\_____/\_____/\_____
//                    ______                              ___________________________
//                          |____________________________|
// clk2                     
//                     _____  _____  _____  _____  _____  _____  _____  _____  
//                    /  3  \/  0  \/  1  \/  2  \/  3  \/  0  \/  1  \/  2  
// cnt4               \_____/\_____/\_____/\_____/\_____/\_____/\_____/\_____
//                    ______                _____________               _____
//                          |______________|             |_____________|
// clk4                     
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Input requirements
// In mode sync4m, It has one high pulse and three low pulses in sequence
//                     __    __    __    __    __
// clk19        __//__|  |__|  |__|  |__|  |__|  |__|
//                     _____                   _____
// bp_fmsync    __//__|     |_________________|     |____
//
// In mode sync2m, It has one high pulse and seven low pulses in sequence
//                     __    __    __    __    __    __    __    __    __    __
// clk19        __//__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |
//                     _____                                           _____
// bp_fmsync    __//__|     |_________________________________________|     |_
//                     _____  _____  _____  _____  _____  _____  _____  _____  _____  
//                       7  \/  0  \/  1  \/  2  \/  3  \/  4  \/  5  \/  6  \/  7  
// cnt2                _____/\_____/\_____/\_____/\_____/\_____/\_____/\_____/\_____
//                    ______                              ___________________________
//                          |____________________________|
// clk2                     
//                     _____  _____  _____  _____  _____  _____  _____  _____  _____  
//                       2  \/  3  \/  0  \/  1  \/  2  \/  3  \/  0  \/  1  \/  2  
// cnt4                _____/\_____/\_____/\_____/\_____/\_____/\_____/\_____/\_____
//                    _____________                _____________               _____
//                                 |______________|             |_____________|
// clk4                     
////////////////////////////////////////////////////////////////////////////////

module genclock2d43
    (
     rst_,
     iclk19,
     frmsync,
     oclk2d43,
     oclk4d86
     );

////////////////////////////////////////////////////////////////////////////////
// Port declarations
parameter CNT2_RST = 0;
//parameter CNT4_RST = 3;
parameter CNT4_RST = 0; //changed by ndthanh, Mon Mar 19 10:59:48 2007

input           rst_;
input           iclk19;
input           frmsync;
output          oclk2d43;
output          oclk4d86;

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

reg             frmsync_rt; // re-time multiframe sync
always @(negedge iclk19 or negedge rst_)
    begin
    if (!rst_)  frmsync_rt  <= 1'b0;
    else if(frmsync_rt) frmsync_rt <= 1'b0;
    else        frmsync_rt  <= frmsync;
    end

reg [2:0] cnt2;
always @(posedge iclk19 or negedge rst_)
    begin
    if (!rst_)              cnt2 <= 3'd0;
    else if (frmsync_rt)    cnt2 <= CNT2_RST;
    else                    cnt2 <= cnt2 + 1'b1;
    end

wire            oclk2d43;
assign          oclk2d43 = cnt2[2];


reg [1:0] cnt4;
always @(posedge iclk19 or negedge rst_)
    begin
    if (!rst_)              cnt4 <= 2'd0;
    else if (frmsync_rt)    cnt4 <= CNT4_RST;
    else                    cnt4 <= cnt4 + 1'b1;
    end

wire            oclk4d86;
assign          oclk4d86 = cnt4[1];

endmodule 
