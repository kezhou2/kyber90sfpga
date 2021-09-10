////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : aluwrap.v
// Description  : design of FSM control
//
// Author       : PC@DESKTOP-9FI2JF9
// Created On   : Sun Mar 17 21:17:30 2019
// History (Date, Changed By)
//
////update RNVL X255 P256 correct
//
////////////////////////////////////////////////////////////////////////////////

module aluwrap
    (
     clk,
     rst,

     status,//00 01 10 11 idle computing done error

     a,//INV only input
     b,
     c, //cin for FA
     en,//start ops
     swapop, //priority for swapoperation
     swapvl, //swap value
     opcode, //[1:0]00 01 10 11 fa mul inv exp 
     //[2] 1 X255 0 P256
     //[3] 1 N 0 P

     r,//result //swap a
     rswap,//second result from swap //swap b
     vld
     );
////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

parameter WID  = 256;
parameter IDLE = 3'b000;
parameter FA   = 3'b001;
parameter INV  = 3'b010;
parameter MUL  = 3'b011;
parameter NOR  = 3'b100;//normalization
parameter EXP  = 3'b101;
parameter SWAP = 3'b110;
parameter MVALP256 = 256'd115792089210356248762697446949407573530086143415290314195533631308867097853951;
parameter RPVLP256 = 256'd134799733323198995502561713907086292154532538166959272814710328655875;
parameter RNVLP256 = 256'd46533765739406314298121036767150998762426774378559716911348521029833835802274;
parameter NVALP256 = 256'd115792089210356248762697446949407573529996955224135760342422259061068512044369;
parameter MVALX255 = 256'd57896044618658097711785492504343953926634992332820282019728792003956564819949;
parameter RPVLX255 = 256'd1444;
parameter RNVLX255 = 256'd1627715501170711445284395025044413883736156588369414752970002579683115011841;
parameter NVALX255 = 256'd7237005577332262213973186563042994240857116359379907606001950938285454250989;

parameter P256EXPK  = 256'd26959946660873538059280334323183841250350249843923952699046031785985;
parameter P256EXP2K = 256'd134799733323198995502561713907086292154532538166959272814710328655875;
parameter X255EXPK  = 256'd38;
parameter X255EXP2K = 256'd1444;

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input clk;
input rst;

output [1:0] status;

input [WID-1:0] a;
input [WID-1:0] b;
input           c;
input           swapop;
input           swapvl;
input           en;
input [3:0] opcode;
                
output [WID-1:0] r;
output [WID-1:0] rswap;
output           vld;

////////////////////////////////////////////////////////////////////////////////
// Output declarations

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation
//declarement fix

reg [WID-1:0]    tempnor;
reg [2:0]        state;
wire             isidle,isinv,ismul,isfa,isnor,isswap;
//,isexp;

wire             enidle;

assign           enidle = isidle & en;

//elliptic logic
/*
wire [WID-1:0]   mecc;

assign           mecc = (opcode[3:2] == 2'b00)? MVALP256 :
                 (opcode[3:2] == 2'b01)? MVALX255 :
                 (opcode[3:2] == 2'b10)? NVALP256 :
                 NVALX255;
                            
wire [WID-1:0]   recc;

assign           recc = (opcode[1:0] == INV)? 256'd1 :
                 opcode[2]? RPVLX255 : RPVL256;
*/

reg [WID-1:0]   mecc;
always@(posedge clk)
    begin
    if(enidle)
        mecc <= (opcode[3:2] == 2'b00)? MVALP256 :
                (opcode[3:2] == 2'b01)? MVALX255 :
                (opcode[3:2] == 2'b10)? NVALP256 :
                NVALX255;
    end

reg [WID-1:0] recc;

always@(posedge clk)
    begin
    if(enidle)
        recc <= (opcode[1:0] == INV)? 256'd1 :
                (opcode[3:2] == 2'b00)? RPVLP256 :
                (opcode[3:2] == 2'b01)? RPVLX255 :
                (opcode[3:2] == 2'b10)? RNVLP256 :
                RNVLX255;
                //opcode[2]? RPVLX255 : RPVLP256;
    end
/*
reg [WID-1:0] expk;

always@(posedge clk)
    begin
    if(enidle)
        expk <= opcode[2]? X255EXPK : P256EXPK;
    end

reg [WID-1:0] exp2k;

always@(posedge clk)
    begin
    if(enidle)
        exp2k <= opcode[2]? X255EXP2K : P256EXP2K;
    end
*/
//can than code kieu nay opcode k dc thay doi trong qua trinh chay //old
//da sua bay gio chi cap nhat opcode khi en pulse bat, vui long khong bat en
//pulse neu chua chay xong (chua vld) //old
//da sua bay gio khong quan tam en khi dang chay
//////////////////////////
//another fix on a, b chaning after en, a b should only be update when en is there
reg [WID-1:0] areg;
reg [WID-1:0] breg;

always@(posedge clk)
    begin
    if(rst)
        begin
        areg <= 256'd0;
        end
    else
        begin
        if(enidle)
            begin
            areg <= a;
            end
        end
    end

always@(posedge clk)
    begin
    if(rst)
        begin
        breg <= 256'd0;
        end
    else
        begin
        if(enidle)
            begin
            breg <= b;
            end
        end
    end

/////////////////////////
//wiring instant
//wire           faen;
wire [WID-1:0]   fars;
wire             favld;

//wire           proen;
wire [WID-1:0]   prors;
wire             provld;
wire [WID-1:0]   proa;
wire [WID-1:0]   prob;
//wire             proenwexp;

//wire           inven;
wire [WID-1:0]   invrs;
wire             invvld;

//wire
wire [WID-1:0]   swaprsa;
wire [WID-1:0]   swaprsb;
wire             swapvld;

//wire
//wire [WID-1:0]   exprs;
//wire             expvld;
/*
wire [WID-1:0]   mpa;
wire [WID-1:0]   mpb;
wire [WID-1:0]   mprs;
wire             mpvld;
wire             mpen;

wire [WID-1:0]   mpa2;
wire [WID-1:0]   mpb2;
wire [WID-1:0]   mprs2;
wire             mpvld2;
wire             mpen2;
*/
//reg instant
reg              faen;
reg              proen;
reg              inven;
//reg              expen;
reg              swapen;

assign           mprs = prors;
assign           mpvld = provld;

//input for montpro

assign           proa = //isexp? mpa :
                 isnor? tempnor : areg;
assign           prob = //isexp? mpb :
                 isnor? recc : breg;

//assign           proenwexp = isexp? mpen : proen;

//en for module is on register FSM

//spare logic

assign           isidle = state == IDLE;
assign           isinv = state == INV;
assign           ismul = state == MUL;
assign           isfa = state == FA;
assign           isnor = state == NOR;
assign           isswap = state == SWAP;
//assign           isexp = state == EXP;

wire             isfavld;
wire             isnorvld;
wire             isswapvld;
//wire             isexpvld;

assign           isfavld = (isfa & favld);
assign           isnorvld = (isnor & provld);
assign           isswapvld = (isswap & swapvld);
//assign           isexpvld = (isexp & expvld);

//Nor condition
wire             norcond;

assign           norcond = (ismul & provld) | (isinv & invvld);

//vld logic

assign           vld = isfavld | isnorvld | isswapvld; //| isexpvld;

//status report
assign status = isidle? 2'b00 :
       vld? 2'b10 : 2'b01;

//outputlogic
assign r = isfavld? fars :
       isswapvld? swaprsa:
       //isexpvld? exprs   :
       prors; // opted

assign rswap = swaprsb;
//FSM
always@(posedge clk)
    begin
    if(rst)
        begin
        state <= IDLE;
        tempnor <= 0;
        faen <= 1'b0;
        proen <= 1'b0;
        inven <= 1'b0;
        //expen <= 1'b0;
        swapen <= 1'b0;
        end
    else
        begin
        if(enidle)
            begin
            if(swapop)
                begin
                state <= SWAP;
                swapen <= 1'b1;
                end
            else
                begin
                case(opcode[1:0])
                    2'b00:
                        begin
                        state <= FA;
                        faen <= 1'b1;
                        end
                    2'b01:
                        begin
                        state <= MUL;
                        proen <= 1'b1;
                        end
                    2'b10:
                        begin
                        state <= INV;
                        inven <= 1'b1;
                        end
                    //2'b11:
                      //  begin
                      //  state <= EXP;
                      //  expen <= 1'b1;
                      //  end
                    default:
                        begin
                        state <= IDLE;
                        end
                endcase
                end
            end
        else if(norcond)
            begin
            tempnor <= provld? prors : invrs;
            state <= NOR;
            proen <= 1'b1;
            end
        else if(isfavld)
            begin
            state <= IDLE;
            end
        else if(isnorvld)
            begin
            state <= IDLE;
            end
        //else if(isexpvld)
           // begin
           // state <= IDLE;
           // end
        else if(isswapvld)
            begin
            state <= IDLE;
            end
        else
            begin
            state <= state;
            faen <= 1'b0;
            proen <= 1'b0;
            inven <= 1'b0;
            //expen <= 1'b0;
            swapen <= 1'b0;
            end
        end
    end
            
//FA Module
modfa imodfa
    (
     .clk(clk),
     .rst(rst),
     .op1(areg),
     .op2(breg),
     .mod(mecc),//
     .cin(c),
     .en(faen),
     .sum(fars),
     .vld(favld)
     );
//MUL/NOR Module

montprowrap imontprowrap
    (
     .clk(clk),
     .rst(rst),
     
     .a(proa),//input a
     .b(prob),//input b
     .m(mecc),
     .r(prors),//output result
     
     .start(proen), //status report
     .vld(provld)
     );

//INV Module
montinv imontinv
    (
     .clk(clk),
     .rst(rst),
     .din(areg),
     .mod(mecc),//
     .en(inven),
     .inv(invrs),
     .vld(invvld)
     );

//cswap module
cswap icswap
    (
     .clk(clk),
     .rst(rst),

     .swap(swapvl),
     .a(areg),
     .b(breg),
     .en(swapen),

     .aswap(swaprsa),
     .bswap(swaprsb),
     .vld(swapvld)
     );
/*
//exponent module
montexp imontexp
    (
     .clk(clk),
     .rst(rst),
     
     .a(areg),//input a
     .b(breg),//input b
     .expk(expk),//exp 
     .exp2k(exp2k),//exp
     .r(exprs),//output result
     
     .start(expen), //enable
     .vld(expvld),

     //interface to montprowrap 1
     .mpa1(mpa),//output a
     .mpb1(mpb),//output b
     .mpr1(mprs),//input result
     
     .mpstart1(mpen), //enable
     .mpvld1(mpvld),

     //interface to montprowrap 2
     .mpa2(mpa2),//output a
     .mpb2(mpb2),//output b
     .mpr2(mprs2),//input result
     
     .mpstart2(mpen2), //enable
     .mpvld2(mpvld2)
     );

montprowrap imontprowrap2
    (
     .clk(clk),
     .rst(rst),
     
     .a(mpa2),//input a
     .b(mpb2),//input b
     .m(mecc),
     .r(mprs2),//output result
     
     .start(mpen2), //status report
     .vld(mpvld2)
     );
*/
endmodule 
