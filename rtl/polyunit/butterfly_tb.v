module butterfly_tb ();

///////////////////////////////////

parameter WIDTH = 12;

//////////not functional testbench
reg rst;

reg [WIDTH-1:0] data_in_tb;
wire [WIDTH-1:0] data_out_tb;

////////////////////////////////////

always begin
clk = 0;
#1 clk =1;
#1;
end

/////////////////////////////

butterfly #(WIDTH) ibutterfly(
    .clk,
    .rst,

    .a,//input 12-bit
    .b,
    .w,

    .c,
    .d,

    .sel //mode of operation 1: NTT:0 INTT:1 BYPASS:2
);

/////////////////////////////

initial begin

end


always begin

end
endmodule