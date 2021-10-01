module mem_gen2 (clk, addr, wr_ena, data);
parameter DATA_WIDTH = 12;
input clk;
input [6:0] addr;
input wr_ena;
output [DATA_WIDTH-1:0] data;
reg [DATA_WIDTH-1:0] data;
always@(posedge clk) begin
 case (addr)
    0: data <= 12'b0;
    1 : data <= 12'b111;
    2 : data <= 12'b110;
    3 : data <= 12'b101;
    4 : data <= 12'b100;
    5 : data <= 12'b011;
    6 : data <= 12'b010;
    7 : data <= 12'b111;
    8 : data <= 12'b110;
    9 : data <= 12'b100;
    10 : data <= 12'b101;
    default : data <= 0;
    endcase
end
endmodule
