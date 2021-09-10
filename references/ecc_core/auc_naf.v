////////////////////////////////////////////////////////////////////////////////
//
// Ho Chi Minh City University of Technology
//
// Filename     : auc_naf.v
// Description  : .
//
// Author       : Vuong Dinh Hung (1511422)
// Created On   : Sun Apr 21 10:44:00 2019
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module auc_naf
    (
     clk,
     rst,
     // Input
     naf_din,
     naf_ranvld,
     naf_shft_en,
     // Output
     naf_shft_rdy,
     naf_shft_vlue,
     naf_shft_last
     );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

parameter           WIDTH   = 256;
parameter           WINDOW  = 4;
parameter           CBIT    = 8;

localparam          SWINDOW = WINDOW -2;
localparam          SH_WID  = (1<<SWINDOW) +1;

localparam          DUPE    = WIDTH - WINDOW;

localparam          INIT    = 0;

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input               clk;
input               rst;

input [WIDTH-1:0]   naf_din;
input               naf_ranvld;
input               naf_shft_en;

output              naf_shft_rdy;
output [SH_WID-1:0] naf_shft_vlue;
output              naf_shft_last;

////////////////////////////////////////////////////////////////////////////////
// Output declarations

reg                 naf_shft_rdy;
wire [SH_WID-1:0]   naf_shft_vlue;

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

reg [WIDTH-1:0]     cnum = 0;
reg [CBIT:0]        lnum = 0;
reg [WINDOW-1:0]    unum = 0;

reg [WIDTH:0]     sign = 0;
reg [WIDTH:0]     num1 = 0;
reg [WIDTH:0]     num3 = 0;
reg [WIDTH:0]     num5 = 0;
reg [WIDTH:0]     num7 = 0;

wire [WINDOW-1:0]   utmp;
assign              utmp = cnum[WINDOW-1:0];
          
wire [WIDTH-1:0]    cnum1;
full_sub
    #(
      .WIDTH(WIDTH)
      ) isub_cnum1
    (
     .a(cnum),
     .b({{DUPE{1'b0}}, utmp}),
     .sub(cnum1),
     .c()
     );
wire [WINDOW-1:0]   n_utmp;
assign              n_utmp = -utmp;

wire [WIDTH-1:0]    cnum2;
wire                carry2;
cla
    #(
      .WID(WIDTH)
      ) isub_cnum2
    (
     .a(cnum),
     .b({{DUPE{1'b0}}, n_utmp}),
     .sum(cnum2),
     .c(carry2)
     );

//================================================

wire [CBIT:0]       lnum_inc;
assign              lnum_inc = lnum + 1'b1;

wire [CBIT:0]       lnum_dec;
assign              lnum_dec = lnum - 1'b1;

wire                cnum_pos;
assign              cnum_pos = (cnum > 0);

wire                cnum_pos_ff;
fflopx #(1) ifflopx (clk, rst, cnum_pos, cnum_pos_ff);

wire                cnum_zero_det;      // detect cnum = 0
assign              cnum_zero_det = cnum_pos_ff & ~cnum_pos;

always @(posedge clk)
     begin
    /*
    if (rst)
        begin
        cnum    <= INIT;
        lnum    <= INIT;
        unum    <= INIT;
        end
     */
    if (naf_ranvld)
        begin
        cnum    <= naf_din;
        lnum    <= INIT;
        unum    <= INIT;
        end
    else if (cnum > 0)
        begin
        if (cnum[0])        // cnum odd
            begin
            if (utmp[WINDOW-1])  
                begin
                unum    <= utmp;
                cnum    <= {carry2, cnum2[WIDTH-1:1]};
                end
            else
                begin
                unum    <= utmp;
                cnum    <= {1'b0, cnum1[WIDTH-1:1]};
                end
            end
        else                // cnum even
            begin
            unum    <= INIT;
            cnum    <= {1'b0, cnum[WIDTH-1:1]};
            end
        lnum    <= lnum_inc;
        end
    // cnum = 0 
    else if (naf_shft_en)
        begin
        cnum    <= cnum;
        lnum    <= lnum_dec;
        unum    <= INIT;
        end
    else
        begin
        cnum    <= cnum;
        lnum    <= lnum;
        unum    <= INIT;
        end
    end

//================================================

reg                 naf_cnv;

always @(posedge clk)
    begin
    if (rst)                naf_cnv <= 1'b0;
    //else if (naf_ranvld)  naf_cnv <= 1'b0;    // not necessary
    else if (cnum > 0)      naf_cnv <= 1'b1;
    else                    naf_cnv <= 1'b0;
    end

//================================================

always @(posedge clk)
    begin
    /*
    if (rst)
        begin
        sign    <= INIT;
        num1    <= INIT;
        num3    <= INIT;
        num5    <= INIT;
        num7    <= INIT;
        end
     */
    if (naf_ranvld)
        begin
        sign    <= INIT;
        num1    <= INIT;
        num3    <= INIT;
        num5    <= INIT;
        num7    <= INIT;
        end
    else if (naf_cnv)
        begin
        case(unum)
            1:
                begin
                sign    <= {1'b0, sign[WIDTH:1]};
                num1    <= {1'b1, num1[WIDTH:1]};
                num3    <= {1'b0, num3[WIDTH:1]};
                num5    <= {1'b0, num5[WIDTH:1]};
                num7    <= {1'b0, num7[WIDTH:1]};
                end
            3:
                begin
                sign    <= {1'b0, sign[WIDTH:1]};
                num1    <= {1'b0, num1[WIDTH:1]};
                num3    <= {1'b1, num3[WIDTH:1]};
                num5    <= {1'b0, num5[WIDTH:1]};
                num7    <= {1'b0, num7[WIDTH:1]};
                end
            5:
                begin
                sign    <= {1'b0, sign[WIDTH:1]};
                num1    <= {1'b0, num1[WIDTH:1]};
                num3    <= {1'b0, num3[WIDTH:1]};
                num5    <= {1'b1, num5[WIDTH:1]};
                num7    <= {1'b0, num7[WIDTH:1]};
                end
            7:
                begin
                sign    <= {1'b0, sign[WIDTH:1]};
                num1    <= {1'b0, num1[WIDTH:1]};
                num3    <= {1'b0, num3[WIDTH:1]};
                num5    <= {1'b0, num5[WIDTH:1]};
                num7    <= {1'b1, num7[WIDTH:1]};
                end
            9:  // -7
                begin
                sign    <= {1'b1, sign[WIDTH:1]};
                num1    <= {1'b0, num1[WIDTH:1]};
                num3    <= {1'b0, num3[WIDTH:1]};
                num5    <= {1'b0, num5[WIDTH:1]};
                num7    <= {1'b1, num7[WIDTH:1]};
                end
            11: // -5
                begin
                sign    <= {1'b1, sign[WIDTH:1]};
                num1    <= {1'b0, num1[WIDTH:1]};
                num3    <= {1'b0, num3[WIDTH:1]};
                num5    <= {1'b1, num5[WIDTH:1]};
                num7    <= {1'b0, num7[WIDTH:1]};
                end
            13: // -3
                begin
                sign    <= {1'b1, sign[WIDTH:1]};
                num1    <= {1'b0, num1[WIDTH:1]};
                num3    <= {1'b1, num3[WIDTH:1]};
                num5    <= {1'b0, num5[WIDTH:1]};
                num7    <= {1'b0, num7[WIDTH:1]};
                end
            15: // -1
                begin
                sign    <= {1'b1, sign[WIDTH:1]};
                num1    <= {1'b1, num1[WIDTH:1]};
                num3    <= {1'b0, num3[WIDTH:1]};
                num5    <= {1'b0, num5[WIDTH:1]};
                num7    <= {1'b0, num7[WIDTH:1]};
                end
            default:
                begin
                sign    <= {1'b0, sign[WIDTH:1]};
                num1    <= {1'b0, num1[WIDTH:1]};
                num3    <= {1'b0, num3[WIDTH:1]};
                num5    <= {1'b0, num5[WIDTH:1]};
                num7    <= {1'b0, num7[WIDTH:1]};
                end
        endcase
        end
    else if (naf_shft_en)
        begin
        sign    <= {sign[WIDTH-1:0], 1'b0};
        num1    <= {num1[WIDTH-1:0], 1'b0};
        num3    <= {num3[WIDTH-1:0], 1'b0};
        num5    <= {num5[WIDTH-1:0], 1'b0};
        num7    <= {num7[WIDTH-1:0], 1'b0};
        end
    else;
    end

//================================================

wire                lnum_pos;
assign              lnum_pos = (lnum > 0);

wire                lnum_pos_ff;
fflopx #(1) ifflopx1 (clk, rst, lnum_pos, lnum_pos_ff);

wire                lnum_zero_det;
assign              lnum_zero_det = lnum_pos_ff & ~lnum_pos;

always @(posedge clk)
    begin
    if (rst)
        begin
        naf_shft_rdy    <= 1'b0;
        end
    else if (cnum_zero_det)
        begin
        naf_shft_rdy    <= 1'b1;
        end
    else if (lnum_zero_det)
        begin
        naf_shft_rdy    <= 1'b0;
        end
    else;
    end

assign              naf_shft_vlue = {
                                     sign[WIDTH],
                                     num1[WIDTH],
                                     num3[WIDTH], 
                                     num5[WIDTH], 
                                     num7[WIDTH]
                                     };

assign              naf_shft_last = lnum == 1;

endmodule 
