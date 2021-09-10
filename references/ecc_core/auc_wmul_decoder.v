////////////////////////////////////////////////////////////////////////////////
//
// Ho Chi Minh City University of Technology
//
// Filename     : auc_wmul_decoder.v
// Description  : .
//
// Author       : Vuong Dinh Hung (1511422)
// Created On   : Sun Apr 28 20:47:10 2019
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module auc_wmul_decoder
    (
     clk,
     rst,
     // Input
     adec_naf_vlue,             // not include sign
     // Output
     adec_paddx,
     adec_paddy,
     adec_paddz,
     adec_nplus
     );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

parameter           ADDR    = 5;
parameter           WINDOW  = 4;

localparam          SWINDOW = WINDOW -2;
localparam          SH_WID  = (1<<SWINDOW) +1;

localparam          INIT    = 0;

localparam          X_G     = 0;
localparam          Y_G     = 1;
localparam          X_3G    = 2;
localparam          Y_3G    = 3;
localparam          Z_3G    = 4;
localparam          X_5G    = 5;
localparam          Y_5G    = 6;
localparam          Z_5G    = 7;
localparam          X_7G    = 8;
localparam          Y_7G    = 9;
localparam          Z_7G    = 10;

localparam          K_NUM   = 11;
localparam          K_INV   = 12;
localparam          R_NUM   = 13;
localparam          S_NUM   = 14;
localparam          X_KG    = 15;
localparam          HASH    = 16;
localparam          PKEY    = 17;
localparam          ZRRAM   = 18;   // NEED FIX
localparam          ONERAM  = 19;   // NEED FIX

localparam          TEMP0   = 20;
localparam          TEMP1   = 21;
localparam          TEMP2   = 22;
localparam          TEMP3   = 23;
localparam          TEMP4   = 24;
localparam          TEMP5   = 25;
localparam          TEMP6   = 26;   
localparam          TEMP7   = 27;

localparam          BLNK    = 31;

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input               clk;
input               rst;

input [SH_WID-2:0]  adec_naf_vlue;

output [ADDR-1:0]   adec_paddx;
output [ADDR-1:0]   adec_paddy;
output [ADDR-1:0]   adec_paddz;
output              adec_nplus;

////////////////////////////////////////////////////////////////////////////////
// Output declarations

reg [ADDR-1:0]      adec_paddx;
reg [ADDR-1:0]      adec_paddy;
reg [ADDR-1:0]      adec_paddz;
reg                 adec_nplus;

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

always @(posedge clk)
    begin
    if (rst)
        begin
        adec_paddx  <= INIT;
        adec_paddy  <= INIT;
        adec_paddz  <= INIT;
        adec_nplus  <= INIT;
        end
    else
        begin
        case(adec_naf_vlue)
        4'b0001:            // 7G
            begin
            adec_paddx  <= X_7G;
            adec_paddy  <= Y_7G;
            adec_paddz  <= Z_7G;
            adec_nplus  <= 1'b0;
            end
        4'b0010:            // 5G
            begin
            adec_paddx  <= X_5G;
            adec_paddy  <= Y_5G;
            adec_paddz  <= Z_5G;
            adec_nplus  <= 1'b0;
            end
        4'b0100:            // 3G
            begin
            adec_paddx  <= X_3G;
            adec_paddy  <= Y_3G;
            adec_paddz  <= Z_3G;
            adec_nplus  <= 1'b0;
            end
        4'b1000:            // G
            begin
            adec_paddx  <= X_G;
            adec_paddy  <= Y_G;
            adec_paddz  <= ONERAM;
            adec_nplus  <= 1'b0;
            end
        default:
            begin
            adec_paddx  <= INIT;
            adec_paddy  <= INIT;
            adec_paddz  <= INIT;
            adec_nplus  <= 1'b1;
            end
        endcase
        end
    end

endmodule 
