////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : auc_mmul.v
// Description  : Montgomery multiplication
// Python code https://github.com/hakatu/rfc7748/blob/master/python/curves.py
// basically k*xP, k from ram
// Author       : hungnt@HW-NTHUNG
// Created On   : Wed April 03 13:35:57 2019
// History (Date, Changed By)
// 33% done, so much logic :((
////////////////////////////////////////////////////////////////////////////////

module auc_mmul
    (
     clk,
     rst,
     
     // Input
     mmul_en,//controller

     //from ALU
     mmul_auvld,
     mmul_audat,
     mmul_aurswap,
     // Output
     mmul_done,//done

     //to ALU
     mmul_opcode,
     mmul_auen,
     mmul_carry,
     mmul_swapop,
     mmul_swapvl,
     
     // RAM control
     mmul_ra,
     mmul_wa,
     mmul_we,
     mmul_wd
     );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations
parameter           WID   = 256;
parameter           CURWID = 255;//curve width is only 255
parameter           AWID  = 5;
parameter           OPWID = 4;

//main statemachine 
localparam          IDLE    = 2'b00;
localparam          INIT    = 2'b01;//init first xz
localparam          COMP    = 2'b10;//compute for
localparam          FINAL   = 2'b11;//final rslt calculation

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input     clk;
input     rst;
     
// Input
input     mmul_en;//controller

//from ALU
input [WID-1:0] mmul_audat;
input           mmul_auvld;
input [WID-1:0] mmul_aurswap;

// Output
output          mmul_done;//done

//to ALU
output [OPWID-1:0] mmul_opcode;
output             mmul_auen;
output             mmul_carry;//for sub
output             mmul_swapop;
output             mmul_swapvl;

// RAM control
output [AWID-1:0]  mmul_ra;
output [AWID-1:0]  mmul_wa;
output             mmul_we;
output [WID-1:0]   mmul_wd;

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation
////////////////////////////////////////
//wire
// INIT wire
reg     init_en;//controller

//from ALU
wire [WID-1:0] init_audat;
wire           init_auvld;

// Output
wire          init_done;//done

//to ALU
wire [OPWID-1:0] init_opcode;
wire             init_auen;
wire             init_carry;//for sub
wire             init_swapvl;
wire             init_swapop;

// RAM control
wire [AWID-1:0]  init_ra;
wire [AWID-1:0]  init_wa;
wire             init_we;
wire [WID-1:0]   init_wd;
////////////////////////////////////////
// COMP wire
reg     comp_en;//controller

//from ALU
wire [WID-1:0] comp_audat;
wire           comp_auvld;
wire [WID-1:0] comp_aurswap;

// Output
wire          comp_done;//done

//to ALU
wire [OPWID-1:0] comp_opcode;
wire             comp_auen;
wire             comp_carry;//for sub
wire             comp_swapop;
wire             comp_swapvl;

// RAM control
wire [AWID-1:0]  comp_ra;
wire [AWID-1:0]  comp_wa;
wire             comp_we;
wire [WID-1:0]   comp_wd;
////////////////////////////////////////
// FINAL wire
reg     final_en;//controller

//from ALU
wire [WID-1:0] final_audat;
wire           final_auvld;
wire [WID-1:0] final_aurswap;

// Output
wire          final_done;//done

//to ALU
wire [OPWID-1:0] final_opcode;
wire             final_auen;
wire             final_carry;//for sub
wire             final_swapop;
wire             final_swapvl;

// RAM control
wire [AWID-1:0]  final_ra;
wire [AWID-1:0]  final_wa;
wire             final_we;
wire [WID-1:0]   final_wd;

//Main FSM
//minor state done flag
reg [1:0]          main;
wire               mmul_done;
assign             mmul_done = final_done;

wire      mainisidle;

assign    mainisidle = main == IDLE;

wire      mainenidle;

assign    mainenidle = mainisidle & mmul_en;//mmul_en not main_en

//reg       main_en;//to enable module fsm

wire      mainisinit;

assign    mainisinit = main == INIT;

wire      maindoneinit;

assign    maindoneinit = mainisinit & init_done;

wire      mainiscomp;

assign    mainiscomp = main == COMP;

wire      maindonecomp;

assign    maindonecomp = mainiscomp & comp_done;

wire      mainisfinal;

assign    mainisfinal = main == FINAL;

wire      maindonefinal;

assign    maindonefinal = mainisfinal & final_done;

always@(posedge clk)
    begin
    if(rst)
        begin
        main <= IDLE;
        end
    else
        begin
        if(mainenidle)
            begin
            main <= INIT;
            end
        else if(maindoneinit)
            begin
            main <= COMP;
            end
        else if(maindonecomp)
            begin
            main <= FINAL;
            end
        else if(maindonefinal)
            begin
            main <= IDLE;
            end
        else
            begin
            main <= main;
            end
        end
    end

//to INIT FSM
//init_en
always@(posedge clk)
    begin
    init_en <= mainenidle? 1'b1 : 1'b0;
    end

assign init_auvld = mmul_auvld;
assign init_audat = mmul_audat;

//to COMP FSM
//comp_en
always@(posedge clk)
    begin
    comp_en <= maindoneinit? 1'b1 : 1'b0;
    end

assign comp_auvld = mmul_auvld;
assign comp_audat = mmul_audat;
assign comp_aurswap = mmul_aurswap;
//to final FSM
//final_en
always@(posedge clk)
    begin
    final_en <= maindonecomp? 1'b1 : 1'b0;
    end

assign final_auvld = mmul_auvld;
assign final_audat = mmul_audat;
assign final_aurswap = mmul_aurswap;

//MMUL OUTPUT logic

assign mmul_opcode = mainisinit? init_opcode:
       mainiscomp? comp_opcode:
       mainisfinal? final_opcode:
       4'b0;

assign mmul_auen = mainisinit? init_auen:
       mainiscomp? comp_auen:
       mainisfinal? final_auen:
       1'b0;

assign mmul_carry = mainisinit? init_carry:
       mainiscomp? comp_carry:
       mainisfinal? final_carry:
       1'b0;

assign mmul_swapop = mainisinit? init_swapop:
       mainiscomp? comp_swapop:
       mainisfinal? final_swapop:
       1'b0;

assign mmul_swapvl = mainisinit? init_swapvl:
       mainiscomp? comp_swapvl:
       mainisfinal? final_swapvl:
       1'b0;

assign mmul_ra = mainisinit? init_ra:
       mainiscomp? comp_ra:
       mainisfinal? final_ra:
       5'b0;

assign mmul_wd = mainisinit? init_wd:
       mainiscomp? comp_wd:
       mainisfinal? final_wd:
       256'b0;

assign mmul_wa = mainisinit? init_wa:
       mainiscomp? comp_wa:
       mainisfinal? final_wa:
       5'b0;

assign mmul_we = mainisinit? init_we:
       mainiscomp? comp_we:
       mainisfinal? final_we:
       1'b0;
//
//////////////instantiation/////////////////
//INIT FSM
auc_mmulinit iauc_mmul_init
    (
     .clk(clk),
     .rst(rst),
     
     // Wire
     .init_en(init_en),//controller

     //from ALU
     .init_auvld(init_auvld),
     .init_audat(init_audat),
     
     // Output
     .init_done(init_done),//done

     //to ALU
     .init_opcode(init_opcode),
     .init_auen(init_auen),
     .init_carry(init_carry),
     .init_swapop(init_swapop),
     .init_swapvl(init_swapvl),
     
     // RAM control
     .init_ra(init_ra),
     .init_wa(init_wa),
     .init_we(init_we),
     .init_wd(init_wd)
     );

///COMP FSM
auc_mmulcomp iauc_mmul_comp
    (
     .clk(clk),
     .rst(rst),
     
     // Wire
     .comp_en(comp_en),//controller

     //from ALU
     .comp_auvld(comp_auvld),
     .comp_audat(comp_audat),
     .comp_aurswap(comp_aurswap),
     
     // Output
     .comp_done(comp_done),//done

     //to ALU
     .comp_opcode(comp_opcode),
     .comp_auen(comp_auen),
     .comp_carry(comp_carry),
     .comp_swapvl(comp_swapvl),
     .comp_swapop(comp_swapop),
     
     // RAM control
     .comp_ra(comp_ra),
     .comp_wa(comp_wa),
     .comp_we(comp_we),
     .comp_wd(comp_wd)
     );


//FINAL fsm

auc_mmulfinal iauc_mmul_final
    (
     .clk(clk),
     .rst(rst),
     
     // input
     .final_en(final_en),//controller

     //from ALU
     .final_auvld(final_auvld),
     .final_audat(final_audat),
     .final_aurswap(final_aurswap),
     
     // Output
     .final_done(final_done),//done

     //to ALU
     .final_opcode(final_opcode),
     .final_auen(final_auen),
     .final_carry(final_carry),
     .final_swapvl(final_swapvl),
     .final_swapop(final_swapop),
     
     // RAM control
     .final_ra(final_ra),
     .final_wa(final_wa),
     .final_we(final_we),
     .final_wd(final_wd)
     );
endmodule 