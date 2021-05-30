////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : intfmux8.v
// Description  : mux 8,7,6,5,4,3,2,1 for FPGA intergration
//
// Author       : tdhcuong@HW-TDHCUONG
// Created On   : Thu Oct 21 16:32:20 2004
// Change by    : ngtnhan@HW-NGTNHAN
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////
// HELP
//
// --------------------MUX 4-1--------------------
// - should select synclk: 155Mhz
//
// - MAXTS :
//          6 : line clock      : synclk/6 = 25Mhz
//              setup time      : 6 synclk
//              length of cable : using jt is shorter than 1m
//                                using jb is shorter than 0.3m
//          
//          7 : line clock      : synclk/7 = 22Mhz
//              setup time      : 3 synclk
//              length of cable : using jt is shorter than 1m
//                                using jb is shorter than 0.3m
//
// - BITTS = 3 (time slot counter 3 bit)
// - Using front plane : should MAXTS = 6
// - Using back plane  : should MAXTS = 7
//
// --------------------MUX 3-1--------------------
// - should select synclk: 155Mhz
//
// - MAXTS :
//          9 : line clock      : synclk/9 = 17Mhz
//              setup time      : 4 synclk
//              length of cable : using jt is shorter than 1m
//                                using jb is shorter than 0.4m
//          
//          10 : line clock      : synclk/10 = 15Mhz
//               setup time      : 2 synclk
//               length of cable : using jt is shorter than 1m
//                                 using jb is shorter than 0.4m
//          more...
//
// - BITTS = 4 (time slot counter 4 bit)
// - should MAXTS = 9
//
// --------------------MUX 2-1--------------------
// - should select synclk: 155Mhz
// - MAXTS :
//          13 : line clock      : synclk/13 = 12Mhz
//               setup time      : 6 synclk
//               length of cable : using jt is shorter than 1m
//                                 using jb is shorter than 0.6m
//          
//          14 : line clock      : synclk/14 = 11Mhz
//               setup time      : 3 synclk
//               length of cable : using jt is shorter than 1m
//                                 using jb is shorter than 0.8m
//          more...
//
// - BITTS = 4 (time slot counter 4 bit)
// - should MAXTS = 13
//
//--------------------MUX 1-1--------------------
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// DEMUX
//         _________________________                            ________
// rxclk _|                         |__________________________|
//        __  _________  _________  _________  ________________________
// idat   __><__bus0___><__bus1___><__bus2___><______bus3______________>
//            _________
// isyn   ___|         |________________________________________________
//          _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _  
// synclk _| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |
//              ___
// posdet _____|   |_____________________________________________________
//                  ___________________________________________________
// bus0            <_________bus0______________________________________>
//                            ___________________________________________________
// bus1                      <_________bus1______________________________________>
//                                       ___________________________________________________
// bus2                                 <_________bus2______________________________________>
//                                       ______________________________
// dashf                                <_____{bus0,bus1,bus2}_________>
//                                             ________________________
// idat                                       <______bus3______________>
//                                             ________________________
// odat                                       <__{bus0,bus1,bus2,bus3}_>
//       
// timing                                      _____setup______|_hold__
//
////////////////////////////////////////////////////////////////////////////////

module intfdemux6
    (
     rst_,
     iclk38, 
     
     idat,      // data receive ~ iclk38
     isyn,      // sync strobe  ~ iclk38

     odat       // data out
     );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

parameter LINEBIT = 12;      // Bit of data befor DEMUX
parameter DEMUX   = 6;      // Demux 4, 3, or 2
parameter BITTS   = 3;      // Bit of time slot counter
parameter MAXTS   = 4;      // Number of time slot synclk to hold transmit data
parameter DATABIT = DEMUX*LINEBIT;

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input                rst_;
input                iclk38;

input [LINEBIT-1:0]  idat;
input                isyn;

output [DATABIT-1:0] odat;
////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation
/*
//detect refclk
reg [2:0]   shfdet;
always @(posedge synclk or negedge rst_)
    begin
    if(!rst_) shfdet <= 3'd0;
    else      shfdet <= {shfdet[1:0],irefclk};
    end

wire    posdet;
assign  posdet = (shfdet == 3'b011);
*/
//  
reg [2:0] cntph;
wire      endcntph;
assign    endcntph = (cntph == (DEMUX-1));

always @(posedge iclk38 or negedge rst_)
    begin
    if(!rst_) cntph <= 3'd0;
    else if(isyn)       cntph <= 3'd1;
    //else if(endcntph)   cntph <= DEMUX-1;
    else                cntph <= cntph + 1'b1;
    end
       
reg [DATABIT-1:0] dashf;
wire [DATABIT+LINEBIT-1:0] dacap;
assign                     dacap = {dashf,idat};

always @(posedge iclk38 or negedge rst_)
    begin
    if(!rst_)   dashf <= {DATABIT{1'b0}};
    else        dashf <= dacap[DATABIT-1:0];
    end

//assign  odat = dacap[DATABIT-1:0];

reg [DATABIT-1:0] odat;
wire              latch_dat;
assign            latch_dat = (cntph == (DEMUX-1));
always @(posedge iclk38 or negedge rst_)
    begin
    if(!rst_) odat <= {DATABIT{1'b0}};
    else if(latch_dat) odat <= dacap[DATABIT-1:0];
    end

endmodule 
