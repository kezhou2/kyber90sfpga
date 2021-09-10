////////////////////////////////////////////////////////////////////////////////
//
// Ho Chi Minh Cioty University of Technology
//
// Filename     : complement_2.v
// Description  : .
//
// Author       : Vuong Dinh Hung (1511422)
// Created On   : Sun Apr 28 21:23:44 2019
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module complement_2
    (
     clk,
     rst,
     din,
     en,
     dout
     );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

parameter           WIDTH   = 256;

localparam          INIT    = 0;

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input               clk;
input               rst;

input [WIDTH-1:0]   din;
input               en;

output [WIDTH-1:0]  dout;

////////////////////////////////////////////////////////////////////////////////
// Output declarations

reg [WIDTH-1:0]     dout;

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

wire [WIDTH-1:0]    comp_2;

full_sub
    #(
      .WIDTH(WIDTH)
      ) ifull_sub
     (
     .a({WIDTH{1'b0}}),
     .b(din),
     .sub(comp_2),
     .c()
      );

always @(posedge clk)
    begin
    if (rst)        dout    <= INIT;
    else if (en)    dout    <= comp_2;
    else            dout    <= din;
    end

endmodule 
