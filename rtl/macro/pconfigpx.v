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
//  Wed Apr 18 13:54:35 2007, ctmtu, Added parity check
//////////////////////////////////////////////////////////////////////////////////
module pconfigpx
    (
     clk,
     rst_,
     upen,
     upws,
     updi,
     out,
     par_dis,
     par_err,
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

input               par_dis; // Disable parity calculation for testing
output              par_err;

//----------------------------------------------
wire    [WIDTH-1:0] out;
reg     [WIDTH-1:0] xxxfpcfg;
assign              out = xxxfpcfg;

assign updo = upen ? xxxfpcfg : {WIDTH{1'b0}};

always @(posedge clk or negedge rst_)
    begin
    if(!rst_) xxxfpcfg <= RESET_VALUE;
    else if(upen & upws) xxxfpcfg <= updi;
    end

reg                 xxxpar;
always @ (posedge clk or negedge rst_)
    begin
    if (!rst_) xxxpar <= ^RESET_VALUE;
    else if(upen & upws & (!par_dis)) xxxpar <= ^updi;
    end
wire par_err;
assign par_err = xxxpar ^ (^xxxfpcfg);

endmodule
