module polyunit_core2(
    clk,
    rst,
    
    data_in,
    data_out, //NTT RAM

    mode,//see param
    run,
    done
);
/////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////

parameter WID   = 12;
parameter DWID = WID*4; //RAM DATAWID
parameter ADDWID = 5;//32 address ram

//poly statemachine
localparam          POLYWID     = 3;
localparam          P_IDLE      = 3'd0;
localparam          P_NTT       = 3'd1;//
localparam          P_INTT      = 3'd2;//
localparam          P_DATAIN    = 3'd4;//

/////////////////////////////////////////////////////////

input    clk;
input    rst;
    
input [DWID-1:0] data_in;
input [DWID-1:0] data_out; //NTT RAM

input [1:0] mode;//mode of operation // NTT 01 or INTT 10 or datain 00
input run;

output done;

/////////////////////////////////////////////////////////
///////FSM////////
reg [2:0] main_state;

wire mainidle;

assign mainidle = main_state == P_IDLE;

wire startntt;

assign startntt = mainidle & (mode == 2'b01) & run;

wire startintt;

assign startintt = mainidle & (mode == 2'b10) & run; 

wire startdatain;

assign startdatain = mainidle & (mode == 2'b00) & run; 

wire mainntt;

assign mainntt = main_state == P_NTT;

wire mainintt;

assign mainintt = main_state == P_INTT;

wire maindatain;

assign maindatain = main_state == P_DATAIN;

always @(posedge clk) begin
    if(rst)
    main_state <= P_IDLE;
    else
    if(startntt)
    main_state <= P_NTT;
    else if (startintt)
    main_state <= P_INTT;
    else if (startdatain)
    main_state <= P_DATAIN;
    else if (done)
    main_state <= P_IDLE;
    else
    main_state <= main_state;
end

/////////////////////////////////////////////
//main RAM
wire wren;
wire [DWID-1:0] rddata,wrdata;
wire [AWID-1] rdadd,wradd;


alram112x #(DWID,ADDWID) ialram112x
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

assign butwrdata = {u20,t20,u21,t21};

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
reg [AWID-1:0] rdaddrg;

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

assign rdadd = rdaddrg;

//WRITE
//first time take 22 clock


endmodule