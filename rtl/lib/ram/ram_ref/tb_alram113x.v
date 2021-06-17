module tb_alram113x;

parameter WID = 256;
parameter AWID = 5; //address width
parameter DEP = 1<<AWID;

reg       clk;
reg       rst;
//clk
always begin
clk = 0;
#50 clk=1;
#50;
end

//define
reg [AWID-1:0] ra;
reg [AWID-1:0] wa;
reg [WID-1:0] wdi;
reg           we;

wire [WID-1:0] rdo;

//isntant
alram113x ialram113x
    (
     .clkw(clk),//clock write
     .clkr(clk),//clock read
     .rst(rst),
     
     .rdo(rdo),//data from ram
     .ra(ra),//read address
     
     .wdi(wdi),//data to ram
     .wa(wa),//write address
     .we(we) //write enable
     );

//simu
initial begin
rst = 1;
#50 rst = 0;
we = 1;
wa = 5'd12;
wdi = 256'd1230;
#50;
we = 0;
#50;
ra = 5'd12;
we = 1;
wa = 5'd13;
wdi = 256'd1330;
#50;
we = 0;
#1000;
$stop;
end
endmodule