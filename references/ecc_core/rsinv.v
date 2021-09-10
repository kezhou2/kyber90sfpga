////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : rsinv.v
// Description  : .
//
// Author       : PC@DESKTOP-9FI2JF9
// Created On   : Sat Apr 20 00:27:24 2019
// History (Date, Changed By)
// // dont need to check value valid
////////////////////////////////////////////////////////////////////////////////

module rsinv
    (
     clk,
     rst,

     ramra, //to RAM to get a b to alu
     ramwd,//to write new value to ram
     ramwa,
     ramwe,
     
     //start operation //to ALU ctrl
     acen_i,//pulse
     acen_r,//pulse
     acen_s,//pulse
     rsidone, //pulse

     aen,//to ALU
     aop,//2 bit FA MUL INV
     adi,
     adivld
     );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

parameter WID = 256;
parameter AWID = 5;

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
localparam          PRKEY   = 17; // private key
localparam          ZRRAM   = 18; // slot contain 0
localparam          ONERAM  = 19; // slot contain 1

localparam          S_RP    = 29;
localparam          S_RPH   = 30;
localparam          BLNK    = 31; // blank slot

localparam FA  = 2'b00;
localparam MUL = 2'b01;
localparam INV = 2'b10;

localparam IDLE = 2'b00;
localparam RPRO = 2'b01;
localparam SPRO = 2'b10;
localparam IPRO = 2'b11;

localparam RIDLE = 2'b00;//for R state
localparam RCAL1 = 2'b01; //load x1
localparam RCAL2 = 2'b10; //load 0 and wait cal

localparam SIDLE  = 3'b000;//for S state
localparam SRP1   = 3'b001; //load r
localparam SRP2   = 3'b010; //load p and wait cal
localparam SRPH1  = 3'b011; //load rp
localparam SRPH2  = 3'b100; //load h and wait cal
localparam SRPHK1 = 3'b101; //load rph
localparam SRPHK2 = 3'b110; //load k and wait cal

localparam IIDLE = 1'b0;//for I state
localparam ICAL = 1'b1; //load k and wait cal

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input clk;
input rst;

output [AWID-1:0] ramra;
output [WID-1:0]  ramwd;
output [AWID-1:0] ramwa;
output            ramwe;

input             acen_i;
input             acen_r;
input             acen_s;
output            rsidone;

output            aen;
output [1:0]      aop;
input [WID-1:0]   adi;
input             adivld;

////////////////////////////////////////////////////////////////////////////////
// Output declarations

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

//main statemachine

reg [1:0]         mainfsm;

wire              mainidle;

assign            mainidle = mainfsm == IDLE;


always@(posedge clk)
    begin
    if(rst)
        begin
        mainfsm <= IDLE;
        end
    else
        begin
        if(acen_i & mainidle)
            begin
            mainfsm <= IPRO;
            end
        else if(acen_r & mainidle)
            begin
            mainfsm <= RPRO;
            end
        else if(acen_s & mainidle)
            begin
            mainfsm <= SPRO;
            end
        else if(rsidone & !mainidle)
            begin
            mainfsm <= IDLE;
            end
        else
            begin
            mainfsm <= mainfsm;
            end
        end
    end

//r state machine r = x1 mod n // x1 fa 0 mod n
reg [1:0] rfsm;

reg       rdone;//included in fsm

//rproen pulse
reg      rproen;

always@(posedge clk)
    begin
    if(rst)
        rproen <= 1'b0;
    else
        if(acen_r)
            rproen <= 1'b1;
        else
            rproen <= 1'b0;
    end
//

wire      riscal1;

assign    riscal1 = rfsm == RCAL1;

wire      riscal2;

assign    riscal2 = rfsm == RCAL2;

wire      rprovld;

assign    rprovld = riscal2 & adivld;

//raen
reg       raen; //included in fsm
//

always@(posedge clk)
    begin
    if(rst)
        begin
        rfsm <= RIDLE;
        raen <= 1'b0;
        rdone <= 1'b0;
        end
    else
        begin
        if(rproen)
            begin
            rfsm <= RCAL1;
            raen <= 1'b0;//not need?
            rdone <= 1'b0;//
            end
        else if(riscal1)
            begin
            rfsm <= RCAL2;
            raen <= 1'b1;
            rdone <= 1'b0;//
            end
        else if(rprovld)
            begin
            rfsm <= RIDLE;
            raen <= 1'b0;//not need?
            rdone <= 1'b1;
            end
        else
            begin
            rfsm <= rfsm;
            raen <= 1'b0;
            rdone <= 1'b0;
            end
        end
    end

//s state machine s = kinv * (hash+r*privatekey) mod n

reg sdone;//include in fsm

reg [2:0] sfsm;

//sproen pulse
reg      sproen;

always@(posedge clk)
    begin
    if(rst)
        sproen <= 1'b0;
    else
        if(acen_s)
            sproen <= 1'b1;
        else
            sproen <= 1'b0;
    end
//
wire sisrp1;

assign sisrp1 = sfsm == SRP1;

wire   sisrp2;

assign sisrp2 = sfsm == SRP2;

wire   srpvld;

assign srpvld = sisrp2 & adivld;

wire   sisrph1;

assign sisrph1 = sfsm == SRPH1;

wire   sisrph2;

assign sisrph2 = sfsm == SRPH2;

wire   srphvld;

assign srphvld = sisrph2 & adivld;

wire   sisrphk1;

assign sisrphk1 = sfsm == SRPHK1;

wire   sisrphk2;

assign sisrphk2 = sfsm == SRPHK2;

wire   srphkvld;

assign srphkvld = sisrphk2 & adivld;

//
reg    saen; //included in fsm

//S FSM
always@(posedge clk)
    begin
    if(rst)
        begin
        sfsm <= SIDLE;
        saen <= 1'b0;
        sdone <= 1'b0;
        end
    else
        begin
        if(sproen)
            begin
            sfsm <= SRP1;
            saen <= 1'b0;
            sdone <= 1'b0;
            end
        else if(sisrp1)
            begin
            sfsm <= SRP2;
            saen <= 1'b1;
            sdone <= 1'b0;
            end
        else if(srpvld)
            begin
            sfsm <= SRPH1;
            saen <= 1'b0;
            sdone <= 1'b0;
            end
        else if(sisrph1)
            begin
            sfsm <= SRPH2;
            saen <= 1'b1;
            sdone <= 1'b0;
            end
        else if(srphvld)
            begin
            sfsm <= SRPHK1;
            saen <= 1'b0;
            sdone <= 1'b0;
            end
        else if(sisrphk1)
            begin
            sfsm <= SRPHK2;
            saen <= 1'b1;
            sdone <= 1'b0;
            end
        else if(srphkvld)
            begin
            sfsm <= SIDLE;
            saen <= 1'b0;
            sdone <= 1'b1;
            end
        else
            begin
            sfsm <= sfsm;
            saen <= 1'b0;
            sdone <= 1'b0;
            end
        end
    end

//inv state machine  k^-1 * k mod n = 1
reg idone;

reg ifsm; //1 bit

//iproen pulse
reg      iproen;

always@(posedge clk)
    begin
    if(rst)
        iproen <= 1'b0;
    else
        if(acen_i)
            iproen <= 1'b1;
        else
            iproen <= 1'b0;
    end
//
wire iiscal;

assign iiscal = ifsm == ICAL;

wire   iprovld;

assign iprovld = iiscal & adivld;

//
reg iaen;

//I FSM
always@(posedge clk)
    begin
    if(rst)
        begin
        ifsm <= IIDLE;
        iaen <= 1'b0;
        idone <= 1'b0;
        end
    else
        begin
        if(iproen)
            begin
            ifsm <= ICAL;
            iaen <= 1'b1;//not need?
            idone <= 1'b0;//
            end
        else if(iprovld)
            begin
            ifsm <= IIDLE;
            iaen <= 1'b0;//not need?
            idone <= 1'b1;
            end
        else
            begin
            ifsm <= ifsm;
            iaen <= 1'b0;
            idone <= 1'b0;
            end
        end
    end

//RAM operation controll

//assign ramra = riscal1? X_KG :
//               riscal2? ZRRAM:
//               sisrp1? R_NUM :
//               sisrp2? PRKEY :
//               sisrph1? S_RP :
//               sisrph2? HASH :
//               sisrphk1?S_RPH:
//               sisrphk2?K_INV:
//               iiscal? K_NUM :
//               ZRRAM;

reg [AWID-1:0] ramra;

always@(posedge clk)
    begin
    ramra <= riscal1? X_KG :
             riscal2? ZRRAM:
             sisrp1? R_NUM :
             sisrp2? PRKEY :
             sisrph1? S_RP :
             sisrph2? HASH :
             sisrphk1?S_RPH:
             sisrphk2?K_INV:
             iiscal? K_NUM :
             ZRRAM;
    end
//assign ramwd = adi;
reg [WID-1:0] ramwd;

always@(posedge clk)
    begin
    ramwd <= adi;
    end

//assign ramwa = rprovld? R_NUM :
//       srpvld? S_RP   : 
//       srphvld? S_RPH :
//       srphkvld? S_NUM:
//       iprovld? K_INV :
//      BLNK;

reg [AWID-1:0] ramwa;

always@(posedge clk)
    begin
    ramwa <= rprovld? R_NUM :
             srpvld? S_RP   : 
             srphvld? S_RPH :
             srphkvld? S_NUM:
             iprovld? K_INV :
             BLNK;
    end

//assign ramwe = rdone | sdone | idone;
reg ramwe;

always@(posedge clk)
    begin
    ramwe <= rprovld | srpvld | srphvld | srphkvld | iprovld;
    end
//ALU operation controll

assign aen = raen | iaen | saen;

//can be opt

assign aop = riscal2? FA :
       sisrp2? MUL  :
       sisrph2? FA  :
       sisrphk2? MUL:
       iiscal? INV  :
       FA;

//main ctrl

assign rsidone = idone | sdone | rdone;

endmodule 
