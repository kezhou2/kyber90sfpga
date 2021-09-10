////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : auc_mmulcomp.v
// Description  : .
//
// Author       : hungnt@HW-NTHUNG
// Created On   : Wed May 08 09:44:02 2019
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module auc_mmulcomp
    (
     clk,
     rst,
     
     // Input
     comp_en,//controller

     //from ALU
     comp_auvld,
     comp_audat,
     comp_aurswap,
     // Output
     comp_done,//done

     //to ALU
     comp_opcode,
     comp_auen,
     comp_carry,
     comp_swapvl,
     comp_swapop,
     
     // RAM control
     comp_ra,
     comp_wa,
     comp_we,
     comp_wd
     );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations
parameter           WID   = 256;
parameter           CURWID = 256;
parameter           AWID  = 5;
parameter           OPWID = 4;
parameter           CNTWID = 8;

localparam          ZERO   = 0;
localparam          A24VL  = 256'd121665;

localparam          CNTSTART = 254;
localparam          CNTSTOP = 0;

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

//TEMP CHANGE NAME FOR USAGE in comp
localparam          A     = 20;
localparam          DA    = 20;
localparam          B     = 21;
localparam          CB    = 21;
localparam          AA    = 22;
localparam          C     = 22;
localparam          DACBS = 22; //DA-CB
localparam          BB    = 23;
localparam          Z2TEMP= 23;
localparam          D     = 23;
localparam          DACB  = 23; //DA+CB
localparam          E     = 24;
localparam          DACB2 = 24;
//
//comp statemachine (loop 254 to 0) 255 iterations
localparam          CSWID    = 6;
localparam          C_IDLE     = 6'd0;
localparam          C_PREKT1   = 6'd1; //read K
localparam          C_PREKT2   = 6'd2; //read 0 //enable fa //wait vld
localparam          C_SWAPX2   = 6'd3;//get swap^=k>>i & 1 //read x2
localparam          C_SWAPX3   = 6'd4;//read x3 //enable swap //waitvld
localparam          C_SWAPZ2   = 6'd5;//write x2
localparam          C_SWAPZ22  = 6'd6;//write x3 //read z2
localparam          C_SWAPZ3   = 6'd7;//read z3 //enable swap //waitvld
localparam          C_SWAPZ32  = 6'd8;//write z2
localparam          C_SWAPZ33  = 6'd9;//write z3 //read x2
localparam          C_GETA1    = 6'd10;//read z2 //enable fa //waitvld
localparam          C_GETA2    = 6'd11;//write A //read A
localparam          C_GETAA    = 6'd12;//read A //enable mul //waitvld
localparam          C_GETB1    = 6'd13;//write AA //read z2 //x2-z2
localparam          C_GETB2    = 6'd14;//read x2 //enable fa & carry(sub) //waitvld
localparam          C_GETBB    = 6'd15;//write B //read B
localparam          C_GETBB2   = 6'd16;//read B //enable mul //waitvld
localparam          C_GETE1    = 6'd17;//write BB //read BB AA-BB
localparam          C_GETE2    = 6'd18;//read AA //enable fa & carry(sub) //waitvld
localparam          C_GETX21   = 6'd19;//write E //read AA
localparam          C_GETX22   = 6'd20;//read BB //enable mul //waitvld
localparam          C_GETZ21   = 6'd21;//write x2 //read E
localparam          C_GETZ22   = 6'd22;//read A24 //enable mul //waitvld
localparam          C_GETZ23   = 6'd23;//write Z2TEMP //read AA
localparam          C_GETZ24   = 6'd24;//read Z2TEMP //enable fa //waitvld
localparam          C_GETZ25   = 6'd25;//write Z2TEMP //read E
localparam          C_GETZ26   = 6'd26;//read Z2TEMP //enable mul //waitvld
localparam          C_GETC1    = 6'd27;//write z2 //read x3
localparam          C_GETC2    = 6'd28;//read z3  //enable fa //waitvld
localparam          C_GETD1    = 6'd29;//write C //read z3 //x3-z3
localparam          C_GETD2    = 6'd30;//read x3  //enable fa & carry(sub) //waitvld
localparam          C_GETCB1   = 6'd31;//write D //read C
localparam          C_GETCB2   = 6'd32;//read B  //enable mul  //waitvld
localparam          C_GETDA1   = 6'd33;//write CB //read D
localparam          C_GETDA2   = 6'd34;//read A  //enable mul  //waitvld
localparam          C_GETX31   = 6'd35;//write DA //read CB
localparam          C_GETX32   = 6'd36;//read DA  //enable fa  //waitvld
localparam          C_GETX33   = 6'd37;//write DACB  //read DACB
localparam          C_GETX34   = 6'd38;//read DACB  //enable mul  //waitvld
localparam          C_GETDACB21= 6'd39;//write x3  //read CB //DA-CB
localparam          C_GETDACB22= 6'd40;//read DA  //enable fa & carry(sub)  //waitvld
localparam          C_GETDACB23= 6'd41;//write DACBS  //read DACBS
localparam          C_GETDACB24= 6'd42;//read DACBS  //enable mul  //waitvld
localparam          C_GETZ31   = 6'd43;//write DACBS //read //read UNUM
localparam          C_GETZ32   = 6'd44;//read DACBS  //enable mul  //waitvld //counter dec
localparam          C_GETZ33   = 6'd45;//write Z3
//next if if done to idle //if not done go to C_PREKT1 again

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input     clk;
input     rst;
     
// Input
input     comp_en;//controller

//from ALU
input [WID-1:0] comp_audat;
input           comp_auvld;
input [WID-1:0] comp_aurswap;

// Output
output          comp_done;//done

//to ALU
output [OPWID-1:0] comp_opcode;
output             comp_auen;
output             comp_carry;//for sub
output             comp_swapop;
output             comp_swapvl;

// RAM control
output [AWID-1:0]  comp_ra;
output [AWID-1:0]  comp_wa;
output             comp_we;
output [WID-1:0]   comp_wd;

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation
//COMP FSM
reg [CNTWID-1:0] cnt;

reg              comp_done;

wire               compcnt_done;

assign             compcnt_done = cnt == CNTSTOP;

reg [CSWID-1:0] comp_state;

wire      compisidle; 

assign    compisidle = comp_state == C_IDLE;

wire      compisidlevld; 

assign    compisidlevld = compisidle & comp_auvld;

wire      compisprekt1; 

assign    compisprekt1 = comp_state == C_PREKT1;

wire      compisprekt2; 

assign    compisprekt2 = comp_state == C_PREKT2;

wire      compisprekt2vld; 

assign    compisprekt2vld = compisprekt2 & comp_auvld;

wire      compisswapx2; 

assign    compisswapx2 = comp_state == C_SWAPX2;

wire      compisswapx3; 

assign    compisswapx3 = comp_state == C_SWAPX3;

wire      compisswapx3vld; 

assign    compisswapx3vld = compisswapx3 & comp_auvld;

wire      compisswapz2; 

assign    compisswapz2 = comp_state == C_SWAPZ2;

wire      compisswapz22; 

assign    compisswapz22 = comp_state == C_SWAPZ22;

wire      compisswapz3; 

assign    compisswapz3 = comp_state == C_SWAPZ3;

wire      compisswapz3vld; 

assign    compisswapz3vld = compisswapz3 & comp_auvld;

wire      compisswapz32; 

assign    compisswapz32 = comp_state == C_SWAPZ32;

wire      compisswapz33; 

assign    compisswapz33 = comp_state == C_SWAPZ33;

wire      compisgeta1; 

assign    compisgeta1 = comp_state == C_GETA1;

wire      compisgeta1vld; 

assign    compisgeta1vld = compisgeta1 & comp_auvld;

wire      compisgeta2; 

assign    compisgeta2 = comp_state == C_GETA2;

wire      compisgetaa; 

assign    compisgetaa = comp_state == C_GETAA;

wire      compisgetaavld; 

assign    compisgetaavld = compisgetaa & comp_auvld;

wire      compisgetb1; 

assign    compisgetb1 = comp_state == C_GETB1;

wire      compisgetb2; 

assign    compisgetb2 = comp_state == C_GETB2;

wire      compisgetb2vld; 

assign    compisgetb2vld = compisgetb2 & comp_auvld;

wire      compisgetbb; 

assign    compisgetbb = comp_state == C_GETBB;

wire      compisgetbb2; 

assign    compisgetbb2 = comp_state == C_GETBB2;

wire      compisgetbb2vld; 

assign    compisgetbb2vld = compisgetbb2 & comp_auvld;

wire      compisgete1; 

assign    compisgete1 = comp_state == C_GETE1;

wire      compisgete2; 

assign    compisgete2 = comp_state == C_GETE2;

wire      compisgete2vld; 

assign    compisgete2vld = compisgete2 & comp_auvld;

wire      compisgetx21; 

assign    compisgetx21 = comp_state == C_GETX21;

wire      compisgetx22; 

assign    compisgetx22 = comp_state == C_GETX22;

wire      compisgetx22vld; 

assign    compisgetx22vld = compisgetx22 & comp_auvld;

wire      compisgetz21; 

assign    compisgetz21 = comp_state == C_GETZ21;

wire      compisgetz22; 

assign    compisgetz22 = comp_state == C_GETZ22;

wire      compisgetz22vld; 

assign    compisgetz22vld = compisgetz22 & comp_auvld;

wire      compisgetz23; 

assign    compisgetz23 = comp_state == C_GETZ23;

wire      compisgetz24; 

assign    compisgetz24 = comp_state == C_GETZ24;

wire      compisgetz24vld; 

assign    compisgetz24vld = compisgetz24 & comp_auvld;

wire      compisgetz25; 

assign    compisgetz25 = comp_state == C_GETZ25;

wire      compisgetz26; 

assign    compisgetz26 = comp_state == C_GETZ26;

wire      compisgetz26vld; 

assign    compisgetz26vld = compisgetz26 & comp_auvld;

wire      compisgetc1; 

assign    compisgetc1 = comp_state == C_GETC1;

wire      compisgetc2; 

assign    compisgetc2 = comp_state == C_GETC2;

wire      compisgetc2vld; 

assign    compisgetc2vld = compisgetc2 & comp_auvld;

wire      compisgetd1; 

assign    compisgetd1 = comp_state == C_GETD1;

wire      compisgetd2; 

assign    compisgetd2 = comp_state == C_GETD2;

wire      compisgetd2vld; 

assign    compisgetd2vld = compisgetd2 & comp_auvld;

wire      compisgetcb1; 

assign    compisgetcb1 = comp_state == C_GETCB1;

wire      compisgetcb2; 

assign    compisgetcb2 = comp_state == C_GETCB2;

wire      compisgetcb2vld; 

assign    compisgetcb2vld = compisgetcb2 & comp_auvld;

wire      compisgetda1; 

assign    compisgetda1 = comp_state == C_GETDA1;

wire      compisgetda2; 

assign    compisgetda2 = comp_state == C_GETDA2;

wire      compisgetda2vld; 

assign    compisgetda2vld = compisgetda2 & comp_auvld;

wire      compisgetx31; 

assign    compisgetx31 = comp_state == C_GETX31;

wire      compisgetx32; 

assign    compisgetx32 = comp_state == C_GETX32;

wire      compisgetx32vld; 

assign    compisgetx32vld = compisgetx32 & comp_auvld;

wire      compisgetx33; 

assign    compisgetx33 = comp_state == C_GETX33;

wire      compisgetx34; 

assign    compisgetx34 = comp_state == C_GETX34;

wire      compisgetx34vld; 

assign    compisgetx34vld = compisgetx34 & comp_auvld;

wire      compisgetdacb21; 

assign    compisgetdacb21 = comp_state == C_GETDACB21;

wire      compisgetdacb22; 

assign    compisgetdacb22 = comp_state == C_GETDACB22;

wire      compisgetdacb22vld; 

assign    compisgetdacb22vld = compisgetdacb22 & comp_auvld;

wire      compisgetdacb23; 

assign    compisgetdacb23 = comp_state == C_GETDACB23;

wire      compisgetdacb24; 

assign    compisgetdacb24 = comp_state == C_GETDACB24;

wire      compisgetdacb24vld; 

assign    compisgetdacb24vld = compisgetdacb24 & comp_auvld;

wire      compisgetz31; 

assign    compisgetz31 = comp_state == C_GETZ31;

wire      compisgetz32; 

assign    compisgetz32 = comp_state == C_GETZ32;

wire      compisgetz32vld; 

assign    compisgetz32vld = compisgetz32 & comp_auvld;

wire      compisgetz33; 

assign    compisgetz33 = comp_state == C_GETZ33;

//counter
always@(posedge clk)
    begin
    if(rst)
        begin
        cnt <= ZERO;
        end
    else
        begin
        if(compisidle)
            begin
            cnt <= CNTSTART;
            end
        else if(compisgetz33)
            begin
            cnt <= cnt - 256'd1;//sub
            end
        else
            begin
            cnt <= cnt;
            end
        end
    end

always@(posedge clk)
    begin
    if(rst)
        begin
        comp_state <= C_IDLE;
        end
    else
        begin
        if(comp_en & compisidle)
            begin
            comp_state <= C_PREKT1;            
            end
        else if(compisprekt1)
            begin
            comp_state <= C_PREKT2;    
            end
        else if(compisprekt2vld)
            begin
            comp_state <= C_SWAPX2;     
            end
        else if(compisswapx2)
            begin
            comp_state <= C_SWAPX3;    
            end
        else if(compisswapx3vld)
            begin
            comp_state <= C_SWAPZ2;    
            end
        else if(compisswapz2)
            begin
            comp_state <= C_SWAPZ22;        
            end
        else if(compisswapz22)
            begin
            comp_state <= C_SWAPZ3;        
            end
        else if(compisswapz3vld)
            begin
            comp_state <= C_SWAPZ32;        
            end
        else if(compisswapz32)
            begin
            comp_state <= C_SWAPZ33;         
            end
        else if(compisswapz33)
            begin
            comp_state <= C_GETA1;         
            end
        else if(compisgeta1vld)
            begin
            comp_state <= C_GETA2;         
            end
        else if(compisgeta2)
            begin
            comp_state <= C_GETAA;        
            end
        else if(compisgetaavld)
            begin
            comp_state <= C_GETB1;        
            end
        else if(compisgetb1)
            begin
            comp_state <= C_GETB2;        
            end
        else if(compisgetb2vld)
            begin
            comp_state <= C_GETBB;         
            end
        else if(compisgetbb)
            begin
            comp_state <= C_GETBB2;            
            end
        else if(compisgetbb2vld)
            begin
            comp_state <= C_GETE1;          
            end
        else if(compisgete1)
            begin
            comp_state <= C_GETE2;           
            end
        else if(compisgete2vld)
            begin
            comp_state <= C_GETX21;            
            end
        else if(compisgetx21)
            begin
            comp_state <= C_GETX22;            
            end
        else if(compisgetx22vld)
            begin
            comp_state <= C_GETZ21;            
            end
        else if(compisgetz21)
            begin
            comp_state <= C_GETZ22;            
            end
        else if(compisgetz22vld)
            begin
            comp_state <= C_GETZ23;            
            end
        else if(compisgetz23)
            begin
            comp_state <= C_GETZ24;            
            end
        else if(compisgetz24vld)
            begin
            comp_state <= C_GETZ25;            
            end
        else if(compisgetz25)
            begin
            comp_state <= C_GETZ26;            
            end
        else if(compisgetz26vld)
            begin
            comp_state <= C_GETC1;       
            end
        else if(compisgetc1)
            begin
            comp_state <= C_GETC2;            
            end
        else if(compisgetc2vld)
            begin
            comp_state <= C_GETD1;            
            end
        else if(compisgetd1)
            begin
            comp_state <= C_GETD2;            
            end
        else if(compisgetd2vld)
            begin
            comp_state <= C_GETCB1;            
            end
        else if(compisgetcb1)
            begin
            comp_state <= C_GETCB2;            
            end
        else if(compisgetcb2vld)
            begin
            comp_state <= C_GETDA1;            
            end
        else if(compisgetda1)
            begin
            comp_state <= C_GETDA2;            
            end
        else if(compisgetda2vld)
            begin
            comp_state <= C_GETX31;            
            end
        else if(compisgetx31)
            begin
            comp_state <= C_GETX32;
            end
        else if(compisgetx32vld)
            begin
            comp_state <= C_GETX33;            
            end
        else if(compisgetx33)
            begin
            comp_state <= C_GETX34;            
            end
        else if(compisgetx34vld)
            begin
            comp_state <= C_GETDACB21;            
            end
        else if(compisgetdacb21)
            begin
            comp_state <= C_GETDACB22;            
            end
        else if(compisgetdacb22vld)
            begin
            comp_state <= C_GETDACB23;            
            end
        else if(compisgetdacb23)
            begin
            comp_state <= C_GETDACB24;            
            end
        else if(compisgetdacb24vld)
            begin
            comp_state <= C_GETZ31;            
            end
        else if(compisgetz31)
            begin
            comp_state <= C_GETZ32;            
            end
        else if(compisgetz32vld)
            begin
            comp_state <= C_GETZ33;            
            end
        else if(compisgetz33)
            begin
            if(compcnt_done)
                begin
                comp_state <= C_IDLE;
                end
            else
                begin
                comp_state <= C_PREKT1;   
                end
            end
        else
            begin
            comp_state <= comp_state;
            end
        end
    end

//comp_done
wire compdonecond; //comp done condition

assign compdonecond = compisgetz33 & compcnt_done;

always@(posedge clk)
    begin
    if(rst)
        begin
        comp_done <= 1'b0;
        end
    else
        begin
        if(compdonecond)
            begin
            comp_done <= 1'b1;
            end
        else
            begin
            comp_done <= 1'b0;
            end
        end
    end

//alu dat catch
//comp_audat1
reg [WID-1:0] comp_audat1;

always@(posedge clk)
    begin
    if(rst)
        begin
        comp_audat1 <= 256'd0;
        end
    else
        begin
        if(comp_auvld)
            begin
            comp_audat1 <= comp_audat;
            end
        end
    end
//comp_aurswap1
reg [WID-1:0] comp_aurswap1;

always@(posedge clk)
    begin
    if(rst)
        begin
        comp_aurswap1 <= 256'd0;
        end
    else
        begin
        if(comp_auvld)
            begin
            comp_aurswap1 <= comp_aurswap;
            end
        end
    end

//RAM access

//RAM write
reg [WID-1:0] comp_wd;

always@(posedge clk)
    begin
    comp_wd <= compisswapz22? comp_aurswap1:
               compisswapz33? comp_aurswap1:
               comp_audat1;
    end

reg [AWID-1:0] comp_wa;

always@(posedge clk)
    begin
    comp_wa <= compisswapz2? X3://
               compisswapz22? X2://testing reverse pos fix
               compisswapz32? Z3://
               compisswapz33? Z2://
               compisgeta2? A:
               compisgetb1? AA:
               compisgetbb? B:
               compisgete1? BB:
               compisgetx21? E:
               compisgetz21? X2:
               compisgetz23? Z2TEMP:
               compisgetz25? Z2TEMP:
               compisgetc1? Z2:
               compisgetd1? C:
               compisgetcb1? D:
               compisgetda1? CB:
               compisgetx31? DA:
               compisgetx33? DACB:
               compisgetdacb21? X3:
               compisgetdacb23? DACBS:
               compisgetz31? DACBS:
               compisgetz33? Z3:
               ZRRAM; //mark accidental write
    end

//we

reg comp_we;

always@(posedge clk)
    begin
    if(rst)
        begin
        comp_we <= 1'b0;
        end
    else
        begin
        comp_we <= compisswapz2
                   | compisswapz22
                   | compisswapz32
                   | compisswapz33
                   | compisgeta2
                   | compisgetb1
                   | compisgetbb
                   | compisgete1
                   | compisgetx21
                   | compisgetz21
                   | compisgetz23
                   | compisgetz25
                   | compisgetc1
                   | compisgetd1
                   | compisgetcb1
                   | compisgetda1
                   | compisgetx31
                   | compisgetx33
                   | compisgetdacb21
                   | compisgetdacb23
                   | compisgetz31
                   | compisgetz33
                   ;
        end
    end

//RAM read
reg [AWID-1:0] comp_ra;

always@(posedge clk)
    begin
    comp_ra <= compisprekt1? K_NUM:
               compisprekt2? ZRRAM:
               compisswapx2? X2:
               compisswapx3? X3:
               compisswapz22? Z2:
               compisswapz3? Z3:
               compisswapz33? X2:
               compisgeta1? Z2:
               compisgeta2? A:
               compisgetaa? A:
               compisgetb1? Z2:
               compisgetb2? X2:
               compisgetbb? B:
               compisgetbb2? B:
               compisgete1? BB:
               compisgete2? AA:
               compisgetx21? AA:
               compisgetx22? BB:
               compisgetz21? E:
               compisgetz22? A24:
               compisgetz23? AA:
               compisgetz24? Z2TEMP:
               compisgetz25? E:
               compisgetz26? Z2TEMP:
               compisgetc1? X3:
               compisgetc2? Z3:
               compisgetd1? Z3:
               compisgetd2? X3:
               compisgetcb1? C:
               compisgetcb2? B:
               compisgetda1? D:
               compisgetda2? A:
               compisgetx31? DA:
               compisgetx32? CB:
               compisgetx33? DACB:
               compisgetx34? DACB:
               compisgetdacb21? DA:
               compisgetdacb22? CB:
               compisgetdacb23? DACBS:
               compisgetdacb24? DACBS:
               compisgetz31? UNUM:
               compisgetz32? DACBS:
               ACCIDENT; //mark accidental read
    end

//////
//ALU interface
reg [OPWID-1:0] comp_opcode;
reg             comp_auen;
reg             comp_carry;//for sub
reg             comp_swapop;
reg             comp_swapvl;

//opcode //swapop /carry
always@(posedge clk)
    begin
    if(rst)
        begin
        comp_opcode[1:0] <= ZERO;
        comp_opcode[2] <= 1'b1; //X255
        comp_opcode[3] <= 1'b0; //P
        comp_swapop <= 1'b0;
        comp_carry <= 1'b0;
        end
    else
        begin
        {comp_carry,comp_swapop,comp_opcode[1:0]} <= compisprekt2? FA:
                                                     compisswapx3? SWAP:
                                                     compisswapz3? SWAP:
                                                     compisgeta1? FA:
                                                     compisgetaa? MUL:
                                                     compisgetb2? SUB:
                                                     compisgetbb2? MUL:
                                                     compisgete2? SUB:
                                                     compisgetx22? MUL:
                                                     compisgetz22? MUL:
                                                     compisgetz24? FA:
                                                     compisgetz26? MUL:
                                                     compisgetc2? FA:
                                                     compisgetd2? SUB:
                                                     compisgetcb2? MUL:
                                                     compisgetda2? MUL:
                                                     compisgetx32? FA:
                                                     compisgetx34? MUL:
                                                     compisgetdacb22? SUB:
                                                     compisgetdacb24? MUL: 
                                                     compisgetz32? MUL:
                                                     4'b0000; 
        end
    end
//comp_swapvl
reg comp_swapvltemp;

always@(posedge clk)
    begin
    if(rst)
        begin
        comp_swapvl <= 1'b0;
        comp_swapvltemp <= 1'b0;
        end
    else
        begin
        if(compisidle)
            begin
            comp_swapvl <= 1'b0;
            comp_swapvltemp <= 1'b0;
            end
        else
            begin
            if(compisprekt2vld)
                begin
                comp_swapvl <= comp_swapvl ^ comp_audat[cnt];
                comp_swapvltemp <= comp_audat[cnt];
                end
            else if(compisgeta1)
                begin
                comp_swapvl <= comp_swapvltemp;
                end
            end
        end
    end

//comp_auen
always@(posedge clk)
    begin
    if(rst)
        begin
        comp_auen <= 1'b0;
        end
    else
        begin
        if(compisprekt1)
            begin
            comp_auen <= 1'b1;    
            end
        else if(compisswapx2)
            begin
            comp_auen <= 1'b1;    
            end
        else if(compisswapz22)
            begin
            comp_auen <= 1'b1;        
            end
        else if(compisswapz33)
            begin
            comp_auen <= 1'b1;         
            end
        else if(compisgeta2)
            begin
            comp_auen <= 1'b1;        
            end
        else if(compisgetb1)
            begin
            comp_auen <= 1'b1;        
            end
        else if(compisgetbb)
            begin
            comp_auen <= 1'b1;            
            end
        else if(compisgete1)
            begin
            comp_auen <= 1'b1;           
            end
        else if(compisgetx21)
            begin
            comp_auen <= 1'b1;            
            end
        else if(compisgetz21)
            begin
            comp_auen <= 1'b1;            
            end
        else if(compisgetz23)
            begin
            comp_auen <= 1'b1;            
            end
        else if(compisgetz25)
            begin
            comp_auen <= 1'b1;            
            end
        else if(compisgetc1)
            begin
            comp_auen <= 1'b1;            
            end
        else if(compisgetd1)
            begin
            comp_auen <= 1'b1;            
            end
        else if(compisgetcb1)
            begin
            comp_auen <= 1'b1;            
            end
        else if(compisgetda1)
            begin
            comp_auen <= 1'b1;            
            end
        else if(compisgetx31)
            begin
            comp_auen <= 1'b1;
            end
        else if(compisgetx33)
            begin
            comp_auen <= 1'b1;            
            end
        else if(compisgetdacb21)
            begin
            comp_auen <= 1'b1;            
            end
        else if(compisgetdacb23)
            begin
            comp_auen <= 1'b1;            
            end
        else if(compisgetz31)
            begin
            comp_auen <= 1'b1;            
            end
        else
            begin
            comp_auen <= 1'b0;
            end
        end
    end

endmodule
