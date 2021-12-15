module polyunit_core2(
    clk,
    rst,
    
    data_in,
    data_in_add,
    data_in_done,

    data_out, //NTT RAM

    mode,//see param
    run,
    done
);
/////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////

parameter WID   = 12;
parameter DWID = WID*4; //RAM DATAWID
parameter AWID = 5;//32 address ram

//poly statemachine
localparam          POLYWID     = 3;
localparam          P_IDLE      = 3'd0;
localparam          P_NTT       = 3'd1;//
localparam          P_INTT      = 3'd2;//
localparam          P_DATAIN    = 3'd3;//
localparam          P_DATAOUT   = 3'd4;//

//poly mode
localparam          M_NTT       = 2'd0;//
localparam          M_INTT      = 2'd1;//
localparam          M_DATAIN    = 2'd2;//
localparam          M_DATAOUT   = 2'd3;//

//NTTFSM n = 128
localparam          N_IDLE      = 3'd0;//
localparam          N_CY1       = 3'd1;// //full
localparam          N_CY2       = 3'd2;// //full
localparam          N_CY3       = 3'd3;// //full
localparam          N_CY4       = 3'd4;// //bypass 2 
localparam          N_CY5       = 3'd4;// //bypass 1

/////////////////////////////////////////////////////////

input    clk;
input    rst;
    
input [DWID-1:0] data_in;
input [AWID-1:0] data_in_add;
input data_in_done;

output [DWID-1:0] data_out; //NTT RAM

input [1:0] mode;//mode of operation // NTT 01 or INTT 10 or datain 00 or dataout 11
input run;

output done;

/////////////////////////////////////////////////////////
//for dataout datain
//32-counter

reg [4:0] docnt; // three two counter
//reg [4:0] dicnt; // three two counter

wire ntt_done;
wire intt_done;

///////FSM////////
reg done; //for output

wire caldone;

reg [2:0] main_state;

wire mainidle;

assign mainidle = main_state == P_IDLE;

wire startntt;

assign startntt = mainidle & (mode == M_NTT) & run;

wire startintt;

assign startintt = mainidle & (mode == M_INTT) & run; 

wire startdatain;

assign startdatain = mainidle & (mode == M_DATAIN) & run;

wire startdataout;

assign startdataout = mainidle & (mode == M_DATAOUT) & run; 

wire mainntt;

assign mainntt = main_state == P_NTT;

wire mainintt;

assign mainintt = main_state == P_INTT;

wire maindatain;

assign maindatain = main_state == P_DATAIN;

wire maindataout;

assign maindataout = main_state == P_DATAOUT;

always @(posedge clk) begin
    if(rst)
    begin
    main_state <= P_IDLE;
    done <= 1'b0;
    end
    else
    if(startntt)
    main_state <= P_NTT;
    else if (startintt)
    main_state <= P_INTT;
    else if (startdatain)
    main_state <= P_DATAIN;
    else if (startdataout)
    main_state <= P_DATAOUT;
    else if (caldone)
    begin
    main_state <= P_IDLE;
    done <= 1'b1;
    end
    else
    begin
    main_state <= main_state;
    done <= 1'b0;
    end
end

assign ntt_done = 1'b0;
assign intt_done = 1'b0;
/////////////////////////////////////////////
//main RAM
wire wren;
wire [DWID-1:0] rddata,wrdata;
wire [AWID-1:0] rdadd,wradd;

alram112x #(DWID,AWID) ialram112x
    (
     .clkw(clk),//clock write
     .clkr(clk),//clock read
     .rst(rst),
     
     .rdo(rddata),//data from ram
     .ra(rdadd),//read address
     
     .wdi(wrdata),//data to ram
     .wa(wradd),//write address
     .we(wren) //write enable
     );

/////////////////////////////////////////////
//main ROMs (w)

wire wrenrom;
wire [WID-1:0] romdata00,romdata10,romdata11;
wire [6:0] rdadd00,rdadd10,rdadd11;

mem_gen1 #(WID) imem_gen1
(
    .clk(clk),
    .addr(rdadd00), //using with 
    .wr_ena(wrenrom),
    .data(romdata00)
);

mem_gen1 #(WID) imem_gen2
(
    .clk(clk),
    .addr(rdadd10), //using with 
    .wr_ena(wrenrom),
    .data(romdata10)
);

mem_gen1 #(WID) imem_gen3
(
    .clk(clk),
    .addr(rdadd11), //using with 
    .wr_ena(wrenrom),
    .data(romdata11)
);

assign wrenrom = 1'b0; //gan gia tri tranh float

//ROM address logic (temp of course)
//assign rdadd00 = 7'd0;
//assign rdadd10 = 7'd1;
//assign rdadd11 = 7'd2;

/////////////////////////////////////////////
//main butterflys
wire butsel;

assign butsel = mainntt;

wire [WID-1:0] u00,t00,u01,t01,u10,t10,u11,t11,u20,t20,u21,t21;
wire [WID-1:0] w00,w10,w11;

butterfly2 ibutterfly1(
    .clk(clk),
    .rst(rst),

    .u(u00),//input 12-bit
    .t(t00),
    .w(w00),

    .s0(u10),
    .s1(t10),

    .sel(butsel) //mode of operation NTT:1 INTT:0
);

butterfly2 ibutterfly2(
    .clk(clk),
    .rst(rst),

    .u(u01),//input 12-bit
    .t(t01),
    .w(w00),

    .s0(u11),
    .s1(t11),

    .sel(butsel) //mode of operation NTT:1 INTT:0
);

butterfly2 ibutterfly3(
    .clk(clk),
    .rst(rst),

    .u(u10),//input 12-bit
    .t(u11),
    .w(w10),

    .s0(u20),
    .s1(t20),

    .sel(butsel) //mode of operation NTT:1 INTT:0
);

butterfly2 ibutterfly4(
    .clk(clk),
    .rst(rst),

    .u(t10),//input 12-bit
    .t(t11),
    .w(w11),

    .s0(u21),
    .s1(t21),

    .sel(butsel) //mode of operation NTT:1 INTT:0
);

//without delay;

assign u00 = rddata[11:0];
assign t00 = rddata[23:12];
assign u01 = rddata[35:24];
assign t01 = rddata[47:36];

assign w00 = romdata00;
assign w10 = romdata10;
assign w11 = romdata11;

//to write back data to RAM

wire [DWID-1:0] butwrdata;
wire [DWID-1:0] butd1,butd2,butd3,butd4;
wire [1:0] wreno;//write enabler number

sipo isipo1 (clk,rst,u20,butd1);
sipo isipo1 (clk,rst,t20,butd2);
sipo isipo1 (clk,rst,u21,butd3);
sipo isipo1 (clk,rst,t21,butd4);

assign butwrdata = (wreno == 01)? butd2:
                    (wreno == 10)? butd3:
                    (wreno == 11)? butd4:
                    butd1;

//data mux

assign wrdata = maindatain? data_in : butwrdata;

//////////The address logic/////////
//8-10-clock counter
reg [3:0] flagcnt;
wire eightflag, tenflag;

always @(posedge clk) begin
    if(rst)
    flagcnt <= 0;
    else
    if(mainntt & eightflag)
    flagcnt <= 0;
    else if(mainintt & tenflag)
    flagcnt <= 0;
    else if(mainntt|mainintt)
    flagcnt <= flagcnt + 4'd1;
    else if(!(mainntt|mainintt))
    flagcnt <= 0;
    else
    flagcnt <= flagcnt;
end

assign eightflag = flagcnt == 4'd7;
assign tenflag = flagcnt == 4'd9;

//RAM address
//READ
/*reg [AWID-1:0] rdaddrg;

always@(posedge clk) begin
    if(rst)
    rdaddrg <= 0;
    else
    if(mainntt & eightflag)
    rdaddrg <= rdaddrg + 5'd1;
    else if(mainintt & tenflag)
    rdaddrg <= rdaddrg + 5'd1;
    else if(!(mainntt|mainintt))
    rdaddrg <= 0;
    else
    rdaddrg <= rdaddrg;
end
*/
assign rdadd = (mainntt)? rdaddrgntt : 
                maindataout? docnt : 5'd0;

/////////////

reg [AWID-1:0] rdaddrg;

always@(posedge clk) begin
    if(rst)
    rdaddrg <= 0;
    else
    if(mainntt & eightflag)
    rdaddrg <= rdaddrg + 5'd1;
    else if(!(mainntt|mainintt))
    rdaddrg <= 0;
    else
    rdaddrg <= rdaddrg;
end

//WRITE
//first time take 22 clock
//first time counter
reg [4:0] wrflcnt;//write flag counter
reg firstwrite;

wire eightwrfl, tenwrfl; //16+2 and 20+2 appearently

always @(posedge clk) begin
    if(rst)
    wrflcnt <= 0;
    else
    if(!firstwrite)
    wrflcnt <= 0;
    else if(mainntt & eightwrfl)
    wrflcnt <= 0;
    else if(mainintt & tenwrfl)
    wrflcnt <= 0;
    else if(mainntt|mainintt)
    wrflcnt <= wrflcnt + 4'd1;
    else if(!(mainntt|mainintt))
    wrflcnt <= 0;
    else
    wrflcnt <= wrflcnt;
end

assign eightwrfl = wrflcnt == 5'd17;
assign tenwrfl = wrflcnt == 5'd22;

always @(posedge clk) begin
   if(rst)
   firstwrite <= 1'b1;
   else
   if(mainntt & eightwrfl)
   firstwrite <= 1'b0;
   else if(mainintt & tenwrfl)
   firstwrite <= 1'b0;
   else if(!(mainntt|mainintt))
   firstwrite <= 1'b1;
   else
   firstwrite <= firstwrite;
end

////

reg [AWID-1:0] wraddrg;

always@(posedge clk) begin
    if(rst)
    wraddrg <= 0;
    else
    if(firstwrite)
    wraddrg <= 0;
    if(mainntt & eightflag)
    wraddrg <= wraddrg + 5'd1;
    else if(mainintt & tenflag)
    wraddrg <= wraddrg + 5'd1;
    else if(!(mainntt|mainintt))
    wraddrg <= 0;
    else
    wraddrg <= wraddrg;
end

assign wradd = maindatain? data_in_add : wraddrg;

reg wrenrg;

always @(posedge clk) begin
    if(rst)
    wrenrg <= 0;
    else
    if(firstwrite)
    wrenrg <= 0;
    if(mainntt & eightflag)
    wrenrg <= 1'b1;
    else if (maindatain&caldone) //fix for data_in
    wrenrg <= 1'b0;
    else if(mainintt & tenflag)
    wrenrg <= 1'b1;
    else if(maindatain)
    wrenrg <= 1'b1;
    else if(startdatain)
    wrenrg <= 1'b1;
    else
    wrenrg <= 0;
end

assign wren = wrenrg;

///dang xai chung write flag voi eight flag hinh nhu tui no trung nhau


////////////////
//dataout
wire data_out_done;

always @(posedge clk) begin
    if(rst)
    docnt <= 0;
    else if(maindatain|maindataout)
    docnt <= docnt + 5'd1;
    else if(!(maindatain|maindataout))
    docnt <= 0;
    else
    docnt <= docnt;
end

assign data_out = mainidle? 1'b0 : rddata;
assign data_out_done = docnt == 5'd31;

////////////////////
//calculation done logic

assign caldone = maindatain? data_in_done :
                maindataout? data_out_done :
                mainntt? ntt_done :
                mainintt? intt_done :
                1'b0;

///////////////////////
//NTT/INTT logic

//read rom //temp
assign rdadd00 = mopt+jcnt; // m + j
assign rdadd10 = {rdadd00[5:0],1'b0}; //2*(m+j)
assign rdadd11 = {rdadd00[5:0],1'b1}; //2*(m+j)+1

//////////////
//read/write seq data

mem_gen3 imem_gen4(clk,nttcycle,wrenrom,nttadd);

//state machine //NTT FSM
reg [2:0] nfsm;

wire nfsmidle;

assign nfsmidle = nfsm == N_IDLE;

wire nfsmcy1;

assign nfsmcy1 = nfsm == N_CY1;

wire nfsmcy2;

assign nfsmcy2 = nfsm == N_CY2;

wire nfsmcy3;

assign nfsmcy3 = nfsm == N_CY3;

wire nfsmcy4;

assign nfsmcy4 = nfsm == N_CY4;

wire nfsmcy5;

assign nfsmcy5 = nfsm == N_CY5;

reg [7:0] nttcycle; //max to 160
wire sixrelease;
reg [2:0] sixcnt;

reg ntthalt;
wire nttendc1,nttendc2,nttendc3,nttendc4,nttendc5;

assign nttendc1 = nttcycle == 8'd31;
assign nttendc2 = nttcycle == 8'd63;
assign nttendc3 = nttcycle == 8'd95;
assign nttendc4 = nttcycle == 8'd127;
assign nttendc5 = nttcycle == 8'd159;

always @(posedge clk) begin
    if(rst)
    nfsm <= N_IDLE;
    else if(mainntt)
    nfsm <= N_CY1;
    else if(nfsmcy1&sixrelease)
    nfsm <= N_CY2;
    else if(nfsmcy2&sixrelease)
    nfsm <= N_CY3;
    else if(nfsmcy3&sixrelease)
    nfsm <= N_CY4;
    else if(nfsmcy4&sixrelease)
    nfsm <= N_CY5;
    else if(nfsmcy5&sixrelease)
    nfsm <= N_IDLE;
    else
    nfsm <= nfsm;
end

//ntthalt
always @(posedge clk) begin
    if(rst)
    ntthalt <= 0;
    else if(sixrelease)
    ntthalt <= 0;
    else if(nttendc1)
    ntthalt <= 1;
    else if(nttendc2)
    ntthalt <= 1;
    else if(nttendc3)
    ntthalt <= 1;
    else if(nttendc4)
    ntthalt <= 1;
    else if(nttendc5)
    ntthalt <= 1;
    else
    ntthalt <= ntthalt;
end
//ntt cycle counter

always @(posedge clk) begin
    if(rst)
    nttcycle <= 0;
    else if(!ntthalt|!nfsmidle)
    nttcycle <= nttcycle + 8'd1;
    else if(nfsmidle)
    nttcycle <= 0;
    else
    nttcycle <= nttcycle;
end

//count 6 cycle delay between each stage
always @(posedge clk) begin
    if(rst)
    sixcnt <= 0;
    else
    if(ntthalt)
    sixcnt <= sixcnt + 1'b1;
    else if(!ntthalt)
    sixcnt <= 0;
    else
    sixcnt <= sixcnt;
end

assign sixrelease = sixcnt == 6;

//wreno for sipos sequence
assign wreno = nttcycle[1:0];

endmodule