////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : cswap.v
// Description  : swap func for mont scalar mult
//
// Author       : hungnt@HW-NTHUNG
// Created On   : Thu May 02 13:26:59 2019
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module cswap
    (
     clk,
     rst,

     swap,
     a,
     b,
     en,

     aswap,
     bswap,
     vld
     );
////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

parameter WID = 256;//X25519
parameter DUM = 256'd57896044618658097711785492504343953926634992332820282019728792003956564819968;//2^255
localparam INIT = 0;

////////////////////////////////////////////////////////////////////////////////
// Port declarations
input     clk;
input     rst;

input     swap;
input [WID-1:0] a;
input [WID-1:0] b;
input           en;

output [WID-1:0] aswap;
output [WID-1:0] bswap;
output           vld;

////////////////////////////////////////////////////////////////////////////////
// Output declarations
////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation
reg [WID-1:0]    arg,brg;
reg              swaprg;
reg              vldrg;

always@(posedge clk)
    begin
    if(rst)
        begin
        arg <= INIT;
        brg <= INIT;
        swaprg <= INIT;
        vldrg <= 1'b0;
        end
    else if(en)
        begin
        arg <= a;
        brg <= b;
        swaprg <= swap;
        vldrg <= 1'b1;
        end
    else
        begin
        arg <= arg;
        brg <= brg;
        swaprg <= swaprg;
        vldrg <= 1'b0;
        end
    end
    
fflopx #(1) ifflopx1(clk,rst,vldrg,vld);
assign aswap = swaprg? brg : arg;
assign bswap = swaprg? arg : brg;


/*
wire [WID-1:0] dummy;
wire [WID-1:0] dumsub;
wire [WID-1:0] dumxor;

full_sub #(256) ifull_sub (DUM,{255'd0,swaprg},dumsub);

assign         dumxor = arg ^ brg;

assign         dummy = dumsub & dumxor;

wire [WID-1:0] dummy1;
wire [WID-1:0] arg1;
wire [WID-1:0] brg1;

fflopx #(256) ifflopxdm(clk,rst,dummy,dummy1);
fflopx #(256) ifflopxas1(clk,rst,arg,arg1);
fflopx #(256) ifflopxbs1(clk,rst,brg,brg1); //improve timing

wire [WID-1:0] aswap0;
wire [WID-1:0] bswap0;
wire [WID-1:0] aswap1;
wire [WID-1:0] bswap1;

assign         aswap0 = arg1 ^ dummy1;
assign         bswap0 = brg1 ^ dummy1;

fflopx #(256) ifflopxas2(clk,rst,aswap0,aswap1);
fflopx #(256) ifflopxbs2(clk,rst,bswap0,bswap1);

//output
assign         aswap = aswap1;
assign         bswap = bswap1;

reg [1:0]      vldcnt;
wire           vldcnt00;
assign         vldcnt00 = !(|vldcnt);
wire           vldcnten;
assign         vldcnten = vldcnt00 & en;

always@(posedge clk)
    begin
    if(rst)
        begin   
        vldcnt <= INIT;
        //$display ("chay vo reset, luc nay vldcnt = %d tai %0t", vldcnt,$time);
        end
    else
        begin
        if(vldcnten)
            begin
            vldcnt <= vldcnt + 2'b01;
            //$display ("chay vo +,luc nay vldcnt = %d tai %0t",vldcnt,$time);
            end
        else if(|vldcnt)//reduction OR means != 2'b00
            begin
            vldcnt <= vldcnt + 2'b01;
            //$display ("chay vo +2,luc nay vldcnt = %d tai %0",vldcnt,$time);
            end
        else
            begin
            vldcnt <= vldcnt;
            //$display ("chay vo binh thuong vldcnt = %d tai %0t",vldcnt,$time);
            end
        end
    end

assign vld = &vldcnt;
*/
endmodule 
