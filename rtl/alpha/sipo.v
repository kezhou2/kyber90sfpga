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
    siporeg <= {siporeg[35:0],di};
end

endmodule