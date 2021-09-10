////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : auc_mmulinit.v
// Description  : .
//
// Author       : PC@DESKTOP-9FI2JF9
// Created On   : Sun May 05 12:21:38 2019
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module auc_mmulinit
    (
     clk,
     rst,

     // Input
     init_en,//controller
     
     // Output
     init_done,//done

     //alu
     //from ALU
     init_auvld,
     init_audat,
     //to ALU
     init_opcode,
     init_auen,
     init_carry,
     init_swapvl,
     init_swapop,
     
     // RAM control
     init_ra,
     init_wa,
     init_we,
     init_wd
     );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations
parameter           WID   = 256;
parameter           CURWID = 256;
parameter           AWID  = 5;
parameter           OPWID = 4;

localparam          ZERO   = 0;
localparam          A24VL  = 256'd121665;
localparam          BYTE = 8;

//Block RAM address table

localparam          X_G     = 0;
localparam          Y_G     = 1;
localparam          X_3G    = 2;
localparam          Y_3G    = 3;
localparam          Z_3G    = 3;
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
localparam          TEMP8   = 28;//A24

localparam          S_RP    = 29;
localparam          S_RPH   = 30;
localparam          BLNK    = 31;
//INITTABLE
localparam UNUM = 6;
localparam          X2    = 7;//X2
localparam          Z2    = 8;//Z2
localparam          X3    = 9;//X3
localparam          Z3    = 10;//Z3

localparam          ACCIDENT   = 30;//Accident write debug
localparam          A24   = 31;//A24
//VALUE INIT
localparam          X2VL   = 1;
localparam          Z2VL   = 0;
localparam          Z3VL   = 1;

//init statemachine
localparam          ISWID    = 4;
localparam          I_IDLE   = 4'd0;
localparam          I_INITX2 = 4'd1;//INIT X2
localparam          I_INITZ2 = 4'd2;//INIT Z2
localparam          I_INITX3 = 4'd3;//read X_G
localparam          I_INITX32 = 4'd4;//read ZRRAM //enable fa //waitvld
localparam          I_INITU = 4'd10; //write X_G 
localparam          I_INITZ3 = 4'd5;//INIT Z3
localparam          I_INITA24= 4'd6;//INIT A24
localparam          I_INITK1 = 4'd7;//read K 
localparam          I_INITK2 = 4'd8;//read 0 // enable fa //waitvld
localparam          I_INITK3 = 4'd9;//change //write K_dec

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input     clk;
input     rst;
     
// Input
input     init_en;//controller //done

// Output
output          init_done;//done //done

//ALU
//to ALU
output [OPWID-1:0] init_opcode;
output             init_auen;
output             init_carry;//for sub
output             init_swapop;
output             init_swapvl;

//from ALU
input [WID-1:0]    init_audat;
input              init_auvld;

// RAM control
output [AWID-1:0] init_ra;
output [AWID-1:0] init_wa;
output            init_we;
output [WID-1:0]  init_wd;

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation
//INIT FSM
//FSM
reg               init_done;

reg [ISWID-1:0] init_state;

wire      initisidle; //declared for the scope of perfection

assign    initisidle = init_state == I_IDLE;

wire      initisinitx2; 

assign    initisinitx2 = init_state == I_INITX2;

wire      initisinitz2; 

assign    initisinitz2 = init_state == I_INITZ2;

wire      initisinitx3; 

assign    initisinitx3 = init_state == I_INITX3;

wire      initisinitx32; 

assign    initisinitx32 = init_state == I_INITX32;

wire      initisinitu; 

assign    initisinitu = init_state == I_INITU;

wire      initisinitx32vld;

assign    initisinitx32vld = initisinitx32 & init_auvld;

wire      initisinitz3;

assign    initisinitz3 = init_state == I_INITZ3;

wire      initisinita24;

assign    initisinita24 = init_state == I_INITA24;

wire      initisinitk1;

assign    initisinitk1 = init_state == I_INITK1;

wire      initisinitk2;

assign    initisinitk2 = init_state == I_INITK2;

wire      initisinitk2vld;

assign    initisinitk2vld = initisinitk2 & init_auvld;

wire      initisinitk3;

assign    initisinitk3 = init_state == I_INITK3;

always@(posedge clk)
    begin
    if(rst)
        begin
        init_state <= I_IDLE;
        init_done <= 1'b0;//declared
        end
    else
        begin
        if(init_en & initisidle)
            begin
            init_state <= I_INITX2;
            init_done <= 1'b0;
            end
        else if(initisinitx2)
            begin
            init_state <= I_INITZ2;
            init_done <= 1'b0;
            end        
        else if(initisinitz2)
            begin
            init_state <= I_INITX3;
            init_done <= 1'b0;
            end
        else if(initisinitx3)
            begin
            init_state <= I_INITX32;
            init_done <= 1'b0;
            end
        else if(initisinitx32vld)
            begin
            init_state <= I_INITU;
            init_done <= 1'b0;
            end
        else if(initisinitu)
            begin
            init_state <= I_INITZ3;
            init_done <= 1'b0;
            end
        else if(initisinitz3)
            begin
            init_state <= I_INITA24;
            init_done <= 1'b0;
            end
        else if(initisinita24)
            begin
            init_state <= I_INITK1;
            init_done <= 1'b0;
            end
        else if(initisinitk1)
            begin
            init_state <= I_INITK2;
            init_done <= 1'b0;
            end
        else if(initisinitk2vld)
            begin
            init_state <= I_INITK3;
            init_done <= 1'b0;
            end
        else if(initisinitk3)
            begin
            init_state <= I_IDLE;
            init_done <= 1'b1;//done
            end
        else
            begin
            init_state <= init_state;
            init_done <= 1'b0;
            end
        end
    end

//K_NUM decode
reg [WID-1:0] kdecode;
wire [WID-1:0] kdecode2;

always@(posedge clk)
    begin
    if(rst)
        begin
        kdecode <= 256'd0;
        end
    else
        begin
        if(initisinitk2vld)
            begin
            kdecode <= {1'b0,1'b1,kdecode2[253:3],3'b0};
            end
        end
    end

assign         kdecode2[1*BYTE-1:0]      = init_audat[32*BYTE-1:31*BYTE];
assign         kdecode2[2*BYTE-1:1*BYTE] = init_audat[31*BYTE-1:30*BYTE];
assign         kdecode2[3*BYTE-1:2*BYTE] = init_audat[30*BYTE-1:29*BYTE];
assign         kdecode2[4*BYTE-1:3*BYTE] = init_audat[29*BYTE-1:28*BYTE];
assign         kdecode2[5*BYTE-1:4*BYTE] = init_audat[28*BYTE-1:27*BYTE];
assign         kdecode2[6*BYTE-1:5*BYTE] = init_audat[27*BYTE-1:26*BYTE];
assign         kdecode2[7*BYTE-1:6*BYTE] = init_audat[26*BYTE-1:25*BYTE];
assign         kdecode2[8*BYTE-1:7*BYTE] = init_audat[25*BYTE-1:24*BYTE];
assign         kdecode2[9*BYTE-1:8*BYTE] = init_audat[24*BYTE-1:23*BYTE];
assign         kdecode2[10*BYTE-1:9*BYTE] = init_audat[23*BYTE-1:22*BYTE];
assign         kdecode2[11*BYTE-1:10*BYTE] = init_audat[22*BYTE-1:21*BYTE];
assign         kdecode2[12*BYTE-1:11*BYTE] = init_audat[21*BYTE-1:20*BYTE];
assign         kdecode2[13*BYTE-1:12*BYTE] = init_audat[20*BYTE-1:19*BYTE];
assign         kdecode2[14*BYTE-1:13*BYTE] = init_audat[19*BYTE-1:18*BYTE];
assign         kdecode2[15*BYTE-1:14*BYTE] = init_audat[18*BYTE-1:17*BYTE];
assign         kdecode2[16*BYTE-1:15*BYTE] = init_audat[17*BYTE-1:16*BYTE];
assign         kdecode2[17*BYTE-1:16*BYTE] = init_audat[16*BYTE-1:15*BYTE];
assign         kdecode2[18*BYTE-1:17*BYTE] = init_audat[15*BYTE-1:14*BYTE];
assign         kdecode2[19*BYTE-1:18*BYTE] = init_audat[14*BYTE-1:13*BYTE];
assign         kdecode2[20*BYTE-1:19*BYTE] = init_audat[13*BYTE-1:12*BYTE];
assign         kdecode2[21*BYTE-1:20*BYTE] = init_audat[12*BYTE-1:11*BYTE];
assign         kdecode2[22*BYTE-1:21*BYTE] = init_audat[11*BYTE-1:10*BYTE];
assign         kdecode2[23*BYTE-1:22*BYTE] = init_audat[10*BYTE-1:9*BYTE];
assign         kdecode2[24*BYTE-1:23*BYTE] = init_audat[9*BYTE-1:8*BYTE];
assign         kdecode2[25*BYTE-1:24*BYTE] = init_audat[8*BYTE-1:7*BYTE];
assign         kdecode2[26*BYTE-1:25*BYTE] = init_audat[7*BYTE-1:6*BYTE];
assign         kdecode2[27*BYTE-1:26*BYTE] = init_audat[6*BYTE-1:5*BYTE];
assign         kdecode2[28*BYTE-1:27*BYTE] = init_audat[5*BYTE-1:4*BYTE];
assign         kdecode2[29*BYTE-1:28*BYTE] = init_audat[4*BYTE-1:3*BYTE];
assign         kdecode2[30*BYTE-1:29*BYTE] = init_audat[3*BYTE-1:2*BYTE];
assign         kdecode2[31*BYTE-1:30*BYTE] = init_audat[2*BYTE-1:1*BYTE];
assign         kdecode2[32*BYTE-1:31*BYTE] = init_audat[1*BYTE-1:0];

//ureg
reg [WID-1:0] ureg;
wire [WID-1:0] udecode;

always@(posedge clk)
    begin
    if(rst)
        begin
        ureg <= 256'd0;
        end
    else
        begin
        if(initisinitx32vld)
            begin
            ureg <= {1'b0,udecode[254:0]};
            end
        end
    end

assign         udecode[1*BYTE-1:0]      = init_audat[32*BYTE-1:31*BYTE];
assign         udecode[2*BYTE-1:1*BYTE] = init_audat[31*BYTE-1:30*BYTE];
assign         udecode[3*BYTE-1:2*BYTE] = init_audat[30*BYTE-1:29*BYTE];
assign         udecode[4*BYTE-1:3*BYTE] = init_audat[29*BYTE-1:28*BYTE];
assign         udecode[5*BYTE-1:4*BYTE] = init_audat[28*BYTE-1:27*BYTE];
assign         udecode[6*BYTE-1:5*BYTE] = init_audat[27*BYTE-1:26*BYTE];
assign         udecode[7*BYTE-1:6*BYTE] = init_audat[26*BYTE-1:25*BYTE];
assign         udecode[8*BYTE-1:7*BYTE] = init_audat[25*BYTE-1:24*BYTE];
assign         udecode[9*BYTE-1:8*BYTE] = init_audat[24*BYTE-1:23*BYTE];
assign         udecode[10*BYTE-1:9*BYTE] = init_audat[23*BYTE-1:22*BYTE];
assign         udecode[11*BYTE-1:10*BYTE] = init_audat[22*BYTE-1:21*BYTE];
assign         udecode[12*BYTE-1:11*BYTE] = init_audat[21*BYTE-1:20*BYTE];
assign         udecode[13*BYTE-1:12*BYTE] = init_audat[20*BYTE-1:19*BYTE];
assign         udecode[14*BYTE-1:13*BYTE] = init_audat[19*BYTE-1:18*BYTE];
assign         udecode[15*BYTE-1:14*BYTE] = init_audat[18*BYTE-1:17*BYTE];
assign         udecode[16*BYTE-1:15*BYTE] = init_audat[17*BYTE-1:16*BYTE];
assign         udecode[17*BYTE-1:16*BYTE] = init_audat[16*BYTE-1:15*BYTE];
assign         udecode[18*BYTE-1:17*BYTE] = init_audat[15*BYTE-1:14*BYTE];
assign         udecode[19*BYTE-1:18*BYTE] = init_audat[14*BYTE-1:13*BYTE];
assign         udecode[20*BYTE-1:19*BYTE] = init_audat[13*BYTE-1:12*BYTE];
assign         udecode[21*BYTE-1:20*BYTE] = init_audat[12*BYTE-1:11*BYTE];
assign         udecode[22*BYTE-1:21*BYTE] = init_audat[11*BYTE-1:10*BYTE];
assign         udecode[23*BYTE-1:22*BYTE] = init_audat[10*BYTE-1:9*BYTE];
assign         udecode[24*BYTE-1:23*BYTE] = init_audat[9*BYTE-1:8*BYTE];
assign         udecode[25*BYTE-1:24*BYTE] = init_audat[8*BYTE-1:7*BYTE];
assign         udecode[26*BYTE-1:25*BYTE] = init_audat[7*BYTE-1:6*BYTE];
assign         udecode[27*BYTE-1:26*BYTE] = init_audat[6*BYTE-1:5*BYTE];
assign         udecode[28*BYTE-1:27*BYTE] = init_audat[5*BYTE-1:4*BYTE];
assign         udecode[29*BYTE-1:28*BYTE] = init_audat[4*BYTE-1:3*BYTE];
assign         udecode[30*BYTE-1:29*BYTE] = init_audat[3*BYTE-1:2*BYTE];
assign         udecode[31*BYTE-1:30*BYTE] = init_audat[2*BYTE-1:1*BYTE];
assign         udecode[32*BYTE-1:31*BYTE] = init_audat[1*BYTE-1:0];

//RAM access
reg [WID-1:0] init_wd;

always@(posedge clk)
    begin
    init_wd <= initisinitx2? X2VL:
               initisinitz2? Z2VL:
               initisinitx32? {1'b0,udecode[254:0]}:
               initisinitu? ureg:
               initisinitz3? Z3VL:
               initisinita24? A24VL:
               initisinitk3? kdecode:
               ZRRAM; //mark accidental write //write this address
    end

reg [AWID-1:0] init_wa;

always@(posedge clk)
    begin
    init_wa <= initisinitx2? X2:
               initisinitz2? Z2:
               initisinitx32? X3:
               initisinitu? UNUM:
               initisinitz3? Z3:
               initisinita24? A24:
               initisinitk3? K_NUM:
               ACCIDENT; //mark accidental write
    end

reg init_we;

always@(posedge clk)
    begin
    init_we <= initisinitx2
               | initisinitz2
               | initisinitx32vld
               | initisinitu
               | initisinitz3
               | initisinita24 
               | initisinitk3;
    end

reg [AWID-1:0] init_ra;

always@(posedge clk)
    begin
    init_ra <= initisinitk1? K_NUM:
               initisinitk2? ZRRAM:
               initisinitx3? X_G:
               initisinitx32? ZRRAM:
               ZRRAM; 
    end

//ALU interface
assign init_carry = 1'b0;
assign init_opcode = 4'b0100; //P //X255 //SWAP
assign init_swapvl = 1'b1;
assign init_swapop = 1'b1;

reg    init_auen;

always@(posedge clk)
    begin
    if(rst)
        begin
        init_auen <= 1'b0;
        end
    else
        begin
        if(initisinitx3)
            begin
            init_auen <= 1'b1;
            end
        else if(initisinitk1)
            begin
            init_auen <= 1'b1;
            end
        else
            begin
            init_auen <= 1'b0;
            end
        end
    end

endmodule 
