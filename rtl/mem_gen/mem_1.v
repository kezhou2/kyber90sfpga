module mem_1 (clk, addr, wr_ena, data);
parameter DATA_WIDTH = 3;
input clk;
input [10:0] addr;
input wr_ena;
output [DATA_WIDTH-1:0] data;
reg [DATA_WIDTH-1:0] data;
always@(posedge clk) begin
 case (addr)
    0: data <= 3'b000;
    1 : data <= 3'b111;
    2 : data <= 3'b110;
    3 : data <= 3'b101;
    4 : data <= 3'b100;
    5 : data <= 3'b011;
    6 : data <= 3'b010;
    7 : data <= 3'b111;
    8 : data <= 3'b110;
    9 : data <= 3'b100;
    10 : data <= 3'b101;
    default : data <= 0;
    endcase
end
endmodule
