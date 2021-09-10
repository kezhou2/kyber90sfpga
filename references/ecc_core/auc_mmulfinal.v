////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : auc_mmulfinal
// Description  : .
//
// Author       : hungnt@HW-NTHUNG
// Created On   : Wed May 08 15:41:02 2019
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module auc_mmulfinal
    (
     clk,
     rst,
     
     // Input
     final_en,//controller

     //from ALU
     final_auvld,
     final_audat,
     final_aurswap,
     
     // Output
     final_done,//done

     //to ALU
     final_opcode,
     final_auen,
     final_carry,
     final_swapvl,
     final_swapop,
     
     // RAM control
     final_ra,
     final_wa,
     final_we,
     final_wd
     );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations
parameter           WID   = 256;
parameter           CURWID = 255;//curve width is only 255
parameter           AWID  = 5;
parameter           OPWID = 4;

localparam ZERO = 0;
localparam BYTE = 8;

//ALU opcode
//carry //swap //op[1:0]
localparam FA   = 4'b0000;
localparam SUB  = 4'b1000;
localparam MUL  = 4'b0001;
localparam INV  = 4'b0010;
localparam EXP  = 4'b0011;
localparam SWAP = 4'b0100;

//Block RAM address table

localparam          X_G     = 0;
localparam          Y_G     = 1;
localparam          X_3G    = 2;
localparam          Y_3G    = 3;
localparam          Z_3G    = 3;
localparam          X_5G    = 5;
localparam          Y_5G    = 6;
localparam          Z_5G    = 7;//X2
localparam          X_7G    = 8;//Z2
localparam          Y_7G    = 9;//X3
localparam          Z_7G    = 10;//Z3

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
localparam          X2    = 7;//X2
localparam          Z2    = 8;//Z2
localparam          X3    = 9;//X3
localparam          Z3    = 10;//Z3

localparam          PS2 = 29;//p-2 address for last pow
localparam          ACCIDENT   = 30;//Accident write debug
localparam          A24   = 31;//A24

//Final FSM
localparam          FSWID       = 4;
localparam          F_IDLE      = 4'd0;
localparam          F_SWAPZ2    = 4'd1;// read z2
localparam          F_SWAPZ3    = 4'd2;// read z3 //enable swap //waitvld
localparam          F_SWAPZ32   = 4'd3;// write z2
localparam          F_SWAPX2    = 4'd4;// write z3 //read x2
localparam          F_SWAPX3    = 4'd5;// read x3 //enable swap //waitvld
localparam          F_SWAPX32   = 4'd6;// write x2
localparam          F_SWAPX33   = 4'd7;// write x3 //read z_2
localparam          F_POW       = 4'd8;//read z_2 //enable inv //waitvld
localparam          F_POW2      = 4'd9;//write X_KG //read x2
localparam          F_RSLT      = 4'd10;//read X_KG //enable mul //waitvld
localparam          F_DONE      = 4'd11;//write X_KG

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input     clk;
input     rst;
     
// Input
input     final_en;//controller

//from ALU
input [WID-1:0] final_audat;
input           final_auvld;
input [WID-1:0] final_aurswap;

// Output
output          final_done;//done

//to ALU
output [OPWID-1:0] final_opcode;
output             final_auen;
output             final_carry;//for sub
output             final_swapop;
output             final_swapvl;

// RAM control
output [AWID-1:0]  final_ra;
output [AWID-1:0]  final_wa;
output             final_we;
output [WID-1:0]   final_wd;

////////////////////////////////////////////////////////////////////////////////
// Output declarations

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation
//FINAL FSM
reg [FSWID-1:0] final_state;
reg             final_done;

wire      finalisidle; 

assign    finalisidle = final_state == F_IDLE;

wire      finalisidlevld; 

assign    finalisidlevld = finalisidle & final_auvld;

wire      finalisswapz2; 

assign    finalisswapz2 = final_state == F_SWAPZ2;

wire      finalisswapz3; 

assign    finalisswapz3 = final_state == F_SWAPZ3;

wire      finalisswapz3vld; 

assign    finalisswapz3vld = finalisswapz3 & final_auvld;

wire      finalisswapz32; 

assign    finalisswapz32 = final_state == F_SWAPZ32;

wire      finalisswapx2; 

assign    finalisswapx2 = final_state == F_SWAPX2;

wire      finalisswapx3; 

assign    finalisswapx3 = final_state == F_SWAPX3;

wire      finalisswapx3vld; 

assign    finalisswapx3vld = finalisswapx3 & final_auvld;

wire      finalisswapx32; 

assign    finalisswapx32 = final_state == F_SWAPX32;

wire      finalisswapx33; 

assign    finalisswapx33 = final_state == F_SWAPX33;

wire      finalispow; 

assign    finalispow = final_state == F_POW;

wire      finalispowvld; 

assign    finalispowvld = finalispow & final_auvld;

wire      finalispow2; 

assign    finalispow2 = final_state == F_POW2;

wire      finalisrslt; 

assign    finalisrslt = final_state == F_RSLT;

wire      finalisrsltvld; 

assign    finalisrsltvld = finalisrslt & final_auvld;

wire      finalisdone; 

assign    finalisdone = final_state == F_DONE;

always@(posedge clk)
    begin
    if(rst)
        begin
        final_state <= F_IDLE;
        final_done <= 1'b0;
        end
    else
        begin
        if(final_en & finalisidle)
            begin
            final_state <= F_SWAPZ2;
            end
        else if(finalisswapz2)
            begin
            final_state <= F_SWAPZ3;
            end
        else if(finalisswapz3vld)
            begin
            final_state <= F_SWAPZ32;
            end
        else if(finalisswapz32)
            begin
            final_state <= F_SWAPX2;
            end
        else if(finalisswapx2)
            begin
            final_state <= F_SWAPX3;
            end
        else if(finalisswapx3vld)
            begin
            final_state <= F_SWAPX32;
            end
        else if(finalisswapx32)
            begin
            final_state <= F_SWAPX33;
            end
        else if(finalisswapx33)
            begin
            final_state <= F_POW;
            end
        else if(finalispowvld)
            begin
            final_state <= F_POW2;
            end
        else if(finalispow2)
            begin
            final_state <= F_RSLT;
            end
        else if(finalisrsltvld)
            begin
            final_state <= F_DONE;
            end
        else if(finalisdone)
            begin
            final_done <= 1'b1;
            final_state <= F_IDLE;
            end
        else
            begin
            final_state <= final_state;
            final_done <= 1'b0;
            end
        end
    end
//
//alu dat catch
//final_audat1
reg [WID-1:0] final_audat1;

always@(posedge clk)
    begin
    if(rst)
        begin
        final_audat1 <= 256'd0;
        end
    else
        begin
        if(final_auvld)
            begin
            final_audat1 <= final_audat;
            end
        end
    end
//final_aurswap1
reg [WID-1:0] final_aurswap1;

always@(posedge clk)
    begin
    if(rst)
        begin
        final_aurswap1 <= 256'd0;
        end
    else
        begin
        if(final_auvld)
            begin
            final_aurswap1 <= final_aurswap;
            end
        end
    end

//decode finalresult
wire [WID-1:0] rsltdecode;

assign         rsltdecode[1*BYTE-1:0]      = final_audat1[32*BYTE-1:31*BYTE];
assign         rsltdecode[2*BYTE-1:1*BYTE] = final_audat1[31*BYTE-1:30*BYTE];
assign         rsltdecode[3*BYTE-1:2*BYTE] = final_audat1[30*BYTE-1:29*BYTE];
assign         rsltdecode[4*BYTE-1:3*BYTE] = final_audat1[29*BYTE-1:28*BYTE];
assign         rsltdecode[5*BYTE-1:4*BYTE] = final_audat1[28*BYTE-1:27*BYTE];
assign         rsltdecode[6*BYTE-1:5*BYTE] = final_audat1[27*BYTE-1:26*BYTE];
assign         rsltdecode[7*BYTE-1:6*BYTE] = final_audat1[26*BYTE-1:25*BYTE];
assign         rsltdecode[8*BYTE-1:7*BYTE] = final_audat1[25*BYTE-1:24*BYTE];
assign         rsltdecode[9*BYTE-1:8*BYTE] = final_audat1[24*BYTE-1:23*BYTE];
assign         rsltdecode[10*BYTE-1:9*BYTE] = final_audat1[23*BYTE-1:22*BYTE];
assign         rsltdecode[11*BYTE-1:10*BYTE] = final_audat1[22*BYTE-1:21*BYTE];
assign         rsltdecode[12*BYTE-1:11*BYTE] = final_audat1[21*BYTE-1:20*BYTE];
assign         rsltdecode[13*BYTE-1:12*BYTE] = final_audat1[20*BYTE-1:19*BYTE];
assign         rsltdecode[14*BYTE-1:13*BYTE] = final_audat1[19*BYTE-1:18*BYTE];
assign         rsltdecode[15*BYTE-1:14*BYTE] = final_audat1[18*BYTE-1:17*BYTE];
assign         rsltdecode[16*BYTE-1:15*BYTE] = final_audat1[17*BYTE-1:16*BYTE];
assign         rsltdecode[17*BYTE-1:16*BYTE] = final_audat1[16*BYTE-1:15*BYTE];
assign         rsltdecode[18*BYTE-1:17*BYTE] = final_audat1[15*BYTE-1:14*BYTE];
assign         rsltdecode[19*BYTE-1:18*BYTE] = final_audat1[14*BYTE-1:13*BYTE];
assign         rsltdecode[20*BYTE-1:19*BYTE] = final_audat1[13*BYTE-1:12*BYTE];
assign         rsltdecode[21*BYTE-1:20*BYTE] = final_audat1[12*BYTE-1:11*BYTE];
assign         rsltdecode[22*BYTE-1:21*BYTE] = final_audat1[11*BYTE-1:10*BYTE];
assign         rsltdecode[23*BYTE-1:22*BYTE] = final_audat1[10*BYTE-1:9*BYTE];
assign         rsltdecode[24*BYTE-1:23*BYTE] = final_audat1[9*BYTE-1:8*BYTE];
assign         rsltdecode[25*BYTE-1:24*BYTE] = final_audat1[8*BYTE-1:7*BYTE];
assign         rsltdecode[26*BYTE-1:25*BYTE] = final_audat1[7*BYTE-1:6*BYTE];
assign         rsltdecode[27*BYTE-1:26*BYTE] = final_audat1[6*BYTE-1:5*BYTE];
assign         rsltdecode[28*BYTE-1:27*BYTE] = final_audat1[5*BYTE-1:4*BYTE];
assign         rsltdecode[29*BYTE-1:28*BYTE] = final_audat1[4*BYTE-1:3*BYTE];
assign         rsltdecode[30*BYTE-1:29*BYTE] = final_audat1[3*BYTE-1:2*BYTE];
assign         rsltdecode[31*BYTE-1:30*BYTE] = final_audat1[2*BYTE-1:1*BYTE];
assign         rsltdecode[32*BYTE-1:31*BYTE] = final_audat1[1*BYTE-1:0];

// RAM control
reg [AWID-1:0]  final_ra;
reg [AWID-1:0]  final_wa;
reg             final_we;
reg [WID-1:0]   final_wd;

always@(posedge clk)
    begin
    final_wd <= finalisswapx2? final_aurswap1:
                finalisswapx33? final_aurswap1:
                finalisdone? rsltdecode:
                final_audat1;
    end

always@(posedge clk)
    begin
    final_wa <= finalisswapz32? Z3://
                finalisswapx2? Z2://
                finalisswapx32? X3://
                finalisswapx33? X2://
                finalispow2? X_KG:
                finalisdone? X_KG:
                ACCIDENT; //mark accidental write
    end

always@(posedge clk)
    begin
    final_we <= finalisswapz32
                | finalisswapx2
                | finalisswapx3
                | finalisswapx33
                | finalispow2
                | finalisdone;
    end

always@(posedge clk)
    begin
    final_ra <= finalisswapz2? Z2:
                finalisswapz3? Z3:
                finalisswapx2? X2:
                finalisswapx3? X3:
                finalisswapx33? Z2:
                finalispow? Z2:
                finalispow2? X2:
                finalisrslt? X_KG:
                ZRRAM; 
    end

/////////////////////
//ALU interface
reg [OPWID-1:0] final_opcode;
reg             final_auen;
reg             final_carry;//for sub
reg             final_swapop;
wire            final_swapvl;

//SWAP
assign          final_swapvl = 1'b0;


//opcode //swapop /carry
always@(posedge clk)
    begin
    if(rst)
        begin
        final_opcode[1:0] <= ZERO;
        final_opcode[2] <= 1'b1; //X255
        final_opcode[3] <= 1'b0; //P
        final_swapop <= 1'b0;
        final_carry <= 1'b0;
        end
    else
        begin
        {final_carry,final_swapop,final_opcode[1:0]} <= finalisswapz3? SWAP:
                                                        finalisswapx3? SWAP:
                                                        finalispow? INV:
                                                        finalisrslt? MUL:
                                                        4'b0000; 
        end
    end
//
always@(posedge clk)
    begin
    if(rst)
        begin
        final_auen <= 1'b0;
        end
    else
        begin
        if(finalisswapz2)
            begin
            final_auen <= 1'b1;    
            end
        else if(finalisswapx2)
            begin
            final_auen <= 1'b1;    
            end
        else if(finalisswapx33)
            begin
            final_auen <= 1'b1;        
            end
        else if(finalispow2)
            begin
            final_auen <= 1'b1;        
            end
        else
            begin
            final_auen <= 1'b0;
            end
        end
    end
//


endmodule 
