`timescale 1ps/1ps
module tb_k2red;

//reg clk;
/*
always begin
clk = 0;
#1 clk=1;
#1;
end
*/
//input reg/output wire

reg [23:0] c;
wire [11:0] cred;
//instant

k2red ik2red
(
    //clk,
    //rst,
    .c(c),
    .cred(cred)
);

//operation

initial begin
//$display ("DZO NE`");
c = 1;
#100;
//$display ("DZO NE` 2");
c = 24'd3330;
#100;
c = 24'd99999;
#100;
c = 24'd65536;
#100;
c = 24'd600000;
#200;
#100;
end


initial begin
$display ("==========OUTPUT FOR Q = 3329==========");
end


initial begin
$monitor ("c = %d",c," and c reduction = %d",cred);
end

/*
always@(posedge clk) begin
if(vld)
    begin
    $display ("Output : %d ", r);
    $display ("Output : %d ", rswap);
    end
end
*/

//dump wave
//initial begin
//$shm_open ("my_waves");
//$shm_probe (tb_aluwrap,"AC");
//$recordfile("testsample.trn");
//$recordvars();
//end

endmodule