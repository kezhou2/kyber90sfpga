`timescale 1ns/1ps
module tb_k2red;

reg clk;
reg t_rst;

always begin
clk = 0;
#1 clk=1;
#1;
end
//input reg/output wire

reg [23:0] c;
red [11:0] cred;
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
c = 0;
t_rst = 1'b0;
#3 t_rst = 1'b1;
#2 t_rst = 1'b0;
#100;
c = 24'd3330;
#100;
c = 24'd99999;
#100;
c = 24'd65536;
#100;
c = 24'd600000;
#200;
#100;
$finish;
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