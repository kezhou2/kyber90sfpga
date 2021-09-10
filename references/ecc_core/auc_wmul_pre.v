////////////////////////////////////////////////////////////////////////////////
//
// Ho Chi Minh City University of Technology
//
// Filename     : auc_wmul_pre.v
// Description  : .
//
// Author       : Vuong Dinh Hung (1511422)
// Created On   : Mon Apr 29 19:14:22 2019
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module auc_wmul_pre
    (
     clk,
     rst,
     // Input
     pre_en,
     pre_dbl_end,
     pre_add_end,
     // Output
     pre_dbl_en,
     pre_add_en,
     pre_paddx,
     pre_paddy,
     pre_paddz,
     //=========
     pre_dbl,
     pre_ram_1st,               // RAM priority             
     pre_done,   
     // RAM control
     pre_radd,
     pre_rdat,
     pre_wen,
     pre_wadd,
     pre_wdat
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

// Local state

localparam          READ_XG = 4'd0;
localparam          READ_YG = 4'd1;
localparam          READ_ZG = 4'd2;
localparam          WRITE_XG    = 4'd3;
localparam          WRITE_YG    = 4'd4;
localparam          WRITE_ZG    = 4'd5;
localparam          DOUBLE  = 4'd6;
localparam          CAL_3G  = 4'd7;
localparam          CAL_5G  = 4'd8;
localparam          CAL_7G  = 4'd9;
localparam          DONE    = 4'd10;

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input               clk;
input               rst;

input               pre_en;
input               pre_dbl_end;
input               pre_add_end;

output              pre_dbl_en;
output              pre_add_en;
output [ADDR-1:0]   pre_paddx;
output [ADDR-1:0]   pre_paddy;
output [ADDR-1:0]   pre_paddz;

output              pre_dbl;
output              pre_ram_1st;
output              pre_done;

output [ADDR-1:0]   pre_radd;
input [WIDTH-1:0]   pre_rdat;
output              pre_wen;
output [ADDR-1:0]   pre_wadd;
output [WIDTH-1:0]  pre_wdat;

////////////////////////////////////////////////////////////////////////////////
// Output declarations

reg                 pre_dbl_en;
reg                 pre_add_en;
reg [ADDR-1:0]      pre_paddx;
reg [ADDR-1:0]      pre_paddy;
reg [ADDR-1:0]      pre_paddz;

reg                 pre_dbl;
reg                 pre_ram_1st;
reg                 pre_done;

reg [ADDR-1:0]      pre_radd;
reg                 pre_wen;
reg [ADDR-1:0]      pre_wadd;

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

reg [3:0]           pre_step;
wire [3:0]          pre_step_inc;
assign              pre_step_inc = pre_step + 1'b1;

reg                 pre_en_sticky;

always @(posedge clk)
    begin
    if (rst)
        begin
        pre_dbl_en  <= INIT;
        pre_add_en  <= INIT;
        pre_paddx   <= INIT;
        pre_paddy   <= INIT;
        pre_paddz   <= INIT;
        pre_done    <= INIT;
        //==================
        pre_dbl     <= INIT;
        pre_ram_1st <= INIT;
        pre_step    <= INIT;
        //==================
        pre_radd    <= INIT;
        pre_wen     <= INIT;
        pre_wadd    <= INIT;
        //==================
        pre_en_sticky   <= INIT;
        end
    else if (pre_en)
        begin
        pre_dbl_en  <= INIT;
        pre_add_en  <= INIT;
        pre_paddx   <= INIT;
        pre_paddy   <= INIT;
        pre_paddz   <= INIT;
        pre_done    <= INIT;
        //==================
        pre_dbl     <= INIT;
        pre_ram_1st <= 1'b1;
        pre_step    <= INIT;
        //==================
        pre_radd    <= INIT;
        pre_wen     <= INIT;
        pre_wadd    <= INIT;
        //==================
        pre_en_sticky   <= 1'b1;
        end
    else if (pre_en_sticky)
        begin
        case(pre_step)
            READ_XG:
                begin
                pre_dbl_en  <= INIT;
                pre_add_en  <= INIT;
                pre_paddx   <= INIT;
                pre_paddy   <= INIT;
                pre_paddz   <= INIT;
                pre_done    <= INIT;
                //==================
                pre_dbl     <= INIT;
                pre_ram_1st <= 1'b1;
                pre_step    <= pre_step_inc;
                //==================
                pre_radd    <= X_G;
                pre_wadd    <= TEMP0;
                pre_wen     <= 1'b0;
                //==================
                pre_en_sticky   <= 1'b1;
                end
            READ_YG:
                begin
                pre_dbl_en  <= INIT;
                pre_add_en  <= INIT;
                pre_paddx   <= INIT;
                pre_paddy   <= INIT;
                pre_paddz   <= INIT;
                pre_done    <= INIT;
                //==================
                pre_dbl     <= INIT;
                pre_ram_1st <= 1'b1;
                pre_step    <= pre_step_inc;
                //==================
                pre_radd    <= Y_G;
                pre_wadd    <= TEMP0;
                pre_wen     <= 1'b0;
                //==================
                pre_en_sticky   <= 1'b1;
                end
            READ_ZG:
                begin
                pre_dbl_en  <= INIT;
                pre_add_en  <= INIT;
                pre_paddx   <= INIT;
                pre_paddy   <= INIT;
                pre_paddz   <= INIT;
                pre_done    <= INIT;
                //==================
                pre_dbl     <= INIT;
                pre_ram_1st <= 1'b1;
                pre_step    <= pre_step_inc;
                //==================
                pre_radd    <= ONERAM;
                pre_wadd    <= TEMP0;
                pre_wen     <= 1'b0;
                //==================
                pre_en_sticky   <= 1'b1;
                end
            WRITE_XG:
                begin
                pre_dbl_en  <= INIT;
                pre_add_en  <= INIT;
                pre_paddx   <= INIT;
                pre_paddy   <= INIT;
                pre_paddz   <= INIT;
                pre_done    <= INIT;
                //==================
                pre_dbl     <= INIT;
                pre_ram_1st <= 1'b1;
                pre_step    <= pre_step_inc;
                //==================
                pre_radd    <= pre_radd;
                pre_wadd    <= TEMP0;
                pre_wen     <= 1'b1;
                //==================
                pre_en_sticky   <= 1'b1;
                end
            WRITE_YG:
                begin
                pre_dbl_en  <= INIT;
                pre_add_en  <= INIT;
                pre_paddx   <= INIT;
                pre_paddy   <= INIT;
                pre_paddz   <= INIT;
                pre_done    <= INIT;
                pre_dbl     <= INIT;
                //==================
                pre_dbl     <= INIT;
                pre_ram_1st <= 1'b1;
                pre_step    <= pre_step_inc;
                //==================
                pre_radd    <= pre_radd;
                pre_wadd    <= TEMP1;
                pre_wen     <= 1'b1;
                //==================
                pre_en_sticky   <= 1'b1;
                end
            WRITE_ZG:
                begin
                pre_dbl_en  <= INIT;
                pre_add_en  <= INIT;
                pre_paddx   <= INIT;
                pre_paddy   <= INIT;
                pre_paddz   <= INIT;
                pre_done    <= INIT;
                //==================
                pre_dbl     <= INIT;
                pre_ram_1st <= 1'b1;
                pre_step    <= pre_step_inc;
                //==================
                pre_radd    <= pre_radd;
                pre_wadd    <= TEMP2;
                pre_wen     <= 1'b1;
                //==================
                pre_en_sticky   <= 1'b1;
                end
            DOUBLE:
                begin
                pre_dbl_en  <= 1'b1;
                pre_add_en  <= INIT;
                pre_paddx   <= INIT;
                pre_paddy   <= INIT;
                pre_paddz   <= INIT;
                pre_done    <= INIT;
                //==================
                pre_dbl     <= 1'b1;
                pre_ram_1st <= 1'b0;
                pre_step    <= pre_step_inc;
                //==================
                pre_radd    <= pre_radd;
                pre_wadd    <= pre_wadd;
                pre_wen     <= 1'b0;
                //==================
                pre_en_sticky   <= 1'b1;
                end
            CAL_3G:
                if (pre_dbl_end)
                    begin
                    pre_dbl_en  <= INIT;
                    pre_add_en  <= 1'b1;
                    pre_paddx   <= X_G;
                    pre_paddy   <= Y_G;
                    pre_paddz   <= ONERAM;
                    pre_done    <= INIT;
                    //==================
                    pre_dbl     <= INIT;
                    pre_ram_1st <= 1'b0;
                    pre_step    <= pre_step_inc;
                    //==================
                    pre_radd    <= pre_radd;
                    pre_wadd    <= pre_wadd;
                    pre_wen     <= 1'b0;
                    //==================
                    pre_en_sticky   <= 1'b1;
                    end
                else
                    pre_dbl_en  <= INIT;
            CAL_5G:
                if (pre_add_end)
                    begin
                    pre_dbl_en  <= INIT;
                    pre_add_en  <= 1'b1;
                    pre_paddx   <= X_3G;
                    pre_paddy   <= Y_3G;
                    pre_paddz   <= Z_3G;
                    pre_done    <= INIT;
                    //==================
                    pre_dbl     <= INIT;
                    pre_ram_1st <= 1'b0;
                    pre_step    <= pre_step_inc;
                    //==================
                    pre_radd    <= pre_radd;
                    pre_wadd    <= pre_wadd;
                    pre_wen     <= 1'b0;
                    //==================
                    pre_en_sticky   <= 1'b1;
                    end 
                else
                    pre_add_en  <= INIT;
            CAL_7G:
                if (pre_add_end)
                    begin
                    pre_dbl_en  <= INIT;
                    pre_add_en  <= 1'b1;
                    pre_paddx   <= X_5G;
                    pre_paddy   <= Y_5G;
                    pre_paddz   <= Z_5G;
                    pre_done    <= INIT;
                    //==================
                    pre_dbl     <= INIT;
                    pre_ram_1st <= 1'b0;
                    pre_step    <= pre_step_inc;
                    //==================
                    pre_radd    <= pre_radd;
                    pre_wadd    <= pre_wadd;
                    pre_wen     <= 1'b0;
                    //==================
                    pre_en_sticky   <= 1'b1;
                    end
                else
                    pre_add_en  <= INIT;
            DONE:
                if (pre_add_end)
                    begin
                    pre_add_en  <= 1'b0;
                    pre_done    <= 1'b1;
                    //==================
                    pre_step    <= pre_step_inc;
                    pre_en_sticky   <= 1'b1;
                    pre_ram_1st <= 1'b0;
                    end
                else
                    begin
                    pre_add_en  <= INIT;
                    pre_done    <= INIT;
                    //==================
                    pre_en_sticky   <= 1'b1;
                    end
            default:
                begin
                pre_dbl_en  <= INIT;
                pre_add_en  <= INIT;
                pre_paddx   <= INIT;
                pre_paddy   <= INIT;
                pre_paddz   <= INIT;
                pre_done    <= INIT;
                //==================
                pre_dbl     <= INIT;
                pre_ram_1st <= INIT;
                pre_step    <= INIT;
                //==================
                pre_radd    <= INIT;
                pre_wen     <= INIT;
                pre_wadd    <= INIT;
                //==================
                pre_en_sticky   <= 1'b0;
                end
        endcase
        end
    end

assign              pre_wdat = pre_rdat;

endmodule 
