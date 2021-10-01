module butterfly_tb ();

///////////////////////////////////

parameter WIDTH = 12;

//////////not functional testbench
reg rsttb;
reg [1:0] seltb;
reg [WIDTH-1:0] atb,btb,wtb;
wire [WIDTH-1:0] ctb,dtb;
////////////////////////////////////

always begin
clktb = 0;
#1 clktb =1;
#1;
end

/////////////////////////////

butterfly #(WIDTH) ibutterfly(
    .clk(clktb),
    .rst(rsttb),

    .a(atb),//input 12-bit
    .b(btb),
    .w(wtb),

    .c(ctb),
    .d(dtb),

    .sel(seltb) //mode of operation 1: NTT:0 INTT:1 BYPASS:2
);

/////////////////////////////

initial begin
rsttb = 1'b1;
#10;
rsttb = 1'b0;
seltb = 2'd2;
#50 atb = $random;
btb = $random;
wtb = $random;
#10;
end

endmodule