////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : montpro.v
// Description  : pre 256 bit parameterized montgomery multiply in bin
//
// Author       : hungnt@HW-NTHUNG
// Created On   : Thu Mar 07 10:26:10 2019
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module montpro
    (
     clk,
     rst,
     
     a,//full bit of factor a
     b,//full bit of factor b
     m,//modulo
     
     //shfta, //shift reg ctrl a
     ldnew,   //load reg a, reset r
     //shftr, //shift reg ctrl r
     
     r//output
     );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

parameter WID = 256;
parameter ZERO = 256'b0;

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input     clk;
input     rst;

input [WID-1:0] a;
input [WID-1:0] b;
input [WID-1:0] m;

//input           shfta;
input           ldnew;
//input           shftr;

output [WID:0] r;

////////////////////////////////////////////////////////////////////////////////
// Output declarations

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

//register a

reg [WID-1:0]    asrg;// a shift register

always@(posedge clk)
    begin
    if(rst)
        begin
        asrg <= ZERO;
        end
    else if(ldnew)
        begin
        asrg <= a;
        end
    //else if(shfta)
    //    begin
    //    asrg <= {1'b0,asrg[WID-1:1]};
    //    end
    else
        begin
        asrg <= {1'b0,asrg[WID-1:1]};
        end
    end

//first mux b zero
wire [WID-1:0] mxao; //mux a out

mux_xx1 #(WID) imxa (ZERO,b,asrg[0],mxao);

//first adder
wire [WID:0] adari; //adder a r input from reg r
wire [WID+1:0]   adars; //adder a result

cla #(WID+1) iclaa (adari,{1'b0,mxao},adars[WID:0],adars[WID+1]);

//second mux m zero
wire [WID-1:0] mxmo; //mux m out

mux_xx1 #(WID) imxm (ZERO,m,adars[0],mxmo);

//second adder
wire [WID+2:0]   admrs; //adder m result

cla #(WID+2) iclam (adars,{2'b0,mxmo},admrs[WID+1:0],admrs[WID+2]);

//register r
reg [WID+2:0]    rsrg; //r shift register

always@(posedge clk)
    begin
    if(rst)
        begin
        rsrg <= {2'b0,ZERO};
        end
    else if(ldnew)
        begin
        rsrg <= {2'b0,ZERO};
        end
    //else if(shftr)
      //  begin
      //  rsrg <= {1'b0,rsrg[WID:1]};
      //  end
    else
        begin
        rsrg <= {1'b0,admrs[WID+2:1]};
        end
    end

assign r = rsrg[WID:0];
assign adari = rsrg[WID:0];
  
endmodule 
