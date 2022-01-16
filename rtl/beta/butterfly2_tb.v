module butterfly2_tb ();
parameter WID = 12;

reg [WID-1:0] u,t,w;
reg clk,rst;
reg [1:0] sel;
reg fail;
reg start;
wire [WID-1:0] s0,s1;

always begin
clk = 0;
#1 clk =1;
#1;
end

initial begin
    fail = 0;
    rst = 1;
    u=0;
    t=0;
    w=0;
    sel = 0;
    #49;
    rst = 0;
    start = 1;
    sel[0] = 1; //NTT
    sel[1] = 0; //not bypass
    #50;
    sel[0] = 1; //NTT
    sel[1] = 1; //bypass
    #50;
    start = 0;
    u=0;
    t=0;
    w=0;
    #50;
    start = 1;
    sel[0] = 0; //INTT
    sel[1] = 0; //not bypass
    #50;
    sel[0] = 0; //NTT
    sel[1] = 1; //bypass
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

always@(posedge clk) begin
  if(start)
  begin
  u = $random;
  t = $random;
 w = $random;
  end
end

endmodule
