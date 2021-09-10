////////////////////////////////////////////////////////////////////////////////
//
// Ho Chi Minh City University of Technology
//
// Filename     : auc_decoder.v
// Description  : .
//
// Author       : Vuong Dinh Hung (1511422)
// Created On   : Sun Apr 14 21:22:10 2019
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module auc_decoder
    (
     clk,
     rst,
     // Decoder input
     auc_dat,
     auc_start,
     auc_mode,  // Not include curve bit
     // Function enable
     en_rand,
     en_invs,
     en_r,
     en_s,
     en_wmul,   // weierstrass multiplication
     en_mmul,   // montgomery multiplication
     // RAM control
     dec_wen,
     dec_wadd,
     dec_wdat,
     // Inform random valid
     dec_rannum,
     dec_ranvld
     );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

parameter           WIDTH   = 256;
parameter           ADDR    = 5;

localparam          RAND    = 3'b000;
localparam          INVS    = 3'b001;
localparam          R       = 3'b010;
localparam          S       = 3'b011;
localparam          WMUL    = 3'b100;
localparam          MMUL    = 3'b101;

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
localparam          ZRRAM   = 18;   
localparam          ONERAM  = 19;   

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

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input               clk;
input               rst;

input [WIDTH-1:0]   auc_dat;
input               auc_start;
input [2:0]         auc_mode;

output              en_rand;
output              en_invs;
output              en_r;
output              en_s;
output              en_wmul;
output              en_mmul;

output              dec_wen;
output [ADDR-1:0]   dec_wadd;
output [WIDTH-1:0]  dec_wdat;

output [WIDTH-1:0]  dec_rannum;
output              dec_ranvld;

////////////////////////////////////////////////////////////////////////////////
// Output  declarations

reg                 en_rand;
reg                 en_invs;
reg                 en_r;
reg                 en_s;
reg                 en_wmul;
reg                 en_mmul;

wire                dec_wen;
reg [ADDR-1:0]      dec_wadd;
wire [WIDTH-1:0]    dec_wdat;

reg [WIDTH-1:0]     dec_rannum;
reg                 dec_ranvld;

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

wire                auc_start_1;
wire                auc_start_2;
fflopx #(2) ifflopx (clk, rst, {auc_start,auc_start_1}, {auc_start_1,auc_start_2});

wire                neg_start;
assign              neg_start = auc_start_2 & ~auc_start_1;

always @(*)
    begin
    en_rand <= neg_start && (auc_mode == RAND);
    en_invs <= neg_start && (auc_mode == INVS);
    en_r    <= neg_start && (auc_mode == R);
    en_s    <= neg_start && (auc_mode == S);
    en_wmul <= neg_start && (auc_mode == WMUL);
    en_mmul <= neg_start && (auc_mode == MMUL);
    end

//================================================

reg [2:0]           dec_cnt;

wire [2:0]          dec_sum;
assign              dec_sum = dec_cnt + 2'd1;

always @(posedge clk)
    begin
    if (rst)                dec_cnt <= 3'b000;
    else if (auc_start)     dec_cnt <= dec_sum;
    else                    dec_cnt <= 3'b000;
    end

//================================================

fflopx #(WIDTH) ifflopx1 (clk, rst, auc_dat, dec_wdat);

assign              dec_wen = auc_start_1;

wire                dec_rx1;
assign              dec_rx1 = dec_cnt == 3'b000;

wire                dec_rx2;
assign              dec_rx2 = dec_cnt == 3'b001;

wire                dec_rx3;
assign              dec_rx3 = dec_cnt == 3'b010;

wire                dec_rx4;
assign              dec_rx4 = dec_cnt == 3'b011;

wire                dec_rx5;
assign              dec_rx5 = dec_cnt == 3'b100;

always @(posedge clk)
    begin
    if (rst)
        begin
        dec_wadd    <= BLNK;
        end
    else if (auc_start)
        begin
        case(auc_mode)
            RAND:       dec_wadd    <= BLNK;
            INVS:       dec_wadd    <= BLNK;
            R:          dec_wadd    <= BLNK;
            S:
                begin
                if (dec_rx1)        dec_wadd    <= HASH;
                else if (dec_rx2)   dec_wadd    <= PKEY;
                else                dec_wadd    <= BLNK;
                end
            WMUL:
                begin
                if (dec_rx1)        dec_wadd    <= ZRRAM;
                else if (dec_rx2)   dec_wadd    <= ONERAM;
                else if (dec_rx3)   dec_wadd    <= X_G;
                else if (dec_rx4)   dec_wadd    <= Y_G;
                else if (dec_rx5)   dec_wadd    <= K_NUM;
                else                dec_wadd    <= BLNK;
                end
            MMUL:
                begin
                if (dec_rx1)        dec_wadd    <= ZRRAM;
                else if (dec_rx2)   dec_wadd    <= ONERAM;
                else if (dec_rx3)   dec_wadd    <= X_G;
                else if (dec_rx4)   dec_wadd    <= K_NUM;
                else                dec_wadd    <= BLNK;
                end
            default:    dec_wadd    <= BLNK;
        endcase
        end
    else
        begin
        dec_wadd    <= BLNK;
        end
    end

//================================================

always @(posedge clk)
    begin
    if (rst)
        begin
        dec_rannum  <= INIT;
        dec_ranvld  <= 1'b0;
        end
    else if (auc_start)
        begin
        case(auc_mode[2:0])
            WMUL:
                if (dec_rx5)
                    begin
                    dec_rannum  <= auc_dat;
                    dec_ranvld  <= 1'b1;
                    end
                else
                    begin
                    dec_rannum  <= dec_rannum;
                    dec_ranvld  <= 1'b0;
                    end
            MMUL:
                if (dec_rx4)
                    begin
                    dec_rannum  <= auc_dat;
                    dec_ranvld  <= 1'b1;
                    end
                else
                    begin
                    dec_rannum  <= dec_rannum;
                    dec_ranvld  <= 1'b0;
                    end
            default:
                begin
                dec_rannum  <= dec_rannum;
                dec_ranvld  <= 1'b0;
                end
        endcase
        end
    end

endmodule 
