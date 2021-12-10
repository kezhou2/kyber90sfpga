module butterfly2_tb ();
parameter WID = 12;

reg [WID-1:0] u,t,w;
reg clk,rst;
reg sel;
reg fail;

wire [WID-1:0] s0,s1;

always begin
clk = 0;
#1 clk =1;
#1;
end

initial begin
    fail = 0;
    rst = 1;
    #50;
    rst = 0;
    sel = 0; //INTT 
end

butterfly2 ibutterfly2 (
    .clk(clk),
    .rst(rst),

    .u(u),//input 12-bit
    .t(t),
    .w(w),

    .s0(s0),
    .s1(s1),

    .sel(sel) //mode of operation NTT:1 INTT:0
);

always begin
  #500 u = $random;
  t = $random;
  w = $random;
end
endmodule
