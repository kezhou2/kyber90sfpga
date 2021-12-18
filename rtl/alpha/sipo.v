module sipo (clk, rst, di, do);
parameter IWID = 12;
parameter OWID = 48;
input clk;
input rst;
input [IWID-1:0] di;
output [OWID-1:0] do;

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
    end
end

assign do = siporeg;

endmodule