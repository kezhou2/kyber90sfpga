////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : montexp.v
// Description  : Montgomery Exponent LSB first with 2 MontPro module
// a^b mod m
// Author       : hungnt@HW-NTHUNG
// Created On   : Mon May 06 15:35:43 2019
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module montexp
    (
     clk,
     rst,
     
     a,//input a
     b,//input b
     expk,//exp 
     exp2k,//exp
     r,//output result
     
     start, //enable
     vld,

     //interface to montprowrap 1
     mpa1,//input a
     mpb1,//input b
     mpr1,//output result
     
     mpstart1, //enable
     mpvld1,

     //interface to montprowrap 2
     mpa2,//input a
     mpb2,//input b
     mpr2,//output result
     
     mpstart2, //enable
     mpvld2
     );
////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

parameter WID = 256;
parameter CNTWID = 8;
parameter CNTVL = 255;
parameter ZERO = 0;

localparam SWID   = 2;
localparam IDLE   = 2'd0;
localparam INIT  = 2'd1;//e = expk
//localparam INITTY = 3'd2;//ty = mp(y,exp2k) wait vld
localparam LOOP   = 2'd2;//e = mp(e,ty) if binary_k(i) = 1 //waitvld if this true
// localparam LOOPTY = 3'd4;//ty = mp(ty,ty)
localparam FINAL = 2'd3;//z = mp(e,1)

////////////////////////////////////////////////////////////////////////////////
// Port declarations
input     clk;
input     rst;

input [WID-1:0] a;
input [WID-1:0] b;
//input [WID-1:0] m;
input [WID-1:0] expk;
input [WID-1:0] exp2k;

output [WID-1:0] r;

input            start;
output           vld;

//interface to montprowrap 1
output [WID-1:0] mpa1;
output [WID-1:0] mpb1;
input [WID-1:0]  mpr1;

output          mpstart1;
input           mpvld1;

//interface to montprowrap 2
output [WID-1:0] mpa2;
output [WID-1:0] mpb2;
input [WID-1:0]  mpr2;

output          mpstart2;
input           mpvld2;

////////////////////////////////////////////////////////////////////////////////
// Output declarations

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation
//counter
reg [CNTWID-1:0] cnt;
//FSM
reg [SWID-1:0]  state;

wire            isidle;

assign          isidle = state == IDLE;

wire            isinit;

assign          isinit = state == INIT;

wire            isinitvld;

assign          isinitvld = isinit & mpvld2;

wire            isloop;

assign          isloop = state == LOOP;

wire            isloopvld1;

assign          isloopvld1 = isloop & mpvld1;

wire            isloopvld2;

assign          isloopvld2 = isloop & mpvld2;

wire            isloopvld;

assign          isloopvld = isloopvld1 & isloopvld2;

wire            loopmax;

assign          loopmax = cnt == 8'd255;

wire            isloopdone;

assign          isloopdone = isloop & loopmax &isloopvld;

wire            isnotloopdone;

assign          isnotloopdone = isloop & !loopmax &isloopvld;

wire            isfinal;

assign          isfinal = state == FINAL;

wire            isfinalvld;

assign          isfinalvld = isfinal & mpvld1;

reg             mpstart1;
reg             mpstart2;

always@(posedge clk)
    begin
    if(rst)
        begin
        state <= IDLE;
        mpstart1 <= 1'b0;
        mpstart2 <= 1'b0;
        end
    else
        begin
        if(isidle & start)
            begin
            state <= INIT;
            mpstart2 <= 1'b1; //ty
            end
        else if(isinitvld)
            begin
            state <= LOOP;
            mpstart1 <= 1'b1;
            mpstart2 <= 1'b1;
            end
        else if(isnotloopdone)
            begin
            state <= LOOP;
            mpstart1 <= 1'b1;
            mpstart2 <= 1'b1;
            end
        else if(isloopdone)
            begin
            state <= FINAL;
            mpstart1 <= 1'b1;//z
            end
        else if(isfinalvld)
            begin
            state <= IDLE;
            end
        else
            begin
            state <= state;
            mpstart1 <= 1'b0;
            mpstart2 <= 1'b0;
            end
        end
    end


//counter
always@(posedge clk)
    begin
    if(rst)
        begin
        cnt <= ZERO;
        end
    else
        begin
        if(isloopvld)
            begin
            cnt <= cnt + 1;
            end
        else if(isinit)
            begin
            cnt <= ZERO;
            end
        else
            begin
            cnt <= cnt;
            end
        end
    end

//register E
reg [WID-1:0] evalue;

always@(posedge clk)
    begin
    if(rst)
        begin
        evalue <= ZERO;
        end
    else
        begin
        if(isinit)
            begin
            evalue <= expk;
            end
        else if(isloopvld1)
            begin
            evalue <= b[cnt]? mpr1 : evalue;
            end
        else
            begin
            evalue <= evalue;
            end
        end
    end

//register TY
reg [WID-1:0] tyvalue;

always@(posedge clk)
    begin
    if(rst)
        begin
        tyvalue <= ZERO;
        end
    else
        begin
        if(isinitvld)
            begin
            tyvalue <= mpr2;
            end
        else if(isloopvld2)
            begin
            tyvalue <= mpr2;
            end
        else
            begin
            tyvalue <= tyvalue;
            end
        end
    end

//montprowrap1 //e z
assign mpa1 = evalue;
assign mpb1 = isfinal? 256'd1 : tyvalue;

//montprowrap2 //ty
assign mpa2 = isinit? a : tyvalue;
assign mpb2 = isinit? exp2k : tyvalue;

//output and vld
reg    vld;
reg [WID-1:0] r;

always@(posedge clk)
    begin
    if(rst)
        begin
        vld <= 1'b0;
        r <= ZERO;
        end
    else
        begin
        if(isfinalvld)
            begin
            r <= mpr1;
            vld <= 1'b1;
            end
        else
            begin
            r <= ZERO;
            vld <= 1'b0;
            end
        end
    end

endmodule 
