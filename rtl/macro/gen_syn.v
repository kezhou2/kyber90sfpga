////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : gen_syn.v
// Description  : .
//
// Author       : ngtnhan@HW-NGTNHAN
// Created On   : Tue Oct 24 15:11:24 2006
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module gen_syn
    (
     rst_,

     iclk155,
     
     iclk4d86,
     iclk38,

     osyn

     );
////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

////////////////////////////////////////////////////////////////////////////////
// Port declarations
input rst_;
input iclk155;

input       iclk4d86;
input       iclk38;
output      osyn;

////////////////////////////////////////////////////////////////////////////////
// Output declarations
reg         osyn;

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation
reg [2:0]   shfdet4d86;

wire        pos4d86;
assign      pos4d86 = (shfdet4d86 == 3'b011);
//
always @(posedge iclk155 or negedge rst_)
    if(!rst_)   shfdet4d86 <= 3'd0;
    else        shfdet4d86 <= {shfdet4d86[1:0],iclk4d86};
       
reg         synref;
always @(posedge iclk155 or negedge rst_)
    if(!rst_)    synref <= 1'b0;
    else if(pos4d86 & ~synref)  synref <= 1'b1;
    else if(pos4d86)            synref <= 1'b0;
////////////////////////////////////////
wire        insyn;
fflopxe #(1)    linsyn(iclk4d86,rst_,synref,1'b1,insyn);
//
reg [2:0]   cntph;
always @(posedge iclk38 or negedge rst_)
    if(!rst_)   cntph <= 3'd0;
    else if(insyn)                      cntph <= cntph + 1'b1;//0 - 7
    else if(synref & (cntph == 3'd0))   cntph <= 3'd0;
//    else if(synref)                     cntph <= cntph + 1'b1;//0 - 7
//        
always @(posedge iclk38 or negedge rst_)
    if(!rst_)   osyn <= 1'b0;
    else if(&cntph)     osyn <= 1'b1;
    else                osyn <= 1'b0;          
////////////////////////////////////////////////////////////////////////////////
endmodule 
