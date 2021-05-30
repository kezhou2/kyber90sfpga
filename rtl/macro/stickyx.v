//////////////////////////////////////////////////////////////////////////////////
//
//  Arrive Technologies
//
// Filename        : stickyx.v
// Description     : sticky bits, write "1" to clear
//
// Author          : lapnq@atvn.com.vn
// Created On      : Tue Jul 29 17:56:53 2003
// History (Date, Changed By)
//  Added upactive, Wed Feb 18 15:55:48 2004, by lqcuong
//
//////////////////////////////////////////////////////////////////////////////////

module stickyx
    (
     clk,
     rst_,
     upactive,
     alarm,
     upen,
     upws,
     updi,
     updo,
     lalarm
     );

parameter           WIDTH = 8;
input               clk;
input               rst_;
input               upactive;
input               upen;           // processor enable
input               upws;           // processor write strobe
input   [WIDTH-1:0] alarm;          // alarms in
input   [WIDTH-1:0] updi;           // processor data in

output  [WIDTH-1:0] updo;           // processor data out
output  [WIDTH-1:0] lalarm;         // latched alarms out

wire                we;
assign we = upen & upws;

reg     [WIDTH-1:0] lalarm;

assign updo = upen ? lalarm : {WIDTH{1'b0}};

always @(posedge clk or negedge rst_)
    begin
    if (!rst_) 
        lalarm <= {WIDTH{1'b0}};
    else if (~upactive)
        begin
        if(we) lalarm <= updi;
        end
    else if (we)
        lalarm <= alarm | (lalarm & ~updi);
    else 
        lalarm <= alarm | lalarm;
    end

endmodule
