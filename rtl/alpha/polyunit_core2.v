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
reg [2:0] main_state;

wire mainidle;

assign mainidle = main_state == P_IDLE;

wire startntt;

assign startntt = mainidle & (mode == 2'b01) & run;

wire startintt;

assign startintt = mainidle & (mode == 2'b10) & run; 

wire startdatain;

assign startdatain = mainidle & (mode == 2'b00) & run; 

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
//main ROM (w)
wire wrenrom;

mem_gen1 #(DWID) imem_gen1
(
    .clk(clk),
    .addr(rdadd),
    .wr_ena(wrenrom),
    .data(romdata)
);

/////////////////////////////////////////////


endmodule