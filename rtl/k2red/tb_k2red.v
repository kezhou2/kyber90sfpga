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

reg [23:0] counter;

initial begin
    counter = 0;
while(counter<=(2**23)) begin
//$display ("DZO NE`");
c = counter;
#1;
if (cred != ((169*c)%3329))
begin
$display ("SAI O c = %d",c," ket qua la %d",(169*c)%3329," nhung lai tinh ra la %d",cred);
$finish;
end
counter = counter + 1;
end
end
/*
#100;
c = 24'd99999;
#1;
if (cred != ((169*c)%3329))
begin
$display ("SAI O c = %d",c," ket qua la %d",(169*c)%3329," nhung lai tinh ra la %d",cred);
$finish;
end
#100;
c = 24'd133456;
#1;
if (cred != ((169*c)%3329))
begin
$display ("SAI O c = %d",c," ket qua la %d",(169*c)%3329," nhung lai tinh ra la %d",cred);
$finish;
end
#100;
c = 24'd600000;
#1;
if (cred != ((169*c)%3329))
begin
$display ("SAI O c = %d",c," ket qua la %d",(169*c)%3329," nhung lai tinh ra la %d",cred);
$finish;
end
#100;
c = 24'd16777;
#1;
if (cred != ((169*c)%3329))
begin
$display ("SAI O c = %d",c," ket qua la %d",(169*c)%3329," nhung lai tinh ra la %d",cred);
$finish;
end
#100;
c = 2**16;
#1;
if (cred != ((169*c)%3329))
begin
$display ("SAI O c = %d",c," ket qua la %d",(169*c)%3329," nhung lai tinh ra la %d",cred);
$finish;
end
#100;
c = 24'd223;
#1;
if (cred != ((169*c)%3329))
begin
$display ("SAI O c = %d",c," ket qua la %d",(169*c)%3329," nhung lai tinh ra la %d",cred);
$finish;
end
end
*/


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