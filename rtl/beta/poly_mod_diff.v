// Copyright 2007 Altera Corporation. All rights reserved.  
// Altera products are protected under numerous U.S. and foreign patents, 
// maskwork rights, copyrights and other intellectual property laws.  
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design 
// License Agreement (either as signed by you or found at www.altera.com).  By
// using this reference design file, you indicate your acceptance of such terms
// and conditions between you and Altera Corporation.  In the event that you do
// not agree with such terms and conditions, you may not use the reference 
// design file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an "as-is" basis and as an 
// accommodation and therefore all warranties, representations or guarantees of 
// any kind (whether express, implied or statutory) including, without 
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or 
// require that this reference design file be used in combination with any 
// other product not provided by Altera.
/////////////////////////////////////////////////////////////////////////////

//ONLY USE FOR Q = 3329
///////////////////////////
module poly_mod_diff (clk,rst,a,b,o);
///////////////////////////////
parameter WIDTH = 12;
parameter METHOD = 1'b0;//NOTHING
/////////////////////////////
input [WIDTH-1:0] a,b;
input clk,rst;
output [WIDTH-1:0] o;
////////////////////////////////////
wire [WIDTH+1:0] diff_in0,diff_in01;
wire [WIDTH+1:0] diff_in1,diff_in11;
wire [WIDTH+1:0] diff_in2,diff_in21;
wire [WIDTH+1:0] diff_in3;

assign diff_in0 = a - b + 14'd6658;//3329

fflopx #(WIDTH+2) ifflopx1 (clk,rst,diff_in0,diff_in01);

assign diff_in1 = (diff_in01>=14'd3329)? diff_in01 - 14'd3329 : diff_in01;

fflopx #(WIDTH+2) ifflopx2 (clk,rst,diff_in1,diff_in11);

assign diff_in2 = (diff_in11>=14'd3329)? diff_in11 - 14'd3329 : diff_in11;

fflopx #(WIDTH+2) ifflopx3 (clk,rst,diff_in2,diff_in21);

assign diff_in3 = (diff_in21>=14'd3329)? diff_in21 - 14'd3329 : diff_in21;

assign o = diff_in3[11:0];



endmodule

/////////////////////////////////////
//tested, good, tb doesn't work, tested with google