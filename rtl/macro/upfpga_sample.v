////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : upfpga.v
// Description  : .
//
// Author       : tdhcuong@HW-TDHCUONG
// Created On   : Thu Oct 21 23:11:28 2004
// History (Date, Changed By)
//  Thu Nov 04 20:16:12 2004 ddduc@HW-DDDUC
//  Wed Oct 01 10:28:56 2008 ddduc@HW-DDDUC, fix updo_rpt
//
////////////////////////////////////////////////////////////////////////////////

module upfpga
    (
     clk,
     rst_,
     
     // External CPU Bus
     eupa,       
     eupce_,
     euprnw,
     eupdi,
     eupdo,
     eupack,
     eupint,

     // Internal CPU Bus
     upce_part1_,
     upce_part2_,
     upce_part3_,

     updo_part1,
     updo_part2,
     updo_part3,

     upack_part1,
     upack_part2,
     upack_part3,

     upint_part1,
     upint_part2,
     upint_part3,

     // Error Input
     error0,
     error1,
     error2,
     error3,
     error4,
     error5,
     error6,
     error7,
     error8,
     error9,
     error10,
     error11,
     error12,
     error13,
     error14,
     error15,

     // Control Output
     testmode0,
     testmode1,
     testmode2,
     testmode3,
     testmode4,
     testmode5,
     testmode6,
     testmode7,
          
     inserr0,
     inserr1,
     inserr2,
     inserr3,
     inserr4,
     inserr5,
     inserr6,
     inserr7,
     inserr8,
     inserr9,
     inserr10,
     inserr11,
     inserr12,
     inserr13,
     inserr14,
     inserr15,
     );

////////////////////////////////////////////////////////////////////////////////
// Port declarations
input           clk;
input           rst_;

// External CPU bus
input [23:0]    eupa;       // cpu address       
input           eupce_;     // cpu chip select
input           euprnw;     // cpu read assertion
input   [31:0]  eupdi;      // cpu data in
output  [31:0]  eupdo;      // cpu data out
output          eupack;     // cpu ACK
output          eupint;     // cpu interrupt

// Internal CPU bus
output          upce_part1_;
output          upce_part2_;
output          upce_part3_;

input [31:0]    updo_part1;
input [31:0]    updo_part2;
input [31:0]    updo_part3;

input           upack_part1;
input           upack_part2;
input           upack_part3;

input           upint_part1;
input           upint_part2;
input           upint_part3;

// Error Input
input           error0;
input           error1;
input           error2;
input           error3;
input           error4;
input           error5;
input           error6;
input           error7;
input           error8;
input           error9;
input           error10;
input           error11;
input           error12;
input           error13;
input           error14;
input           error15;

// Control Output
output          testmode0;
output          testmode1;
output          testmode2;
output          testmode3;
output          testmode4;
output          testmode5;
output          testmode6;
output          testmode7;

output          inserr0;
output          inserr1;
output          inserr2;
output          inserr3;
output          inserr4;
output          inserr5;
output          inserr6;
output          inserr7;
output          inserr8;
output          inserr9;
output          inserr10;
output          inserr11;
output          inserr12;
output          inserr13;
output          inserr14;
output          inserr15;


////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

////////////////////////////////////////////////////////////////////////////////
// Parameter declaration
parameter       OFFSET1     = 12'h000,
                OFFSET2     = 12'h0f0,
                OFFSET3     = 12'h100,
                OFFSET_RPT  = 12'hf00;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// Put CPU Decoder here

wire            upen;
wire            upce_part1_;
wire            upce_part2_;
wire            upce_part3_;
wire            upce_rpt_;

assign upce_part1_  = !((!eupce_) & (eupa[23:12] == OFFSET1));
assign upce_part2_  = !((!eupce_) & (eupa[23:12] == OFFSET2));
assign upce_part3_  = !((!eupce_) & (eupa[23:12] == OFFSET3));
assign upce_rpt_    = !((!eupce_) & (eupa[23:12] == OFFSET_RPT));

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// Mux CPU data output

wire [31:0] eupdo;
wire        eupack;
wire        eupint;
wire [31:0] updo_rpt;
wire        upack_rpt;

assign eupdo    = updo_part1 | updo_part2 | updo_part3 | updo_rpt;
assign eupack   = upack_part1 | upack_part2 | upack_part3 | upack_rpt;
assign eupint   = upint_part1 | upint_part2 | upint_part3;

////////////////////////////////////////////////////////////////////////////////
// Count Errors

wire        pen_mode,pen_sticky,pen_frcnt,pen_error;
wire        pen;
assign      pen         = (eupa[13:8] == 6'h3f);
assign      pen_mode    = pen & (eupa[2:0] == 3'd0);
assign      pen_error   = pen & (eupa[2:0] == 3'd1);
assign      pen_sticky  = pen & (eupa[2:0] == 3'd2);

//generate read and write strobes synchronized to sys clock
wire        upws,uprs;
rwsgen rwsgeni
    (
     .clk(clk),
     .rst_(rst_),
     .pce_(upce_rpt_),
     .prnw(euprnw),
     .prs(uprs),
     .pws(upws),
     .scanmode(1'b0)
     );

wire [31:0] updi;
assign      updi = eupdi;

wire [2:0] upa;
assign      upa  = eupa;

wire [7:0] mode;
wire [31:0] rdd_mode;
assign rdd_mode[31:8]   = 24'b0;

pconfigx #(8,8'd0) reg_mode
    (
     .clk(clk),
     .rst_(rst_),
     .upen(pen_mode),
     .upws(upws),
     .updi(updi[7:0]),
     .out(mode),
     .updo(rdd_mode[7:0])
     );

assign      testmode0 = mode[0];
assign      testmode1 = mode[1];
assign      testmode2 = mode[2];
assign      testmode3 = mode[3];
assign      testmode4 = mode[4];
assign      testmode5 = mode[5];
assign      testmode6 = mode[6];
assign      testmode7 = mode[7];

wire [15:0] error_ins;
wire [31:0] rdd_error;
assign rdd_error[31:15] = 16'b0;

pconfigx #(16,16'd0) reg_error
    (
     .clk(clk),
     .rst_(rst_),
     .upen(pen_error),
     .upws(upws),
     .updi(updi[15:0]),
     .out(error_ins),
     .updo(rdd_error[15:0])
     );

assign      inserr0 = error_ins[0];
assign      inserr1 = error_ins[1];
assign      inserr2 = error_ins[2];
assign      inserr3 = error_ins[3];
assign      inserr4 = error_ins[4];
assign      inserr5 = error_ins[5];
assign      inserr6 = error_ins[6];
assign      inserr7 = error_ins[7];
assign      inserr8 = error_ins[8];
assign      inserr9 = error_ins[9];
assign      inserr10 = error_ins[10];
assign      inserr11 = error_ins[11];
assign      inserr12 = error_ins[12];
assign      inserr13 = error_ins[13];
assign      inserr14 = error_ins[14];
assign      inserr15 = error_ins[15];



wire [31:0] rdd_stick;
assign      rdd_stick[31:16] = 16'd0;

stickyx #(16) stickyx
    (
     .clk(clk),
     .rst_(rst_),
     .upactive(1'b1),
     .alarm({error15,error14,error13,error12,error11,error10,error9,error8,
             error7,error6,error5,error4,error3,error2,error1,error0}),
     .upen(pen_sticky),
     .upws(upws),
     .updi(updi[15:0]),
     .updo(rdd_stick[15:0]),
     .lalarm()
     );

////////////////////////////////////////////////////////////////////////////////

wire        prdy_reg;
assign      prdy_reg = (upws | uprs);

wire        uprdy;
assign      uprdy    = prdy_reg;

// Generate cpu ready
rdygen rdygeni
    (
     .rst_(rst_),
     .clk(clk),
     .pce_(eupce_),
     .scanmode(1'b0),
     .rdyin(uprdy),
     .rdyout(upack_rpt)
     );

wire [31:0] updomux;
assign      updomux     = rdd_mode | rdd_error | rdd_stick;
assign      updo_rpt    = updomux;


//always @(posedge clk or negedge rst_)     // --> this logic must be removed
//    begin
//    if(!rst_)           updo_rpt <= 32'd0;
//    else if(upce_rpt_)  updo_rpt <= 32'd0;
//    else if(uprdy)      updo_rpt <= updomux;
//    end


endmodule