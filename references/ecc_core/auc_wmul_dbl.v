////////////////////////////////////////////////////////////////////////////////
//
// Ho Chi Minh City University of Technology
//
// Filename     : auc_wmul_dbl.v
// Description  : .
//
// Author       : Vuong Dinh Hung (1511422)
// Created On   : Fri Apr 26 15:21:12 2019
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module auc_wmul_dbl
    (
     clk,
     rst,
     // Input
     dbl_audat,
     dbl_auvld,
     dbl_en,
     // Output
     dbl_start,
     dbl_opcode,
     dbl_const,
     dbl_carry,
     dbl_end,
     // RAM control
     dbl_radd,
     dbl_wen,
     dbl_wadd,
     dbl_wdat
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

input [WIDTH-1:0]   dbl_audat;
input               dbl_auvld;
input               dbl_en;

output [ADDR-1:0]   dbl_radd;
output              dbl_wen;
output [ADDR-1:0]   dbl_wadd;
output [WIDTH-1:0]  dbl_wdat;

output              dbl_start;
output [3:0]        dbl_opcode;
output [WIDTH-1:0]  dbl_const;
output              dbl_carry;
output              dbl_end;

////////////////////////////////////////////////////////////////////////////////
// Output declarations

reg [ADDR-1:0]      dbl_radd;
reg                 dbl_wen;
reg [ADDR-1:0]      dbl_wadd;
reg [WIDTH-1:0]     dbl_wdat;

reg                 dbl_start;
reg [3:0]           dbl_opcode;
reg [WIDTH-1:0]     dbl_const;
reg                 dbl_carry;
reg                 dbl_end;

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

reg [4:0]           dbl_step;
wire [4:0]          dbl_step_inc;
assign              dbl_step_inc = dbl_step + 1'b1;

reg                 dbl_1more;
reg                 dbl_en_sticky;

always @(posedge clk)
    begin
    if (rst)
        begin
        dbl_radd    <= INIT;
        dbl_wen     <= INIT;    //*
        dbl_wadd    <= INIT;
        dbl_wdat    <= INIT;
        //==================
        dbl_start   <= INIT;    //*
        dbl_opcode  <= INIT;
        dbl_const   <= INIT;
        dbl_carry   <= INIT;    //*
        dbl_end     <= INIT;    //*
        //==================
        dbl_step    <= INIT;
        dbl_1more   <= INIT;
        dbl_en_sticky   <= INIT;
        end
    else if (dbl_en)
        begin
        dbl_radd    <= INIT;
        dbl_wen     <= INIT;    //*
        dbl_wadd    <= INIT;
        dbl_wdat    <= INIT;
        //==================
        dbl_start   <= INIT;    //*
        dbl_opcode  <= INIT;
        dbl_const   <= INIT;
        dbl_carry   <= INIT;    //*
        dbl_end     <= INIT;    //*
        //==================
        dbl_step    <= INIT;
        dbl_1more   <= INIT;
        dbl_en_sticky   <= 1'b1;
        end
    else if (dbl_en_sticky)
        begin
        case(dbl_step)
            5'd0:               // X1^2
                begin
                case(dbl_1more)
                    1'b0: 
                        begin
                        dbl_start   <= 1'b0;
                        dbl_step    <= dbl_step;
                        end
                    1'b1: 
                        begin
                        dbl_start   <= 1'b1;
                        dbl_step    <= dbl_step_inc;
                        end
                endcase
                dbl_radd    <= TEMP0;               // X_KG
                dbl_1more   <= ~dbl_1more;
                dbl_opcode  <= OP_MUL;
                dbl_const   <= INIT;
                dbl_carry   <= 1'b0;
                dbl_end     <= 1'b0;
                end
            5'd1:               // 3*X1^2
                begin
                if (dbl_auvld)
                    begin
                    dbl_radd    <= TEMP3;
                    dbl_wen     <= 1'b1;
                    dbl_wadd    <= TEMP3;           // X1^2
                    dbl_wdat    <= dbl_audat;
                    //====================
                    dbl_opcode  <= OP_MUL;
                    dbl_const   <= 256'd3;
                    dbl_start   <= 1'b1;
                    dbl_carry   <= 1'b0;
                    dbl_step    <= dbl_step_inc;
                    dbl_end     <= 1'b0;
                    end
                else
                    begin
                    dbl_wen     <= 1'b0;
                    dbl_start   <= 1'b0;
                    dbl_end     <= 1'b0;
                    dbl_1more   <= 1'b0;
                    end
                end
            5'd2:               // Z1^2
                begin
                case(dbl_1more)
                    1'b0: 
                        begin
                        dbl_start   <= 1'b0;
                        dbl_step    <= dbl_step;
                        dbl_1more   <= dbl_auvld;
                        end
                    1'b1: 
                        begin
                        dbl_start   <= 1'b1;
                        dbl_step    <= dbl_step_inc;
                        dbl_1more   <= 1'b0;
                        end
                endcase
                if (dbl_auvld)
                    begin
                    dbl_radd    <= TEMP2;           // Z_KG
                    dbl_wen     <= ~dbl_wen;
                    dbl_wadd    <= TEMP3;           // 3*X1^2
                    dbl_wdat    <= dbl_audat;
                    //====================              
                    dbl_opcode  <= OP_MUL;
                    dbl_const   <= INIT;
                    dbl_carry   <= 1'b0;
                    dbl_end     <= 1'b0;
                    end
                else
                    begin
                    dbl_wen     <= 1'b0;
                    dbl_end     <= 1'b0;
                    end
                end
            5'd3:               // Z1^4
                begin
                case(dbl_1more)
                    1'b0: 
                        begin
                        dbl_start   <= 1'b0;
                        dbl_step    <= dbl_step;
                        dbl_1more   <= dbl_auvld;
                        end
                    1'b1: 
                        begin
                        dbl_start   <= 1'b1;
                        dbl_step    <= dbl_step_inc;
                        dbl_1more   <= 1'b0;
                        end
                endcase
                if (dbl_auvld)
                    begin
                    dbl_radd    <= TEMP4;
                    dbl_wen     <= ~dbl_wen;
                    dbl_wadd    <= TEMP4;           // Z1^2
                    dbl_wdat    <= dbl_audat;
                    //====================              
                    dbl_opcode  <= OP_MUL;
                    dbl_const   <= INIT;
                    dbl_carry   <= 1'b0;
                    dbl_end     <= 1'b0;
                    end
                else
                    begin
                    dbl_wen     <= 1'b0;
                    dbl_end     <= 1'b0;
                    end
                end
            5'd4:               // 3*Z1^4
                begin
                if (dbl_auvld)
                    begin
                    dbl_radd    <= TEMP4;
                    dbl_wen     <= 1'b1;
                    dbl_wadd    <= TEMP4;           // Z1^4
                    dbl_wdat    <= dbl_audat;
                    //====================
                    dbl_opcode  <= OP_MUL;
                    dbl_const   <= 256'd3;
                    dbl_start   <= 1'b1;
                    dbl_end     <= 1'b0;
                    dbl_carry   <= 1'b0;
                    dbl_step    <= dbl_step_inc;
                    end
                else
                    begin
                    dbl_wen     <= 1'b0;
                    dbl_start   <= 1'b0;
                    dbl_end     <= 1'b0;
                    dbl_1more   <= 1'b0;
                    end
                end
            5'd5:               // M = 3*X1^2 - 3*Z1^4
                begin
                case(dbl_1more)
                    1'b0: 
                        begin
                        dbl_start   <= 1'b0;
                        dbl_step    <= dbl_step;
                        dbl_radd    <= dbl_auvld? TEMP4: dbl_radd;   // 3*Z1^4
                        dbl_1more   <= dbl_auvld;
                        end
                    1'b1: 
                        begin
                        dbl_start   <= 1'b1;
                        dbl_step    <= dbl_step_inc;
                        dbl_radd    <= TEMP3;       // 3*X1^2
                        dbl_1more   <= 1'b0;
                        end
                endcase
                if (dbl_auvld)
                    begin
                    dbl_wen     <= ~dbl_wen;
                    dbl_wadd    <= TEMP4;           // 3*Z1^4
                    dbl_wdat    <= dbl_audat;
                    //====================              
                    dbl_opcode  <= OP_FA;
                    dbl_const   <= INIT;
                    dbl_carry   <= 1'b1;
                    dbl_end     <= 1'b0;
                    end
                else
                    begin
                    dbl_wen     <= 1'b0;
                    dbl_end     <= 1'b0;
                    end
                end
            5'd6:               // Y1^2
                begin
                case(dbl_1more)
                    1'b0: 
                        begin
                        dbl_start   <= 1'b0;
                        dbl_step    <= dbl_step;
                        dbl_1more   <= dbl_auvld;
                        end
                    1'b1: 
                        begin
                        dbl_start   <= 1'b1;
                        dbl_step    <= dbl_step_inc;
                        dbl_1more   <= 1'b0;
                        end
                endcase
                if (dbl_auvld)
                    begin
                    dbl_radd    <= TEMP1;           // Y_KG
                    dbl_wen     <= ~dbl_wen;
                    dbl_wadd    <= TEMP3;           // M
                    dbl_wdat    <= dbl_audat;
                    //====================              
                    dbl_opcode  <= OP_MUL;
                    dbl_const   <= INIT;
                    dbl_carry   <= 1'b0;
                    dbl_end     <= 1'b0;
                    end
                else
                    begin
                    dbl_wen     <= 1'b0;
                    dbl_end     <= 1'b0;
                    end
                end
            5'd7:               // X1*Y1^2
                begin
                case(dbl_1more)
                     1'b0: 
                         begin
                         dbl_start   <= 1'b0;
                         dbl_step    <= dbl_step;
                         dbl_radd    <= dbl_auvld? TEMP0: dbl_radd;   // X_KG
                         dbl_1more  <= dbl_auvld;
                         end
                     1'b1: 
                         begin
                         dbl_start   <= 1'b1;
                         dbl_step    <= dbl_step_inc;
                         dbl_radd    <= TEMP4;      // Y1^2
                         dbl_1more  <= 1'b0;
                         end
                endcase
                if (dbl_auvld)
                    begin
                    dbl_wen     <= ~dbl_wen;
                    dbl_wadd    <= TEMP4;           // Y1^2
                    dbl_wdat    <= dbl_audat;
                    //====================              
                    dbl_opcode  <= OP_MUL;
                    dbl_const   <= INIT;
                    dbl_carry   <= 1'b0;
                    dbl_end     <= 1'b0;
                    end
                else
                    begin
                    dbl_wen     <= 1'b0;
                    dbl_end     <= 1'b0;
                    end
                end
            5'd8:               // T = Y1^4
                begin
                case(dbl_1more)
                    1'b0: 
                        begin
                        dbl_start   <= 1'b0;
                        dbl_step    <= dbl_step;
                        dbl_1more   <= dbl_auvld;
                        end
                    1'b1: 
                        begin
                        dbl_start   <= 1'b1;
                        dbl_step    <= dbl_step_inc;
                        dbl_1more   <= 1'b0;
                        end
                endcase
                if (dbl_auvld)
                    begin
                    dbl_radd    <= TEMP4;           // Y1^2
                    dbl_wen     <= ~dbl_wen;
                    dbl_wadd    <= TEMP5;           // X1*Y1^2
                    dbl_wdat    <= dbl_audat;
                    //====================              
                    dbl_opcode  <= OP_MUL;
                    dbl_const   <= INIT;
                    dbl_carry   <= 1'b0;
                    dbl_end     <= 1'b0;
                    end
                else
                    begin
                    dbl_wen     <= 1'b0;
                    dbl_end     <= 1'b0;
                    end
                end
            5'd9:               // S = 4*X1*Y1^2
                begin
                if (dbl_auvld)
                    begin
                    dbl_radd    <= TEMP5;
                    dbl_wen     <= 1'b1;
                    dbl_wadd    <= TEMP4;           // T
                    dbl_wdat    <= dbl_audat;
                    //====================
                    dbl_opcode  <= OP_MUL;
                    dbl_const   <= 256'd4;
                    dbl_start   <= 1'b1;
                    dbl_carry   <= 1'b0;
                    dbl_end     <= 1'b0;
                    dbl_step    <= dbl_step_inc;
                    end
                else
                    begin
                    dbl_wen     <= 1'b0;
                    dbl_start   <= 1'b0;
                    dbl_end     <= 1'b0;
                    end
                end
            5'd10:              // M^2
                begin
                case(dbl_1more)
                    1'b0: 
                        begin
                        dbl_start   <= 1'b0;
                        dbl_step    <= dbl_step;
                        dbl_1more   <= dbl_auvld;
                        end
                    1'b1: 
                        begin
                        dbl_start   <= 1'b1;
                        dbl_step    <= dbl_step_inc;
                        dbl_1more   <= 1'b0;
                        end
                endcase
                if (dbl_auvld)
                    begin
                    dbl_radd    <= TEMP3;           // M
                    dbl_wen     <= ~dbl_wen;
                    dbl_wadd    <= TEMP5;           // S
                    dbl_wdat    <= dbl_audat;
                    //====================              
                    dbl_opcode  <= OP_MUL;
                    dbl_const   <= INIT;
                    dbl_carry   <= 1'b0;
                    dbl_end     <= 1'b0;
                    end
                else
                    begin
                    dbl_wen     <= 1'b0;
                    dbl_end     <= 1'b0;
                    end
                end
            5'd11:              // 2S
                begin
                if (dbl_auvld)
                    begin
                    dbl_radd    <= TEMP5;
                    dbl_wen     <= 1'b1;
                    dbl_wadd    <= TEMP6;           // M^2
                    dbl_wdat    <= dbl_audat;
                    //====================
                    dbl_opcode  <= OP_MUL;
                    dbl_const   <= 256'd2;
                    dbl_start   <= 1'b1;
                    dbl_carry   <= 1'b0;
                    dbl_end     <= 1'b0;
                    dbl_step    <= dbl_step_inc;
                    end
                else
                    begin
                    dbl_wen     <= 1'b0;
                    dbl_start   <= 1'b0;
                    dbl_end     <= 1'b0;
                    end
                end
            5'd12:              // X = M^2 - 2S
                begin
                case(dbl_1more)
                    1'b0: 
                        begin
                        dbl_start   <= 1'b0;
                        dbl_step    <= dbl_step;
                        dbl_radd    <= dbl_auvld? TEMP7: dbl_radd;   // 2S
                        dbl_1more   <= dbl_auvld;
                        end
                    1'b1: 
                        begin
                        dbl_start   <= 1'b1;
                        dbl_step    <= dbl_step_inc;
                        dbl_radd    <= TEMP6;       // M^2
                        dbl_1more   <= 1'b0;
                        end
                endcase
                if (dbl_auvld)
                    begin
                    dbl_wen     <= ~dbl_wen;
                    dbl_wadd    <= TEMP7;           // 2S
                    dbl_wdat    <= dbl_audat;
                    //====================              
                    dbl_opcode  <= OP_FA;
                    dbl_const   <= INIT;
                    dbl_carry   <= 1'b1;
                    dbl_end     <= 1'b0;
                    end
                else
                    begin
                    dbl_wen     <= 1'b0;
                    dbl_end     <= 1'b0;
                    end
                end
            5'd13:              //  Y1*Z1
                begin
                case(dbl_1more)
                    1'b0: 
                        begin
                        dbl_start   <= 1'b0;
                        dbl_step    <= dbl_step;
                        dbl_radd    <= dbl_auvld? TEMP1: dbl_radd;   // Y_KG
                        dbl_1more   <= dbl_auvld;
                        end
                    1'b1: 
                        begin
                        dbl_start   <= 1'b1;
                        dbl_step    <= dbl_step_inc;
                        dbl_radd    <= TEMP2;       // Z_KG
                        dbl_1more   <= 1'b0;
                        end
                endcase
                if (dbl_auvld)
                    begin
                    dbl_wen     <= ~dbl_wen;
                    dbl_wadd    <= TEMP0;           // X
                    dbl_wdat    <= dbl_audat;
                    //====================              
                    dbl_opcode  <= OP_MUL;
                    dbl_const   <= INIT;
                    dbl_carry   <= 1'b0;
                    dbl_end     <= 1'b0;
                    end
                else
                    begin
                    dbl_wen     <= 1'b0;
                    dbl_end     <= 1'b0;
                    end
                end
            5'd14:              // Z3
                begin
                if (dbl_auvld)
                    begin
                    dbl_radd    <= TEMP2;
                    dbl_wen     <= 1'b1;
                    dbl_wadd    <= TEMP2;           // Y1*Z1
                    dbl_wdat    <= dbl_audat;
                    //====================
                    dbl_opcode  <= OP_MUL;
                    dbl_const   <= 256'd2;
                    dbl_start   <= 1'b1;
                    dbl_carry   <= 1'b0;
                    dbl_end     <= 1'b0;
                    dbl_step    <= dbl_step_inc;
                    end
                else
                    begin
                    dbl_wen     <= 1'b0;
                    dbl_start   <= 1'b0;
                    dbl_end     <= 1'b0;
                    dbl_1more   <= 1'b0;
                    end
                end
            5'd15:              // 8T
                begin
                if (dbl_auvld)
                    begin
                    dbl_radd    <= TEMP4;           // T
                    dbl_wen     <= 1'b1;
                    dbl_wadd    <= TEMP2;           // Z3
                    dbl_wdat    <= dbl_audat;
                    //====================
                    dbl_opcode  <= OP_MUL;
                    dbl_const   <= 256'd8;
                    dbl_start   <= 1'b1;
                    dbl_carry   <= 1'b0;
                    dbl_end     <= 1'b0;
                    dbl_step    <= dbl_step_inc;
                    end
                else
                    begin
                    dbl_wen     <= 1'b0;
                    dbl_start   <= 1'b0;
                    dbl_end     <= 1'b0;
                    dbl_1more   <= 1'b0;
                    end
                end 
            5'd16:              // S - X3
                begin
                case(dbl_1more)
                    1'b0: 
                        begin
                        dbl_start   <= 1'b0;
                        dbl_step    <= dbl_step;
                        dbl_radd    <= dbl_auvld? TEMP0: dbl_radd;   // X
                        dbl_1more   <= dbl_auvld;
                        end
                    1'b1: 
                        begin
                        dbl_start   <= 1'b1;
                        dbl_step    <= dbl_step_inc;
                        dbl_radd    <= TEMP5;       // S
                        dbl_1more   <= 1'b0;
                        end
                endcase
                if (dbl_auvld)
                    begin
                    dbl_wen     <= ~dbl_wen;
                    dbl_wadd    <= TEMP4;           // 8T
                    dbl_wdat    <= dbl_audat;
                    //====================              
                    dbl_opcode  <= OP_FA;
                    dbl_const   <= INIT;
                    dbl_carry   <= 1'b1;
                    dbl_end     <= 1'b0;
                    end
                else
                    begin
                    dbl_wen     <= 1'b0;
                    dbl_end     <= 1'b0;
                    end
                end
            5'd17:              // M(S - X3)
                begin
                case(dbl_1more)
                    1'b0: 
                        begin
                        dbl_start   <= 1'b0;
                        dbl_step    <= dbl_step;
                        dbl_radd    <= dbl_auvld? TEMP3: dbl_radd;   // M
                        dbl_1more   <= dbl_auvld;
                        end
                    1'b1: 
                        begin
                        dbl_start   <= 1'b1;
                        dbl_step    <= dbl_step_inc;
                        dbl_radd    <= TEMP5;       // S - X3
                        dbl_1more   <= 1'b0;
                        end
                endcase 
                if (dbl_auvld)
                    begin
                    dbl_wen     <= ~dbl_wen;
                    dbl_wadd    <= TEMP5;           // S - X3
                    dbl_wdat    <= dbl_audat;
                    //====================              
                    dbl_opcode  <= OP_MUL;
                    dbl_const   <= INIT;
                    dbl_carry   <= 1'b0;
                    dbl_end     <= 1'b0;
                    end
                else
                    begin
                    dbl_wen     <= 1'b0;
                    dbl_end     <= 1'b0;
                    end
                end
            5'd18:              // Y3
                begin
                case(dbl_1more)
                    1'b0: 
                        begin
                        dbl_start   <= 1'b0;
                        dbl_step    <= dbl_step;
                        dbl_radd    <= dbl_auvld? TEMP4: dbl_radd;   // 8T
                        dbl_1more   <= dbl_auvld;
                        end
                    1'b1: 
                        begin
                        dbl_start   <= 1'b1;
                        dbl_step    <= dbl_step_inc;
                        dbl_radd    <= TEMP3;       // M(S-X3)
                        dbl_1more   <= 1'b0;
                        end
                endcase
                if (dbl_auvld)
                    begin
                    dbl_wen     <= ~dbl_wen;
                    dbl_wadd    <= TEMP3;           // M(S-X3)
                    dbl_wdat    <= dbl_audat;
                    //====================              
                    dbl_opcode  <= OP_FA;
                    dbl_const   <= INIT;
                    dbl_carry   <= 1'b1;
                    dbl_end     <= 1'b0;
                    end
                else
                    begin
                    dbl_wen     <= 1'b0;
                    dbl_end     <= 1'b0;
                    end
                end
            5'd19:              // Save Y3
                begin
                if (dbl_auvld)
                    begin
                    dbl_const   <= INIT;
                    dbl_wen     <= 1'b1;
                    dbl_wadd    <= TEMP1;
                    dbl_wdat    <= dbl_audat;
                    dbl_end     <= 1'b1;
                    dbl_step    <= dbl_step_inc;
                    end
                else
                    begin
                    dbl_wen     <= 1'b0;
                    dbl_start   <= 1'b0;
                    dbl_end     <= 1'b0;
                    dbl_1more   <= 1'b0;
                    end
                end
            default:
                begin
                dbl_radd    <= INIT;
                dbl_wen     <= INIT;    //*
                dbl_wadd    <= INIT;
                dbl_wdat    <= INIT;
                //==================
                dbl_start   <= INIT;    //*
                dbl_opcode  <= INIT;
                dbl_const   <= INIT;
                dbl_carry   <= INIT;
                //==================
                dbl_step    <= INIT;
                dbl_end     <= INIT;    //*
                //==================
                dbl_1more   <= INIT;
                dbl_en_sticky   <= INIT;
                end
        endcase
        end
    end

endmodule 
