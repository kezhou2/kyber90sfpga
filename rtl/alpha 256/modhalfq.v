module modhalfq
(
    clk,
    rst,
    a,
    b
);

//////////

/////////

parameter WID=12; //q = 3329 
parameter HALFQ = 1665;
////////////////////////
input clk,rst;
 
input [WID-1:0] a;
output [WID-1:0] b;

/////////////////////////////////

wire [WID-1:0] a1;

fflopx #(WID) ifflopx1 (clk,rst,a,a1);

wire asel2;

fflopx #(1) ifflopx2 (clk,rst,a1[0],asel2);

//even logic//

wire [WID-1:0] beven1;

assign beven1 = {1'b0,a1[WID-1:1]};

////odd logic////
wire [WID-1:0] bodd1;

//poly_mod_add #(WID) ipoly_mod_add1 (clk,rst,beven1,12'd1665,bodd1);

assign bodd1 = beven1 + 12'd1665;

///mux logic///
wire [WID-1:0] bodd2,beven2;

fflopx #(WID) ifflopx3 (clk,rst,bodd1,bodd2);
fflopx #(WID) ifflopx4 (clk,rst,beven1,beven2);

mux_xx1 #(WID) imux_xx1 (beven2,bodd2,asel2,b);

/////////////////////////////////

endmodule