//////////////////////////////////////////////////////////////////////////////////
//
//  Arrive Technologies
//
// Filename        : pconfigx.v
// Description     : Variable width processor config register
//
// Author          : lapnq@atvn.com.vn
// Created On      : Tue Jul 29 18:02:11 2003
// History (Date, Changed By)
//
//////////////////////////////////////////////////////////////////////////////////
module pconfigx
    (
     clk,
     rst_,
     upen,
     upws,
     updi,
     out,
     updo
     );

parameter WIDTH = 8;
parameter RESET_VALUE = {WIDTH{1'b0}};

input   clk,
        rst_,
        upen,               // Microprocessor enable
        upws;               // Microprocessor write strobe
        
input   [WIDTH-1:0] updi;   // Microprocessor data in

output  [WIDTH-1:0] out;

output  [WIDTH-1:0] updo;   // Microprocessor data out

reg     [WIDTH-1:0] out;

assign updo = upen ? out : {WIDTH{1'b0}};

always @(posedge clk or negedge rst_)
    begin
    if(!rst_) out <= RESET_VALUE;
    else if(upen & upws) out <= updi;
    end

endmodule
