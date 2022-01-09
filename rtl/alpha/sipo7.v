module sipo7 (clk, rst, di, do);
parameter IWID = 12;
parameter OWID = IWID*7;
input clk;
input rst;
input [IWID-1:0] di;
output [IWID*4-1:0] do;

reg [OWID-1:0] siporeg;

always @(posedge clk) begin
    if(rst)
    begin
    siporeg <= 0;
    end
    else
    begin
    siporeg[11:0] <= di;
    siporeg[23:12] <= siporeg[11:0];
    siporeg[35:24] <= siporeg[23:12];
    siporeg[47:36] <= siporeg[35:24];
    siporeg[59:48] <= siporeg[47:36];
    siporeg[71:60] <= siporeg[59:48];
    siporeg[OWID-1:OWID-1-11] <= siporeg[71:60];
    end
end

assign do = siporeg[OWID-1:36];

endmodule