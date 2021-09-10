////////////////////////////////////////////////////////////////////////////////
//
// Ho Chi Minh City University of Technology
//
// Filename     : auc_wmul.v
// Description  : .
//
// Author       : Vuong Dinh Hung (1511422)
// Created On   : Tue Apr 23 09:40:58 2019
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module auc_wmul
    (
     clk,
     rst,
     // Input
     wmul_en,
     wmul_naf_vlue,
     wmul_naf_rdy,
     wmul_naf_last,
     wmul_auvld,
     wmul_audat,
     // Output
     wmul_vld,
     wmul_shft_en,
     wmul_opcode,
     wmul_start,
     wmul_const,
     wmul_carry,
     // RAM control
     wmul_radd,
     wmul_rdat,
     wmul_wadd,
     wmul_wen,
     wmul_wdat
     );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

parameter           WIDTH   = 256;
parameter           ADDR    = 5;
parameter           WINDOW  = 4;
parameter           CBIT    = 8;

localparam          INIT    = 0;
localparam          SWINDOW = WINDOW -2;
localparam          SH_WID  = (1<<SWINDOW) +1;

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

// State

localparam          IDLE    = 2'b00;
localparam          PRECOM  = 2'b01;
localparam          DOUBLE  = 2'b10;
localparam          ADD     = 2'b11;

// OPCODE

localparam          OP_FA   = 4'b0000;
localparam          OP_MUL  = 4'b0001;
localparam          OP_INV  = 4'b0010;
     
////////////////////////////////////////////////////////////////////////////////
// Port declarations

input               clk;
input               rst;

input               wmul_en;
input [SH_WID-1:0]  wmul_naf_vlue;
input               wmul_naf_rdy;
input               wmul_naf_last;
input               wmul_auvld;
input [WIDTH-1:0]   wmul_audat;

output              wmul_vld;
output              wmul_shft_en;
output [3:0]        wmul_opcode;
output              wmul_start;
output [WIDTH-1:0]  wmul_const;
output              wmul_carry;

output [ADDR-1:0]   wmul_radd;
input [WIDTH-1:0]   wmul_rdat;
output              wmul_wen;
output [ADDR-1:0]   wmul_wadd;
output [WIDTH-1:0]  wmul_wdat;

////////////////////////////////////////////////////////////////////////////////
// Output declarations

wire                wmul_vld;
wire                wmul_shft_en;
wire [3:0]          wmul_opcode;
wire                wmul_start;
wire [WIDTH-1:0]    wmul_const;
wire                wmul_carry;

wire [ADDR-1:0]     wmul_radd;
wire                wmul_wen;
wire [ADDR-1:0]     wmul_wadd;
wire [WIDTH-1:0]    wmul_wdat;

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

wire                pre_dbl_en;
wire                pre_add_en;
wire [ADDR-1:0]     pre_paddx;
wire [ADDR-1:0]     pre_paddy;
wire [ADDR-1:0]     pre_paddz;
wire                pre_dbl;
wire                pre_ram_1st;
wire                pre_done;
wire [ADDR-1:0]     pre_radd;
wire                pre_wen;
wire [ADDR-1:0]     pre_wadd;
wire [WIDTH-1:0]    pre_wdat;

wire [ADDR-1:0]     adec_paddx;
wire [ADDR-1:0]     adec_paddy;
wire [ADDR-1:0]     adec_paddz;
wire                adec_nplus;

wire                main_dbl_en;
wire                main_add_en;
wire                main_shft;
wire                main_dbl;
wire                main_ram_1st;
wire                main_done;
wire [ADDR-1:0]     main_radd;
wire                main_wen;
wire [ADDR-1:0]     main_wadd;
wire [WIDTH-1:0]    main_wdat;

wire                conv_start;
wire [3:0]          conv_opcode;
wire                conv_done;
wire [ADDR-1:0]     conv_radd;
wire                conv_wen;
wire [ADDR-1:0]     conv_wadd;
wire [WIDTH-1:0]    conv_wdat;

wire [ADDR-1:0]     dbl_radd;
wire                dbl_wen;
wire [ADDR-1:0]     dbl_wadd;
wire [WIDTH-1:0]    dbl_wdat;
wire                dbl_start;
wire [3:0]          dbl_opcode;
wire [WIDTH-1:0]    dbl_const;
wire                dbl_carry;
wire                dbl_end;

wire [ADDR-1:0]     add_radd;
wire                add_wen;
wire [ADDR-1:0]     add_wadd;
wire [WIDTH-1:0]    add_wdat;
wire                add_start;
wire [3:0]          add_opcode;
wire [WIDTH-1:0]    add_const;
wire                add_carry;
wire                add_end;

reg                 pre_sticky;
always @(posedge clk)
    begin
    if (rst)            pre_sticky  <= 1'b0;
    else if (pre_done)  pre_sticky  <= 1'b1;
    else if (main_done) pre_sticky  <= 1'b0;
    end

reg                 main_sticky;
always @(posedge clk)
    begin
    if (rst)            main_sticky <= 1'b0;
    else if (main_done) main_sticky <= 1'b1;
    else if (conv_done) main_sticky <= 1'b0;
    end

//================================================

auc_wmul_pre
    #(
      .WIDTH(WIDTH),
      .ADDR(ADDR)
      ) iauc_wmul_pre
    (
     .clk(clk),
     .rst(rst),
     // Input
     .pre_en(wmul_en),
     .pre_dbl_end(dbl_end),
     .pre_add_end(add_end),
     // Output
     .pre_dbl_en(pre_dbl_en),
     .pre_add_en(pre_add_en),
     .pre_paddx(pre_paddx),
     .pre_paddy(pre_paddy),
     .pre_paddz(pre_paddz),
     //=========
     .pre_dbl(pre_dbl),
     .pre_ram_1st(pre_ram_1st),                             // RAM priority
     .pre_done(pre_done),   
     // RAM control
     .pre_radd(pre_radd),
     .pre_rdat(wmul_rdat),
     .pre_wen(pre_wen),
     .pre_wadd(pre_wadd),
     .pre_wdat(pre_wdat)
     );

//================================================

auc_wmul_decoder
    #(
      .ADDR(ADDR),
      .WINDOW(WINDOW)
      ) iauc_wmul_decoder
    (
     .clk(clk),
     .rst(rst),
     // Input
     .adec_naf_vlue(wmul_naf_vlue[SH_WID-2:0]),             // not include sign
     // Output
     .adec_paddx(adec_paddx),
     .adec_paddy(adec_paddy),
     .adec_paddz(adec_paddz),
     .adec_nplus(adec_nplus)
     );

//================================================

auc_wmul_main
    #(
      .WIDTH(WIDTH),
      .ADDR(ADDR)
      ) iauc_wmul_main
    (
     .clk(clk),
     .rst(rst),
     // Input
     .main_en(pre_done),
     .main_dbl_end(dbl_end),
     .main_add_end(add_end),
     .main_naf_rdy(wmul_naf_rdy),
     .main_naf_last(wmul_naf_last),
     .main_paddx(adec_paddx),
     .main_paddy(adec_paddy),
     .main_paddz(adec_paddz),
     .main_nplus(adec_nplus),
     // Output
     .main_dbl_en(main_dbl_en),
     .main_add_en(main_add_en),     
     .main_shft(main_shft),
     //=========
     .main_dbl(main_dbl),
     .main_ram_1st(main_ram_1st),
     .main_done(main_done),   
     // RAM control
     .main_radd(main_radd),
     .main_rdat(wmul_rdat),
     .main_wen(main_wen),
     .main_wadd(main_wadd),
     .main_wdat(main_wdat)
     );

assign              wmul_shft_en = main_shft;

//================================================

auc_wmul_conv
    #(
      .WIDTH(WIDTH),
      .ADDR(ADDR)
      ) iauc_wmul_conv
    (
     .clk(clk),
     .rst(rst),
     // Input
     .conv_en(main_done),
     .conv_auvld(wmul_auvld),
     .conv_audat(wmul_audat),
     // Output
     .conv_start(conv_start),
     .conv_opcode(conv_opcode),
     .conv_done(conv_done),
     // RAM control
     .conv_radd(conv_radd),
     .conv_wen(conv_wen),
     .conv_wadd(conv_wadd),
     .conv_wdat(conv_wdat)
     );

assign              wmul_vld = conv_done;

//================================================

wire                dbl_en;
assign              dbl_en = pre_sticky? main_dbl_en: pre_dbl_en;

auc_wmul_dbl
    #(
      .WIDTH(WIDTH),
      .ADDR(ADDR)
      ) iauc_wmul_dbl
    (
     .clk(clk),
     .rst(rst),
     // Input
     .dbl_audat(wmul_audat),
     .dbl_auvld(wmul_auvld),
     .dbl_en(dbl_en),
     // Output
     .dbl_start(dbl_start),
     .dbl_opcode(dbl_opcode),
     .dbl_const(dbl_const),
     .dbl_carry(dbl_carry),
     .dbl_end(dbl_end),
     // RAM control
     .dbl_radd(dbl_radd),
     .dbl_wen(dbl_wen),
     .dbl_wadd(dbl_wadd),
     .dbl_wdat(dbl_wdat)
     );

//================================================

wire                add_en;
assign              add_en = pre_sticky? main_add_en: pre_add_en;

wire [ADDR-1:0]     add_paddx;
assign              add_paddx = pre_sticky? adec_paddx: pre_paddx;

wire [ADDR-1:0]     add_paddy;
assign              add_paddy = pre_sticky? adec_paddy: pre_paddy;

wire [ADDR-1:0]     add_paddz;
assign              add_paddz = pre_sticky? adec_paddz: pre_paddz;

auc_wmul_add
    #(
      .WIDTH(WIDTH),
      .ADDR(ADDR)
      ) iauc_wmul_add
    (
     .clk(clk),
     .rst(rst),
     // Input
     .add_audat(wmul_audat),
     .add_auvld(wmul_auvld),
     .add_en(add_en),
     .add_sign(wmul_naf_vlue[SH_WID-1]),
     .add_paddx(add_paddx),
     .add_paddy(add_paddy),
     .add_paddz(add_paddz),
     .add_pre_done(pre_sticky),
     // Output
     .add_start(add_start),
     .add_opcode(add_opcode),
     .add_const(add_const),
     .add_carry(add_carry),
     .add_end(add_end),
     // RAM control
     .add_radd(add_radd),
     .add_wen(add_wen),
     .add_wadd(add_wadd),
     .add_wdat(add_wdat)
     );

//================================================
// MUX to ALU

wire                dbl_active;
assign              dbl_active  = pre_sticky? main_dbl: pre_dbl;

assign              wmul_start  = main_sticky? conv_start:
                    dbl_active? dbl_start: add_start;

assign              wmul_opcode = main_sticky? conv_opcode:
                    dbl_active? dbl_opcode: add_opcode;

assign              wmul_const  = dbl_active? dbl_const: add_const;
assign              wmul_carry  = dbl_active? dbl_carry: add_carry;

//================================================
// MUX to RAM

assign              wmul_radd   = pre_ram_1st? pre_radd:
                    main_ram_1st? main_radd:
                    main_sticky? conv_radd:
                    dbl_active? dbl_radd: add_radd;

assign              wmul_wadd   = pre_ram_1st? pre_wadd:
                    main_ram_1st? main_wadd:
                    main_sticky? conv_wadd:
                    dbl_active? dbl_wadd: add_wadd;

assign              wmul_wdat   = pre_ram_1st? pre_wdat:
                    main_ram_1st? main_wdat:
                    main_sticky? conv_wdat:
                    dbl_active? dbl_wdat: add_wdat;

assign              wmul_wen    = pre_ram_1st? pre_wen:
                    main_ram_1st? main_wen:
                    main_sticky? conv_wen:
                    dbl_active? dbl_wen: add_wen;

endmodule 
