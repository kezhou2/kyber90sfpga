module tb_sha256_transform;

////////clock generator//////////
reg clk;

always begin
clk = 0;
#1 clk=1;
#1;
end

///////////////reg-wire//////////////

reg feedback;
reg [5:0] cnt;
reg [255:0] rx_state;
reg [511:0] rx_input;
wire [255:0] tx_hash;

////////////////////////////////

sha256_transform isha256_transform(
	.clk(clk),
	.feedback(),
	.cnt(),
	.rx_state(),
	.rx_input(),
	.tx_hash()
);

initial begin
	cnt = 6'b0;
end
