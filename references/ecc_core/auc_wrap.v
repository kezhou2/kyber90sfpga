////////////////////////////////////////////////////////////////////////////////
//
// Ho Chi Minh City University of Technology
//
// Filename     : auc_wrap
// Description  : .
//
// Author       : Vuong Dinh Hung (1511422)
// Created On   : Thu May 02 13:59:17 2019
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module auc_wrap
    (
     clk,
     rst,
     // Main control - AUC
     auc_dat,
     auc_start,
     auc_mode,
     auc_rslt,
     auc_status,
     // AUC - AU
     au_dat1,
     au_dat2,
     au_carry,
     au_start,
     au_opcode,
     au_swapop,
     au_swapvl,
     au_rslt,
     au_rswap,
     au_vld,
     // Simulation random number
     test_num
     );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

parameter           WIDTH   = 256;
parameter           ADDR    = 5;
parameter           WINDOW  = 4;
parameter           CBIT    = 8;
parameter           DEPTH   = 1<<ADDR;

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
localparam          TEMP8   = 28;

localparam          S_RP    = 29;
localparam          S_RPH   = 30;
localparam          BLNK    = 31;

localparam          RAND    = 3'b000;
localparam          INVS    = 3'b001;
localparam          R       = 3'b010;
localparam          S       = 3'b011;
localparam          WMUL    = 3'b100;
localparam          MMUL    = 3'b101;

// status

localparam          IDLE    = 2'b00;
localparam          CAL     = 2'b01;
localparam          DONE    = 2'b10;
localparam          ERROR   = 2'b11;

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input               clk;
input               rst;

input [WIDTH-1:0]   auc_dat;
input [3:0]         auc_mode;           // MSB indicates EC
input               auc_start;
output [WIDTH-1:0]  auc_rslt;
output [1:0]        auc_status;

output [WIDTH-1:0]  au_dat1;
output [WIDTH-1:0]  au_dat2;
output              au_carry;
output              au_start;
output [3:0]        au_opcode;
output              au_swapop;
output              au_swapvl;
input [WIDTH-1:0]   au_rslt;
input [WIDTH-1:0]   au_rswap;
input               au_vld;

input [WIDTH-1:0]   test_num;

////////////////////////////////////////////////////////////////////////////////
// Output declarations

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

//================================================
// Enable signal decoder

wire                en_rand;
wire                en_invs;
wire                en_r;
wire                en_s;
wire                en_wmul;
wire                en_mmul;

wire                dec_wen;
wire [ADDR-1:0]     dec_wadd;
wire [WIDTH-1:0]    dec_wdat;

wire [WIDTH-1:0]    dec_rannum;
wire                dec_ranvld;

auc_decoder
    #(
      .WIDTH(WIDTH),
      .ADDR(ADDR)
      ) iauc_decoder
    (
     .clk(clk),
     .rst(rst),
     // Decoder input
     .auc_dat(auc_dat),
     .auc_start(auc_start),
     .auc_mode(auc_mode[2:0]),          // Not include curve bit
     // Function enable
     .en_rand(en_rand),
     .en_invs(en_invs),
     .en_r(en_r),
     .en_s(en_s),
     .en_wmul(en_wmul),                 // weierstrass multiplication
     .en_mmul(en_mmul),                 // montgomery multiplication
     // RAM control
     .dec_wen(dec_wen),
     .dec_wadd(dec_wadd),
     .dec_wdat(dec_wdat),
     // Inform random valid
     .dec_rannum(dec_rannum),           // to NAF
     .dec_ranvld(dec_ranvld)
     );

//================================================
// Random

wire                rand_vld;
wire                rand_wen;
wire [ADDR-1:0]     rand_wadd;
wire [WIDTH-1:0]    rand_wdat;

auc_rand_wrap
    #(
      .WIDTH(WIDTH),
      .ADDR(ADDR)
      ) iauc_rand_wrap
    (
     .clk(clk),
     .rst(rst),
     // Input
     .rand_en(en_rand),
     .rand_tnum(test_num),              // simulation only
     .rand_curve(auc_mode[3]),          // define elliptic curve random limit
     // Output
     .rand_vld(rand_vld),
     //RAM control
     .rand_wen(rand_wen),
     .rand_wadd(rand_wadd),
     .rand_wdat(rand_wdat)
     );

//================================================
// NAF

wire                naf_shft_rdy;
wire [SH_WID-1:0]   naf_shft_vlue;
wire                naf_shft_last;

wire [WIDTH-1:0]    naf_din;
assign              naf_din     = (auc_mode[2:0] == RAND)? rand_wdat: dec_rannum;

wire                naf_ranvld;
assign              naf_ranvld  = (auc_mode[2:0] == RAND)? rand_vld: dec_ranvld;

wire                naf_shft_en;

auc_naf
    #(
      .WIDTH(WIDTH),
      .WINDOW(WINDOW),
      .CBIT(CBIT)
      ) iauc_naf
    (
     .clk(clk),
     .rst(rst),
     // Input
     .naf_din(naf_din),
     .naf_ranvld(naf_ranvld),
     .naf_shft_en(naf_shft_en),
     // Output
     .naf_shft_rdy(naf_shft_rdy),
     .naf_shft_vlue(naf_shft_vlue),
     .naf_shft_last(naf_shft_last)
     );

//================================================
// Weiertrass multiplication

wire                wmul_vld;
wire                wmul_shft_en;
wire [3:0]          wmul_opcode;
wire                wmul_start;
wire [WIDTH-1:0]    wmul_const;
wire                wmul_carry;
wire                wmul_comp2;

wire [ADDR-1:0]     wmul_radd;
wire [WIDTH-1:0]    wmul_rdat;
wire                wmul_wen;
wire [ADDR-1:0]     wmul_wadd;
wire [WIDTH-1:0]    wmul_wdat;

assign              naf_shft_en = wmul_shft_en;

auc_wmul
    #(
      .WIDTH(WIDTH),
      .ADDR(ADDR),
      .WINDOW(WINDOW),
      .CBIT(CBIT)
      ) iauc_wmul
    (
     .clk(clk),
     .rst(rst),
     // Input
     .wmul_en(en_wmul),
     .wmul_naf_vlue(naf_shft_vlue[SH_WID-1:0]),
     .wmul_naf_rdy(naf_shft_rdy),
     .wmul_naf_last(naf_shft_last),
     .wmul_auvld(au_vld),
     .wmul_audat(au_rslt),
     // Output
     .wmul_vld(wmul_vld),
     .wmul_shft_en(wmul_shft_en),
     .wmul_opcode(wmul_opcode),
     .wmul_start(wmul_start),
     .wmul_const(wmul_const),
     .wmul_carry(wmul_carry),
     // RAM control
     .wmul_radd(wmul_radd),
     .wmul_rdat(wmul_rdat),
     .wmul_wadd(wmul_wadd),
     .wmul_wen(wmul_wen),
     .wmul_wdat(wmul_wdat)
     );

//================================================
// Montgomery multiplication

wire                mmul_vld;           //done
wire [3:0]          mmul_opcode;
wire                mmul_start;
wire                mmul_carry;         //for sub
wire                mmul_swapop;
wire                mmul_swapvl;

wire [ADDR-1:0]     mmul_radd;
wire [ADDR-1:0]     mmul_wadd;
wire                mmul_wen;
wire [WIDTH-1:0]    mmul_wdat;

auc_mmul
    #(
      .WID(WIDTH),
      .AWID(ADDR)
      ) iauc_mmul
    (
     .clk(clk),
     .rst(rst),
     // Input
     .mmul_en(en_mmul),                 //controller
     //from ALU
     .mmul_auvld(au_vld),
     .mmul_audat(au_rslt),
     .mmul_aurswap(au_rswap),
     // Output
     .mmul_done(mmul_vld),      //done
     //to ALU
     .mmul_opcode(mmul_opcode),
     .mmul_auen(mmul_start),
     .mmul_carry(mmul_carry),
     .mmul_swapop(mmul_swapop),
     .mmul_swapvl(mmul_swapvl),
     // RAM control
     .mmul_ra(mmul_radd),
     .mmul_wa(mmul_wadd),
     .mmul_we(mmul_wen),
     .mmul_wd(mmul_wdat)
     );

//================================================
// r, s nad inversion

wire [ADDR-1:0]     rsi_radd;
wire [WIDTH-1:0]    rsi_wdat;
wire                rsi_wen;
wire [ADDR-1:0]     rsi_wadd;
wire                rsi_vld;
wire                rsi_start;
wire [3:0]          rsi_opcode;
wire [1:0]          aop;

assign              rsi_opcode  = {1'b1, auc_mode[3], aop};

rsinv
    #(
      .WID(WIDTH),
      .AWID(ADDR)
      ) irsinv
    (
     .clk(clk),
     .rst(rst),

     .ramra(rsi_radd),                  //to RAM to get a b to alu
     .ramwd(rsi_wdat),                  //to write new value to ram
     .ramwa(rsi_wadd),
     .ramwe(rsi_wen),
     
     //start operation //to ALU ctrl
     .acen_i(en_invs),                  //pulse
     .acen_r(en_r),                     //pulse
     .acen_s(en_s),                     //pulse
     .rsidone(rsi_vld),                 //pulse

     .aen(rsi_start),                   //to ALU
     .aop(aop),                         //2 bit FA MUL INV
     .adi(au_rslt),
     .adivld(au_vld)
     );

wire                rsi_start_ff;
fflopx #(1) irsi_start (clk, rst, rsi_start, rsi_start_ff);

//================================================
// RAM 3clk

wire [WIDTH-1:0]    ram_rdat;
assign              wmul_rdat   = ram_rdat;

reg [ADDR-1:0]      ram_radd;
reg [WIDTH-1:0]     ram_wdat;
reg [ADDR-1:0]      ram_wadd;
reg                 ram_wen;

alram113x
    #(
      .WID(WIDTH),
      .AWID(ADDR),
      .DEP(DEPTH)
      ) ialram113x
    (
     .clkw(clk),                        //clock write
     .clkr(clk),                        //clock read
     .rst(rst),
     
     .rdo(ram_rdat),                    //data from ram
     .ra(ram_radd),                     //read address
     
     .wdi(ram_wdat),                    //data to ram
     .wa(ram_wadd),                     //write address
     .we(ram_wen)                       //write enable
     );

always @(*)
    begin
    case(auc_mode[2:0])
        INVS:   ram_radd    <= rsi_radd;
        R:      ram_radd    <= rsi_radd;
        S:      ram_radd    <= rsi_radd;
        WMUL:   ram_radd    <= wmul_radd;
        MMUL:   ram_radd    <= mmul_radd;
        default:ram_radd    <= rsi_radd;
    endcase
    end

wire                auc_start_ff;
ffxkclkx #(1,1) iffxkclkx (clk, rst, auc_start, auc_start_ff);

wire                mux_ctrl;
assign              mux_ctrl = auc_start | auc_start_ff;                // Decoder in charge

always @(*)
    begin
    case(auc_mode[2:0])
        RAND:   ram_wen <= rand_wen;    // No data in 
        INVS:   ram_wen <= rsi_wen;     // No data in 
        R:      ram_wen <= rsi_wen;     // No data in
        S:      ram_wen <= mux_ctrl? dec_wen: rsi_wen;
        WMUL:   ram_wen <= mux_ctrl? dec_wen: wmul_wen;
        MMUL:   ram_wen <= mux_ctrl? dec_wen: mmul_wen;
        default:ram_wen <= rsi_wen;
    endcase
    end

always @(*)
    begin
    case(auc_mode[2:0])
        RAND:   ram_wadd    <= rand_wadd;
        INVS:   ram_wadd    <= rsi_wadd;
        R:      ram_wadd    <= rsi_wadd;
        S:      ram_wadd    <= mux_ctrl? dec_wadd: rsi_wadd;
        WMUL:   ram_wadd    <= mux_ctrl? dec_wadd: wmul_wadd;
        MMUL:   ram_wadd    <= mux_ctrl? dec_wadd: mmul_wadd;
        default:ram_wadd    <= rsi_wadd;
    endcase
    end

always @(*)
    begin
    case(auc_mode[2:0])
        RAND:   ram_wdat    <= rand_wdat;
        INVS:   ram_wdat    <= rsi_wdat;
        R:      ram_wdat    <= rsi_wdat;
        S:      ram_wdat    <= mux_ctrl? dec_wdat: rsi_wdat;
        WMUL:   ram_wdat    <= mux_ctrl? dec_wdat: wmul_wdat;
        MMUL:   ram_wdat    <= mux_ctrl? dec_wdat: mmul_wdat;
        default:ram_wdat    <= rsi_wdat;
    endcase
    end

//================================================
// MUX to ALU

assign              au_dat1     = ram_rdat;

wire [WIDTH-1:0]    au_dat2_mux;
assign              au_dat2_mux = (wmul_const == INIT)? ram_rdat: wmul_const;

ffxkclkx #(1,WIDTH) iau_dat2 (clk, rst, au_dat2_mux, au_dat2);
                   
assign              au_carry    = (auc_mode[2:0] == WMUL)? wmul_carry:
                    (auc_mode[2:0] == MMUL)? mmul_carry: 1'b0;

assign              au_opcode   = (auc_mode[2:0] == WMUL)? wmul_opcode: 
                    (auc_mode[2:0] == MMUL)? mmul_opcode: rsi_opcode;

wire                mmul_start_ff;
fflopx #(1) immul_start (clk, rst, mmul_start, mmul_start_ff);

wire                au_start_mux;
assign              au_start_mux = (auc_mode[2:0] == WMUL)? wmul_start: 
                    (auc_mode[2:0] == MMUL)? mmul_start_ff: rsi_start_ff;

ffxkclkx #(3,1) iau_start (clk, rst, au_start_mux, au_start);

assign              au_swapop = mmul_swapop;
assign              au_swapvl = mmul_swapvl;

//================================================
// 

reg                 auc_vld_mux;
always @(*)
    begin
    case(auc_mode[2:0])
        RAND:   auc_vld_mux <= rand_vld;
        INVS:   auc_vld_mux <= rsi_vld;
        R:      auc_vld_mux <= rsi_vld;
        S:      auc_vld_mux <= rsi_vld;
        WMUL:   auc_vld_mux <= wmul_vld;
        MMUL:   auc_vld_mux <= mmul_vld;
        default:auc_vld_mux <= rsi_vld;
    endcase
    end

reg [WIDTH-1:0]     auc_rslt;
reg [1:0]           auc_status;

always @(posedge clk)
    begin
    if (rst)
        begin
        auc_rslt    <= INIT;
        end
    else if (auc_vld_mux)
        begin
        auc_rslt    <= ram_wdat;
        end
    end

always @(posedge clk)
    begin
    if (rst)
        begin
        auc_status  <= IDLE;
        end
    else if (auc_vld_mux)
        begin
        case(auc_mode[2:0])
             RAND:      auc_status  <= DONE;
             INVS:      auc_status  <= DONE;
             R:         auc_status  <= (ram_wdat == INIT)? ERROR: DONE;
             S:         auc_status  <= (ram_wdat == INIT)? ERROR: DONE;
             WMUL:      auc_status  <= DONE;
             MMUL:      auc_status  <= DONE;
             default:   auc_status  <= IDLE;
        endcase
        end
    else
        begin
        auc_status  <= IDLE;
        end
    end

endmodule 
