////////////////////////////////////////////////////////////////////////////////
//
// Ho Chi Minh City University of Technology
//
// Filename     : auc_wmul_conv.v
// Description  : .
//
// Author       : Vuong Dinh Hung (1511422)
// Created On   : Wed May 01 17:13:41 2019
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module auc_wmul_conv
    (
     clk,
     rst,
     // Input
     conv_en,
     conv_auvld,
     conv_audat,
     // Output
     conv_start,
     conv_opcode,
     conv_done,
     // RAM control
     conv_radd,
     conv_wen,
     conv_wadd,
     conv_wdat
     );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

parameter           WIDTH   = 256;
parameter           ADDR    = 5;

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
localparam          TEMP8   = 28;

localparam          S_RP    = 29;
localparam          S_RPH   = 30;
localparam          BLNK    = 31;

// OPCODE

localparam          OP_FA   = 4'b0000;
localparam          OP_MUL  = 4'b0001;
localparam          OP_INV  = 4'b0010;

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input               clk;
input               rst;

input               conv_en;
input               conv_auvld;
input [WIDTH-1:0]   conv_audat;

output              conv_start;
output [3:0]        conv_opcode;
output              conv_done;

output [ADDR-1:0]   conv_radd;
output              conv_wen;
output [ADDR-1:0]   conv_wadd;
output [WIDTH-1:0]  conv_wdat;

////////////////////////////////////////////////////////////////////////////////
// Output declarations

reg                 conv_start;
reg [3:0]           conv_opcode;
reg                 conv_done;

reg [ADDR-1:0]      conv_radd;
reg                 conv_wen;
reg [ADDR-1:0]      conv_wadd;
reg [WIDTH-1:0]     conv_wdat;

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

reg [2:0]           conv_step;
wire [2:0]          conv_step_inc;
assign              conv_step_inc = conv_step + 1'b1;

reg                 conv_1more;
reg                 conv_en_sticky;

always @(posedge clk)
    begin
    if (rst)
        begin
        conv_start  <= INIT;
        conv_opcode <= INIT;
        conv_done   <= INIT;
        //================
        conv_radd   <= INIT;
        conv_wen    <= INIT;
        conv_wadd   <= INIT;
        conv_wdat   <= INIT;
        //================
        conv_step   <= INIT;
        conv_1more  <= INIT;
        //================
        conv_en_sticky  <= INIT;
        end
    else if (conv_en)
        begin
        conv_start  <= INIT;
        conv_opcode <= INIT;
        conv_done   <= INIT;
        //================
        conv_radd   <= INIT;
        conv_wen    <= INIT;
        conv_wadd   <= INIT;
        conv_wdat   <= INIT;
        //================
        conv_step   <= INIT;
        conv_1more  <= INIT;
        //================
        conv_en_sticky  <= 1'b1;
        end
    else if (conv_en_sticky)
        begin
        case(conv_step)
            3'd0:               // Z^2
                begin
                case(conv_1more)
                    1'b0: 
                        begin
                        conv_start  <= 1'b0;
                        conv_step   <= conv_step;
                        end
                    1'b1: 
                        begin
                        conv_start  <= 1'b1;
                        conv_step   <= conv_step_inc;
                        end
                endcase
                conv_radd   <= TEMP2;               // Z
                conv_1more  <= ~conv_1more;
                conv_opcode <= OP_MUL;
                conv_en_sticky  <= 1'b1;
                end
            3'd1:               // Z^-1
                begin
                if (conv_auvld)
                    begin
                    conv_start  <= 1'b1;
                    conv_opcode <= OP_INV;
                    conv_done   <= INIT;
                    //================
                    conv_radd   <= TEMP3;
                    conv_wen    <= 1'b1;
                    conv_wadd   <= TEMP3;           // Z^2 
                    conv_wdat   <= conv_audat;
                    //================
                    conv_step   <= conv_step_inc;
                    conv_1more  <= INIT;
                    //================
                    conv_en_sticky  <= 1'b1;   
                    end
                else
                    begin
                    conv_start  <= 1'b0;
                    conv_wen    <= 1'b0;
                    conv_done   <= 1'b0;
                    end
                end
            3'd2:               // x affine
                begin
                case(conv_1more)
                    1'b0:
                        begin
                        conv_start  <= 1'b0;
                        conv_step   <= conv_step;
                        conv_radd   <= conv_auvld? TEMP0: conv_radd;    // X
                        end
                    1'b1:
                        begin
                        conv_start  <= 1'b1;
                        conv_step   <= conv_step_inc;
                        conv_radd   <= TEMP3;                           // Z^-1
                        end
                endcase
                if (conv_auvld)
                    begin
                    conv_wen    <= 1'b1;
                    conv_wadd   <= TEMP3;           // Z^-1
                    conv_wdat   <= conv_audat;
                    //====================
                    conv_opcode <= OP_MUL;
                    conv_1more  <= ~conv_1more;
                    conv_done   <= 1'b0;
                    //================
                    conv_en_sticky  <= 1'b1;
                    end
                else
                    begin
                    conv_wen    <= 1'b0;
                    conv_done   <= 1'b0;
                    end
                end
            3'd3:               // Save X_KG
                begin
                if (conv_auvld)
                    begin
                    conv_wen    <= 1'b1;
                    conv_wadd   <= X_KG;
                    conv_wdat   <= conv_audat;
                    conv_done   <= 1'b1;
                    conv_step   <= conv_step_inc;
                    //================
                    conv_en_sticky  <= 1'b1;
                    end
                else
                    begin
                    conv_wen    <= 1'b0;
                    conv_start  <= 1'b0;
                    conv_done   <= 1'b0;
                    end
                end
            default:
                begin
                conv_start  <= INIT;
                conv_opcode <= INIT;
                conv_done   <= INIT;
                //================
                conv_radd   <= INIT;
                conv_wen    <= INIT;
                conv_wadd   <= INIT;
                conv_wdat   <= INIT;
                //================  
                conv_step   <= INIT;
                conv_1more  <= INIT;
                //================
                conv_en_sticky  <= 1'b0;
                end
        endcase
        end
    end
        
endmodule 
