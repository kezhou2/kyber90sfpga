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
wire ntt_donedelay;

wire wrenntt;

reg [4:0] docnt; // three two counter
//reg [4:0] dicnt; // three two counter

wire ntt_done;
wire intt_done;

reg [2:0] nfsm;

wire nfsmidle;

assign nfsmidle = nfsm == N_IDLE;

//wire nfsmcy1;

//assign nfsmcy1 = nfsm == N_CY1;

//wire nfsmcy2;

//assign nfsmcy2 = nfsm == N_CY2;

//wire nfsmcy3;

//assign nfsmcy3 = nfsm == N_CY3;

wire nfsmcy4;

assign nfsmcy4 = nfsm == N_CY4;

reg [6:0] nttcycle; //max to 127
wire sixrelease;
reg [2:0] sixcnt;

reg ntthalt;
wire nttendc1,nttendc2,nttendc3,nttendc4;

wire [4:0] nttadd;
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

//assign ntt_done = 1'b0;
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
wire [5:0] rdadd00,rdadd10,rdadd11;//64 
wire [17:0] triromadd;

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

mem_gen4 #(18) imem_gen11
(
    .clk(clk),
    .addr(nttcycle), //using with 
    .wr_ena(wrenrom),
    .data(triromadd)
);

assign wrenrom = 1'b0; //gan gia tri tranh float

//ROM address logic (temp of course)

assign rdadd00 = triromadd[5:0];

assign rdadd10 = triromadd[11:6];

assign rdadd11 = triromadd[17:12];

/////////////////////////////////////////////
//main butterflys
wire [1:0] butsel1,butsel2;
wire bypass1,bypass2;

assign bypass1 = nfsmcy4;
assign bypass2 = 1'b0;

assign butsel1 = {bypass1,mainntt};
assign butsel2 = {bypass2,mainntt};

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

    .sel(butsel1) //mode of operation NTT:1 INTT:0
);

butterfly2 ibutterfly2(
    .clk(clk),
    .rst(rst),

    .u(u01),//input 12-bit
    .t(t01),
    .w(w00),

    .s0(u11),
    .s1(t11),

    .sel(butsel1) //mode of operation NTT:1 INTT:0
);

butterfly2 ibutterfly3(
    .clk(clk),
    .rst(rst),

    .u(u10),//input 12-bit
    .t(u11),
    .w(w10),

    .s0(u20),
    .s1(t20),

    .sel(butsel2) //mode of operation NTT:1 INTT:0
);

butterfly2 ibutterfly4(
    .clk(clk),
    .rst(rst),

    .u(t10),//input 12-bit
    .t(t11),
    .w(w11),

    .s0(u21),
    .s1(t21),

    .sel(butsel2) //mode of operation NTT:1 INTT:0
);

//with delay;

assign u00 = rddata[11:0];
assign t00 = rddata[35:24];
assign u01 = rddata[23:12];//doi nguoc chieu` 0x64
assign t01 = rddata[47:36];

wire [WID-1:0] romdata00d,romdata10d,romdata01d;

ffxkclkx #(2,WID) iffxkclkx66 (clk,rst,romdata00,romdata00d);
ffxkclkx #(2,WID) iffxkclkx67 (clk,rst,romdata10,romdata10d);
ffxkclkx #(2,WID) iffxkclkx68 (clk,rst,romdata11,romdata11d);

assign w00 = romdata00d;
assign w10 = romdata10d;
assign w11 = romdata11d;

//to write back data to RAM

wire [DWID-1:0] butwrdata;
wire [DWID-1:0] butd1,butd2,butd3,butd4;
wire [1:0] wreno;//write enabler number

sipo isipo1 (clk,rst,u20,butd1);
sipo isipo2 (clk,rst,t20,butd2);
sipo isipo3 (clk,rst,u21,butd3);
sipo isipo4 (clk,rst,t21,butd4);

assign butwrdata = (wreno == 2'b01)? butd2:
                    (wreno == 2'b10)? butd3:
                    (wreno == 2'b11)? butd4:
                    butd1;

//data mux

assign wrdata = maindatain? data_in : butwrdata;

//////////The address logic/////////
//8-10-clock counter
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
assign rdadd = (mainntt)? nttadd : 
                maindataout? docnt : 5'd0;

/////////////
//WRITE
////
wire [4:0] nttadddelay;

ffxkclkx #(27,5) iffxkclkx5 (clk,rst,nttadd,nttadddelay);

//test delay

assign wradd = maindatain? data_in_add : nttadddelay;

/////////
//for data in
reg wrenrg;

always @(posedge clk) begin
    if(rst)
    wrenrg <= 0;
    else if (maindatain&caldone) //fix for data_in
    wrenrg <= 1'b0;
    else if(maindatain)
    wrenrg <= 1'b1;
    else if(startdatain)
    wrenrg <= 1'b1;
    else
    wrenrg <= 0;
end
//////////
assign wrenntt = !nfsmidle&!ntthalt;

wire wrennttdelay;
ffxkclkx #(27,1) iffxkclkx6 (clk,rst,wrenntt,wrennttdelay);

assign wren = maindatain? wrenrg :
                mainntt? wrennttdelay : 1'b0;

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

assign data_out = maindataout? rddata : 1'b0;
assign data_out_done = docnt == 5'd31;

////////////////////
//calculation done logic

assign caldone = maindatain? data_in_done :
                maindataout? data_out_done :
                mainntt? ntt_donedelay :
                mainintt? intt_done :
                1'b0;

///////////////////////
//NTT/INTT logic

//////////////
//read/write seq data

mem_gen3 imem_gen4(clk,nttcycle,wrenrom,nttadd);

//state machine //NTT FSM


assign nttendc1 = nttcycle == 7'd31;
assign nttendc2 = nttcycle == 7'd63;
assign nttendc3 = nttcycle == 7'd95;
assign nttendc4 = nttcycle == 7'd127;

always @(posedge clk) begin
    if(rst)
    nfsm <= N_IDLE;
    else if(startntt)
    nfsm <= N_CY1;
    else if(nttendc1)
    nfsm <= N_CY2;
    else if(nttendc2)
    nfsm <= N_CY3;
    else if(nttendc3)
    nfsm <= N_CY4;
    else if(nttendc4)
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
    else
    ntthalt <= ntthalt;
end

assign ntt_done = nttendc4;



ffxkclkx #(27,1) iffxkclkx65 (clk,rst,ntt_done,ntt_donedelay);

//ntt cycle counter

always @(posedge clk) begin
    if(rst)
    nttcycle <= 0;
    else if(nfsmidle)
    nttcycle <= 0;
    else if(!ntthalt)
    nttcycle <= nttcycle + 7'd1;
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
wire [1:0] nttcycledelay;

ffxkclkx #(27,2) iffxkclkx91 (clk,rst,nttcycle[1:0],nttcycledelay);

assign wreno = nttcycledelay;


endmodule