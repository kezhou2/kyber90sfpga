////////////////////////////////////////////////////////////////////////////////
//
// Ho Chi Minh City University of Technology
//
// Filename     : auc_wmul_add.v
// Description  : .
//
// Author       : Vuong Dinh Hung
// Created On   : Fri Apr 26 16:07:32 2019
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module auc_wmul_add
    (
     clk,
     rst,
     // Input
     add_audat,
     add_auvld,
     add_en,
     add_sign,
     add_paddx,
     add_paddy,
     add_paddz,
     add_pre_done,
     // Output
     add_start,
     add_opcode,
     add_const,
     add_carry,
     add_end,
     // RAM control
     add_radd,
     add_wen,
     add_wadd,
     add_wdat
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

input [WIDTH-1:0]   add_audat;
input               add_auvld;
input               add_en;
input               add_sign;
input [ADDR-1:0]    add_paddx;
input [ADDR-1:0]    add_paddy;
input [ADDR-1:0]    add_paddz;
input               add_pre_done;

output [ADDR-1:0]   add_radd;
output              add_wen;
output [ADDR-1:0]   add_wadd;
output [WIDTH-1:0]  add_wdat;

output              add_start;
output [3:0]        add_opcode;
output [WIDTH-1:0]  add_const;
output              add_carry;
output              add_end;

////////////////////////////////////////////////////////////////////////////////
// Output declarations

reg [ADDR-1:0]      add_radd;
reg                 add_wen;
reg [ADDR-1:0]      add_wadd;
reg [WIDTH-1:0]     add_wdat;

reg                 add_start;
reg [3:0]           add_opcode;
reg [WIDTH-1:0]     add_const;
reg                 add_carry;
reg                 add_end;

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

reg [4:0]           add_step;
wire [4:0]          add_step_inc;
assign              add_step_inc = add_step + 1'b1;

reg                 add_1more;
reg                 add_en_sticky;

wire [ADDR-1:0]     pre_waddx;
assign pre_waddx = ((add_paddx == X_G) ? X_3G :
                    (add_paddx == X_3G)? X_5G : X_7G);

wire [ADDR-1:0]     pre_waddy;
assign pre_waddy = ((add_paddy == Y_G) ? Y_3G :
                    (add_paddy == Y_3G)? Y_5G : Y_7G);

wire [ADDR-1:0]     pre_waddz;
assign pre_waddz = ((add_paddz == ONERAM) ? Z_3G :
                    (add_paddz == Z_3G)? Z_5G : Z_7G);


always @(posedge clk)
    begin
    if (rst)
        begin
        add_radd    <= INIT;
        add_wen     <= INIT;    //*
        add_wadd    <= INIT;
        add_wdat    <= INIT;
        //==================
        add_start   <= INIT;    //*
        add_opcode  <= INIT;
        add_const   <= INIT;
        add_carry   <= INIT;    //*
        add_end     <= INIT;    //*
        //==================
        add_step    <= INIT;
        add_1more   <= INIT;
        add_en_sticky   <= INIT;
        end
    else if (add_en)
        begin
        add_radd    <= INIT;
        add_wen     <= INIT;    //*
        add_wadd    <= INIT;
        add_wdat    <= INIT;
        //==================
        add_start   <= INIT;    //*
        add_opcode  <= INIT;
        add_const   <= INIT;
        add_carry   <= INIT;    //*
        add_end     <= INIT;    //*
        //==================
        add_step    <= INIT;
        add_1more   <= INIT;  
        add_en_sticky   <= 1'b1;  
        end
    else if (add_en_sticky)
        begin
        case(add_step)
            5'd0:               // Z2^2
                begin
                case(add_1more)
                    1'b0: 
                        begin
                        add_start   <= 1'b0;
                        add_step    <= add_step;
                        end
                    1'b1: 
                        begin
                        add_start   <= 1'b1;
                        add_step    <= add_step_inc;
                        end
                endcase
                add_radd    <= add_paddz;           // Z2
                add_1more   <= ~add_1more;
                add_opcode  <= OP_MUL;
                add_const   <= INIT;
                add_carry   <= 1'b0;
                add_end     <= 1'b0;
                end
            5'd1:               // U1 = X1 * Z2^2
                begin
                case(add_1more)
                     1'b0: 
                         begin
                         add_start  <= 1'b0;
                         add_step   <= add_step;
                         add_radd   <= add_auvld? TEMP0: add_radd;      // X1
                         add_1more  <= add_auvld;
                         end
                     1'b1: 
                         begin
                         add_start  <= 1'b1;
                         add_step   <= add_step_inc;
                         add_radd   <= TEMP3;       // Z2^2
                         add_1more  <= 1'b0;
                         end
                endcase
                if (add_auvld)
                    begin
                    add_wen     <= ~add_wen;
                    add_wadd    <= TEMP3;           // Z2^2
                    add_wdat    <= add_audat;
                    //====================              
                    add_opcode  <= OP_MUL;
                    add_const   <= INIT;
                    add_carry   <= 1'b0;
                    add_end     <= 1'b0;
                    end
                else
                    begin
                    add_wen     <= 1'b0;
                    add_end     <= 1'b0;
                    end
                end
            5'd2:               // Z1^2
                begin
                case(add_1more)
                    1'b0: 
                        begin
                        add_start   <= 1'b0;
                        add_step    <= add_step;
                        add_1more   <= add_auvld;
                        end
                    1'b1: 
                        begin
                        add_start   <= 1'b1;
                        add_step    <= add_step_inc;
                        add_1more   <= 1'b0;
                        end
                endcase
                if (add_auvld)
                    begin
                    add_radd    <= TEMP2;           // Z1
                    add_wen     <= ~add_wen;
                    add_wadd    <= TEMP4;           // U1
                    add_wdat    <= add_audat;
                    //====================              
                    add_opcode  <= OP_MUL;
                    add_const   <= INIT;
                    add_carry   <= 1'b0;
                    add_end     <= 1'b0;
                    end
                else
                    begin
                    add_wen     <= 1'b0;
                    add_end     <= 1'b0;
                    end
                end
            5'd3:               // U2 = X2*Z1^2
                begin
                case(add_1more)
                     1'b0: 
                         begin
                         add_start  <= 1'b0;
                         add_step   <= add_step;
                         add_radd   <= add_auvld? add_paddx: add_radd;  // X2
                         add_1more  <= add_auvld;
                         end
                     1'b1: 
                         begin
                         add_start  <= 1'b1;
                         add_step   <= add_step_inc;
                         add_radd   <= TEMP5;       // Z1^2
                         add_1more  <= 1'b0;
                         end
                endcase
                if (add_auvld)
                    begin
                    add_wen     <= ~add_wen;
                    add_wadd    <= TEMP5;           // Z1^2
                    add_wdat    <= add_audat;
                    //====================              
                    add_opcode  <= OP_MUL;
                    add_const   <= INIT;
                    add_carry   <= 1'b0;
                    add_end     <= 1'b0;
                    end
                else
                    begin
                    add_wen     <= 1'b0;
                    add_end     <= 1'b0;
                    end
                end
            5'd4:               // Z2^2 * Z2
                begin
                case(add_1more)
                     1'b0: 
                         begin
                         add_start  <= 1'b0;
                         add_step   <= add_step;
                         add_radd   <= add_auvld? add_paddz: add_radd;  // Z2
                         add_1more  <= add_auvld;
                         end
                     1'b1: 
                         begin
                         add_start  <= 1'b1;
                         add_step   <= add_step_inc;
                         add_radd   <= TEMP3;       // Z2^2
                         add_1more  <= 1'b0;
                         end
                endcase
                if (add_auvld)
                    begin
                    add_wen     <= ~add_wen;
                    add_wadd    <= TEMP6;           // U2
                    add_wdat    <= add_audat;
                    //====================              
                    add_opcode  <= OP_MUL;
                    add_const   <= INIT;
                    add_carry   <= 1'b0;
                    add_end     <= 1'b0;
                    end
                else
                    begin
                    add_wen     <= 1'b0;
                    add_end     <= 1'b0;
                    end
                end
            5'd5:               // Z1^2 * Z1
                begin
                case(add_1more)
                     1'b0: 
                         begin
                         add_start  <= 1'b0;
                         add_step   <= add_step;
                         add_radd   <= add_auvld? TEMP2: add_radd;      // Z1
                         add_1more  <= add_auvld;
                         end
                     1'b1: 
                         begin
                         add_start  <= 1'b1;
                         add_step   <= add_step_inc;
                         add_radd   <= TEMP5;       // Z1^2
                         add_1more  <= 1'b0;
                         end
                endcase
                if (add_auvld)
                    begin
                    add_wen     <= ~add_wen;
                    add_wadd    <= TEMP3;           // Z2^3
                    add_wdat    <= add_audat;
                    //====================              
                    add_opcode  <= OP_MUL;
                    add_const   <= INIT;
                    add_carry   <= 1'b0;
                    add_end     <= 1'b0;
                    end
                else
                    begin
                    add_wen     <= 1'b0;
                    add_end     <= 1'b0;
                    end
                end
            5'd6:               // - Y2
                begin
                 case(add_1more)
                    1'b0: 
                        begin
                        add_start   <= 1'b0;
                        add_step    <= add_step;
                        add_radd    <= add_auvld? add_paddy: add_radd;  //  Y2
                        add_1more   <= add_auvld;
                        end
                    1'b1: 
                        begin
                        add_start   <= 1'b1;
                        add_step    <= add_step_inc;
                        add_radd    <= ZRRAM;       // 0
                        add_1more   <= 1'b0;
                        end
                endcase
                if (add_auvld)
                    begin
                    add_wen     <= ~add_wen;
                    add_wadd    <= TEMP5;           // Z1^3
                    add_wdat    <= add_audat;
                    //====================              
                    add_opcode  <= OP_FA;
                    add_const   <= INIT;
                    add_carry   <= 1'b1;
                    add_end     <= 1'b0;
                    end
                else
                    begin
                    add_wen     <= 1'b0;
                    add_end     <= 1'b0;
                    end
                end
            5'd7:               // S1 = Y1 * Z2^3
                begin
                case(add_1more)
                     1'b0: 
                         begin
                         add_start  <= 1'b0;
                         add_step   <= add_step;
                         add_radd   <= add_auvld? TEMP1: add_radd;      // Y1
                         add_1more  <= add_auvld;
                         end
                     1'b1: 
                         begin
                         add_start  <= 1'b1;
                         add_step   <= add_step_inc;
                         add_radd   <= TEMP3;       // Z2^3
                         add_1more  <= 1'b0;
                         end
                endcase
                if (add_auvld)
                    begin
                    add_wen     <= ~add_wen;
                    add_wadd    <= TEMP8;           // -Y2
                    add_wdat    <= add_audat;
                    //====================              
                    add_opcode  <= OP_MUL;
                    add_const   <= INIT;
                    add_carry   <= 1'b0;
                    add_end     <= 1'b0;
                    end
                else
                    begin
                    add_wen     <= 1'b0;
                    add_end     <= 1'b0;
                    end
                end
            5'd8:               // S2 = Y2 * Z1^3
                begin
                case(add_1more)
                     1'b0: 
                         begin
                         add_start  <= 1'b0;
                         add_step   <= add_step;
                         add_radd   <= add_auvld? 
                                       add_sign? TEMP8: add_paddy: add_radd; 
                         add_1more  <= add_auvld;
                         end
                     1'b1: 
                         begin
                         add_start  <= 1'b1;
                         add_step   <= add_step_inc;
                         add_radd   <= TEMP5;       // Z1^3
                         add_1more  <= 1'b0;
                         end
                endcase
                if (add_auvld)
                    begin
                    add_wen     <= ~add_wen;
                    add_wadd    <= TEMP3;           // S1
                    add_wdat    <= add_audat;
                    //====================              
                    add_opcode  <= OP_MUL;
                    add_const   <= INIT;
                    add_carry   <= 1'b0;
                    add_end     <= 1'b0;
                    end
                else
                    begin
                    add_wen     <= 1'b0;
                    add_end     <= 1'b0;
                    end
                end
            5'd9:               // H = U1 - U2
                begin
                case(add_1more)
                    1'b0: 
                        begin
                        add_start  <= 1'b0;
                        add_step   <= add_step;
                        add_radd   <= add_auvld? TEMP6: add_radd;       // U2
                        add_1more   <= add_auvld;
                        end
                    1'b1: 
                        begin
                        add_start  <= 1'b1;
                        add_step   <= add_step_inc;
                        add_radd   <= TEMP4;        // U1
                        add_1more  <= 1'b0;
                        end
                endcase
                if (add_auvld)
                    begin
                    add_wen     <= ~add_wen;
                    add_wadd    <= TEMP5;           // S2
                    add_wdat    <= add_audat;
                    //====================              
                    add_opcode  <= OP_FA;
                    add_const   <= INIT;
                    add_carry   <= 1'b1;
                    add_end     <= 1'b0;
                    end
                else
                    begin
                    add_wen     <= 1'b0;
                    add_end     <= 1'b0;
                    end
                end
            5'd10:              // H^2
                begin
                case(add_1more)
                    1'b0: 
                        begin
                        add_start   <= 1'b0;
                        add_step    <= add_step;
                        add_1more   <= add_auvld;
                        end
                    1'b1: 
                        begin
                        add_start   <= 1'b1;
                        add_step    <= add_step_inc;
                        add_1more   <= 1'b0;
                        end
                endcase
                if (add_auvld)
                    begin
                    add_radd    <= TEMP6;           // H
                    add_wen     <= ~add_wen;
                    add_wadd    <= TEMP6;           // H
                    add_wdat    <= add_audat;
                    //====================              
                    add_opcode  <= OP_MUL;
                    add_const   <= INIT;
                    add_carry   <= 1'b0;
                    add_end     <= 1'b0;
                    end
                else
                    begin
                    add_wen     <= 1'b0;
                    add_end     <= 1'b0;
                    end
                end
            5'd11:              // V = H^2 * U1
                begin
                case(add_1more)
                     1'b0: 
                         begin
                         add_start  <= 1'b0;
                         add_step   <= add_step;
                         add_radd   <= add_auvld? TEMP7: add_radd;      // H^2
                         add_1more  <= add_auvld;
                         end
                     1'b1: 
                         begin
                         add_start  <= 1'b1;
                         add_step   <= add_step_inc;
                         add_radd   <= TEMP4;       // U1
                         add_1more  <= 1'b0;
                         end
                endcase
                if (add_auvld)
                    begin
                    add_wen     <= ~add_wen;
                    add_wadd    <= TEMP7;           // H^2
                    add_wdat    <= add_audat;
                    //====================              
                    add_opcode  <= OP_MUL;
                    add_const   <= INIT;
                    add_carry   <= 1'b0;
                    add_end     <= 1'b0;
                    end
                else
                    begin
                    add_wen     <= 1'b0;
                    add_end     <= 1'b0;
                    end
                end
            5'd12:              // G = H^2 * H 
                begin
                case(add_1more)
                     1'b0: 
                         begin
                         add_start  <= 1'b0;
                         add_step   <= add_step;
                         add_radd   <= add_auvld? TEMP7: add_radd;      // H^2
                         add_1more  <= add_auvld;
                         end
                     1'b1: 
                         begin
                         add_start  <= 1'b1;
                         add_step   <= add_step_inc;
                         add_radd   <= TEMP6;       // H
                         add_1more  <= 1'b0;
                         end
                endcase
                if (add_auvld)
                    begin
                    add_wen     <= ~add_wen;
                    add_wadd    <= TEMP4;           // V
                    add_wdat    <= add_audat;
                    //====================              
                    add_opcode  <= OP_MUL;
                    add_const   <= INIT;
                    add_carry   <= 1'b0;
                    add_end     <= 1'b0;
                    end
                else
                    begin
                    add_wen     <= 1'b0;
                    add_end     <= 1'b0;
                    end
                end
            5'd13:              // R = S1 - S2
                begin
                case(add_1more)
                    1'b0: 
                        begin
                        add_start  <= 1'b0;
                        add_step   <= add_step;
                        add_radd   <= add_auvld? TEMP5: add_radd;       // S2
                        add_1more   <= add_auvld;
                        end
                    1'b1: 
                        begin
                        add_start  <= 1'b1;
                        add_step   <= add_step_inc;
                        add_radd   <= TEMP3;        // S1
                        add_1more   <= 1'b0;
                        end
                endcase
                if (add_auvld)
                    begin
                    add_wen     <= ~add_wen;
                    add_wadd    <= TEMP7;           // G
                    add_wdat    <= add_audat;
                    //====================              
                    add_opcode  <= OP_FA;
                    add_const   <= INIT;
                    add_carry   <= 1'b1;
                    add_end     <= 1'b0;
                    end
                else
                    begin
                    add_wen     <= 1'b0;
                    add_end     <= 1'b0;
                    end
                end
            5'd14:              // Z1 * Z2
                begin
                case(add_1more)
                     1'b0: 
                         begin
                         add_start  <= 1'b0;
                         add_step   <= add_step;
                         add_radd   <= add_auvld? TEMP2: add_radd;      // Z1
                         add_1more  <= add_auvld;
                         end
                     1'b1: 
                         begin
                         add_start  <= 1'b1;
                         add_step   <= add_step_inc;
                         add_radd   <= add_paddz;   // Z2
                         add_1more  <= 1'b0;
                         end
                endcase
                if (add_auvld)
                    begin
                    add_wen     <= ~add_wen;
                    add_wadd    <= TEMP5;           // R
                    add_wdat    <= add_audat;
                    //====================              
                    add_opcode  <= OP_MUL;
                    add_const   <= INIT;
                    add_carry   <= 1'b0;
                    add_end     <= 1'b0;
                    end
                else
                    begin
                    add_wen     <= 1'b0;
                    add_end     <= 1'b0;
                    end
                end
            5'd15:              // Z3 = H * Z1Z2
                begin
                case(add_1more)
                     1'b0: 
                         begin
                         add_start  <= 1'b0;
                         add_step   <= add_step;
                         add_radd   <= add_auvld? TEMP8: add_radd;      // Z1 * Z2
                         add_1more  <= add_auvld;
                         end
                     1'b1: 
                         begin
                         add_start  <= 1'b1;
                         add_step   <= add_step_inc;
                         add_radd   <= TEMP6;       // H
                         add_1more  <= 1'b0;
                         end
                endcase
                if (add_auvld)
                    begin
                    add_wen     <= ~add_wen;
                    add_wadd    <= TEMP8;           // Z1 * Z2
                    add_wdat    <= add_audat;
                    //====================              
                    add_opcode  <= OP_MUL;
                    add_const   <= INIT;
                    add_carry   <= 1'b0;
                    add_end     <= 1'b0;
                    end
                else
                    begin
                    add_wen     <= 1'b0;
                    add_end     <= 1'b0;
                    end
                end
            5'd16:              // S1 * G 
                begin
                case(add_1more)
                     1'b0: 
                         begin
                         add_start  <= 1'b0;
                         add_step   <= add_step;
                         add_radd   <= add_auvld? TEMP3: add_radd;      // S1
                         add_1more  <= add_auvld;
                         end
                     1'b1: 
                         begin
                         add_start  <= 1'b1;
                         add_step   <= add_step_inc;
                         add_radd   <= TEMP7;       // G
                         add_1more  <= 1'b0;
                         end
                endcase
                if (add_auvld)
                    begin
                    add_wen     <= ~add_wen;
                    add_wadd    <= add_pre_done? TEMP2: pre_waddz;      // Z3
                    add_wdat    <= add_audat;
                    //====================              
                    add_opcode  <= OP_MUL;
                    add_const   <= INIT;
                    add_carry   <= 1'b0;
                    add_end     <= 1'b0;
                    end
                else
                    begin
                    add_wen     <= 1'b0;
                    add_end     <= 1'b0;
                    end
                end
            5'd17:              // R^2
                begin
                case(add_1more)
                    1'b0: 
                        begin
                        add_start   <= 1'b0;
                        add_step    <= add_step;
                        add_1more   <= add_auvld;
                        end
                    1'b1: 
                        begin
                        add_start   <= 1'b1;
                        add_step    <= add_step_inc;
                        add_1more   <= 1'b0;
                        end
                endcase
                if (add_auvld)
                    begin
                    add_radd    <= TEMP5;           // R
                    add_wen     <= ~add_wen;
                    add_wadd    <= TEMP3;           // S1 * G
                    add_wdat    <= add_audat;
                    //====================              
                    add_opcode  <= OP_MUL;
                    add_const   <= INIT;
                    add_carry   <= 1'b0;
                    add_end     <= 1'b0;
                    end
                else
                    begin
                    add_wen     <= 1'b0;
                    add_end     <= 1'b0;
                    end
                end
            5'd18:              // R^2 + G
                begin
                case(add_1more)
                    1'b0: 
                        begin
                        add_start   <= 1'b0;
                        add_step    <= add_step;
                        add_radd    <= add_auvld? TEMP7: add_radd;      // G
                        add_1more   <= add_auvld;
                        end
                    1'b1: 
                        begin
                        add_start   <= 1'b1;
                        add_step    <= add_step_inc;
                        add_radd    <= TEMP6;       // R^2
                        add_1more   <= 1'b0;
                        end
                endcase
                if (add_auvld)
                    begin
                    add_wen     <= ~add_wen;
                    add_wadd    <= TEMP6;           // R^2
                    add_wdat    <= add_audat;
                    //====================              
                    add_opcode  <= OP_FA;
                    add_const   <= INIT;
                    add_carry   <= 1'b0;
                    add_end     <= 1'b0;
                    end
                else
                    begin
                    add_wen     <= 1'b0;
                    add_end     <= 1'b0;
                    end
                end
            5'd19:              // 2V
                begin
                if (add_auvld)
                    begin
                    add_radd    <= TEMP4;           // V
                    add_wen     <= 1'b1;
                    add_wadd    <= TEMP6;           // R^2 + G
                    add_wdat    <= add_audat;
                    //====================
                    add_opcode  <= OP_MUL;
                    add_const   <= 256'd2;
                    add_start   <= 1'b1;
                    add_carry   <= 1'b0;
                    add_end     <= 1'b0;
                    add_step    <= add_step_inc;
                    end
                else
                    begin
                    add_wen     <= 1'b0;
                    add_start   <= 1'b0;
                    add_end     <= 1'b0;
                    add_1more   <= 1'b0;
                    end
                end
            5'd20:              // X3
                begin
                case(add_1more)
                    1'b0: 
                        begin
                        add_start   <= 1'b0;
                        add_step    <= add_step;
                        add_radd    <= add_auvld? TEMP7: add_radd;      // 2V
                        add_1more   <= add_auvld;
                        end
                    1'b1: 
                        begin
                        add_start   <= 1'b1;
                        add_step    <= add_step_inc;
                        add_radd    <= TEMP6;       // R^2 + G
                        add_1more   <= 1'b0;
                        end
                endcase
                if (add_auvld)
                    begin
                    add_wen     <= ~add_wen;
                    add_wadd    <= TEMP7;           // 2V
                    add_wdat    <= add_audat;
                    //====================              
                    add_opcode  <= OP_FA;
                    add_const   <= INIT;
                    add_carry   <= 1'b1;
                    add_end     <= 1'b0;
                    end
                else
                    begin
                    add_wen     <= 1'b0;
                    add_end     <= 1'b0;
                    end
                end
            5'd21:              // V - X3
                begin
                case(add_1more)
                    1'b0: 
                        begin
                        add_start   <= 1'b0;
                        add_step    <= add_step;
                        add_radd    <= add_auvld? 
                                       add_pre_done? TEMP0: pre_waddx: add_radd;     
                        add_1more   <= add_auvld;
                        end
                    1'b1: 
                        begin
                        add_start   <= 1'b1;
                        add_step    <= add_step_inc;
                        add_radd    <= TEMP4;       // V
                        add_1more   <= 1'b0;
                        end
                endcase
                if (add_auvld)
                    begin
                    add_wen     <= ~add_wen;
                    add_wadd    <= add_pre_done? TEMP0: pre_waddx;      // X3
                    add_wdat    <= add_audat;
                    //====================              
                    add_opcode  <= OP_FA;
                    add_const   <= INIT;
                    add_carry   <= 1'b1;
                    add_end     <= 1'b0;
                    end
                else
                    begin
                    add_wen     <= 1'b0;
                    add_end     <= 1'b0;
                    end
                end
            5'd22:              // R*(v - X3)
                begin
                case(add_1more)
                     1'b0: 
                         begin
                         add_start  <= 1'b0;
                         add_step   <= add_step;
                         add_radd   <= add_auvld? TEMP5: add_radd;      // R
                         add_1more  <= add_auvld;
                         end
                     1'b1: 
                         begin
                         add_start  <= 1'b1;
                         add_step   <= add_step_inc;
                         add_radd   <= TEMP6;       // V - X3
                         add_1more  <= 1'b0;
                         end
                endcase
                if (add_auvld)
                    begin
                    add_wen     <= ~add_wen;
                    add_wadd    <= TEMP6;           // V - X3
                    add_wdat    <= add_audat;
                    //====================              
                    add_opcode  <= OP_MUL;
                    add_const   <= INIT;
                    add_carry   <= 1'b0;
                    add_end     <= 1'b0;    
                    end
                else
                    begin
                    add_wen     <= 1'b0;
                    add_end     <= 1'b0;
                    end
                end
            5'd23:              // Y3
                begin
                case(add_1more)
                    1'b0: 
                        begin
                        add_start   <= 1'b0;
                        add_step    <= add_step;
                        add_radd    <= add_auvld? TEMP3: add_radd;
                        add_1more   <= add_auvld;
                        end
                    1'b1: 
                        begin
                        add_start   <= 1'b1;
                        add_step    <= add_step_inc;
                        add_radd    <= TEMP6;  
                        add_1more   <= 1'b0;     
                        end
                endcase
                if (add_auvld)
                    begin
                    add_wen     <= ~add_wen;
                    add_wadd    <= TEMP6;           
                    add_wdat    <= add_audat;
                    //====================              
                    add_opcode  <= OP_FA;
                    add_const   <= INIT;
                    add_carry   <= 1'b1;
                    add_end     <= 1'b0;
                    end
                else
                    begin
                    add_wen     <= 1'b0;
                    add_end     <= 1'b0;
                    end
                end
            5'd24:              // Save Y3
                begin
                if (add_auvld)
                    begin
                    add_const   <= INIT;
                    add_wen     <= 1'b1;
                    add_wadd    <= add_pre_done? TEMP1: pre_waddy;
                    add_wdat    <= add_audat;
                    add_end     <= 1'b1;
                    add_step    <= add_step_inc;
                    end
                else
                    begin
                    add_wen     <= 1'b0;
                    add_start   <= 1'b0;
                    add_end     <= 1'b0;
                    add_1more   <= 1'b0;
                    end
                end
            default:
                begin
                add_radd    <= INIT;
                add_wen     <= INIT;    //*
                add_wadd    <= INIT;
                add_wdat    <= INIT;
                //==================
                add_start   <= INIT;    //*
                add_opcode  <= INIT;
                add_const   <= INIT;
                add_carry   <= INIT;
                //==================
                add_step    <= INIT;
                add_end     <= INIT;    //*
                //==================
                add_1more   <= INIT;
                add_en_sticky   <= INIT;
                end
        endcase
        end
    end

endmodule 
