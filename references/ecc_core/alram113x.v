////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : alram113x.v
// Description  : ram m10k altera 2 clock read;
//
// Author       : PC@DESKTOP-9FI2JF9
// Created On   : Sat Apr 20 18:19:40 2019
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module alram113x
    (
     clkw,//clock write
     clkr,//clock read
     rst,
     
     rdo,//data from ram
     ra,//read address
     
     wdi,//data to ram
     wa,//write address
     we //write enable
     );
////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

parameter WID = 256;
parameter AWID = 5; //address width
parameter DEP = 1<<AWID;

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input clkw;
input clkr;
input rst;

output [WID-1:0] rdo;
input [AWID-1:0] ra;

input [WID-1:0]  wdi;
input [AWID-1:0] wa;
input            we;

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

reg [WID-1:0]   rdo;
wire [WID-1:0]    irdo;

always@(posedge clkr)
    begin
    rdo <= irdo;
    end

alram112x
    #(WID,AWID)
ialram112x
    (
     .clkw(clkw),//clock write
     .clkr(clkr),//clock read
     .rst(rst),
     
     .rdo(irdo),//data from ram
     .ra(ra),//read address
     
     .wdi(wdi),//data to ram
     .wa(wa),//write address
     .we(we) //write enable
     );

endmodule