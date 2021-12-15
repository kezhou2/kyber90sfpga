module polyunit_core2_tb ();

parameter WID = 12;

reg clk;
reg rst;


wire [47:0] data_in_tb;
wire [4:0] data_in_add_tb;
reg data_in_done_tb;

reg [1:0] mode_tb;
reg run_tb;
wire done_tb;

wire [47:0] data_out_tb;

//poly mode
localparam          M_NTT       = 2'd0;//
localparam          M_INTT      = 2'd1;//
localparam          M_DATAIN    = 2'd2;//
localparam          M_DATAOUT   = 2'd3;//

///to load data in
reg [5:0] dicnt;
reg loaddi;

always @(posedge clk) begin
    if(rst)
    dicnt <= 0;
    else if(loaddi)
    dicnt <= dicnt + 6'd1;
    else if(!loaddi)
    dicnt <= 0;
    else
    dicnt <= dicnt;
end

wire [5:0] tempdatain;

assign tempdatain = dicnt - 6'd1;
assign data_in_add_tb = tempdatain[4:0];

//main testbenchweq
always begin
clk = 0;
#1 clk =1;
#1;
end

polyunit_core2 ipolyunit_core2(
    .clk(clk),
    .rst(rst),
    
    .data_in(data_in_tb),
    .data_in_add(data_in_add_tb),
    .data_in_done(data_in_done_tb),

    .data_out(data_out_tb), //NTT RAM

    .mode(mode_tb),//see param
    .run(run_tb),
    .done(done_tb)
);

mem_gen2 #(48) imem_gen1
(
    .clk(clk),
    .addr(dicnt[4:0]), //using with 
    .wr_ena(1'b0),
    .data(data_in_tb)
);

initial begin
    
end

initial begin
    //begin testing datain function
    rst = 1'b1;
    data_in_done_tb = 1'b0;
    mode_tb = 0;
    run_tb = 0;
    loaddi = 0;
    #20 rst = 1'b0;
    #2;
    mode_tb = M_DATAIN;
    run_tb = 1'b1;
    loaddi =  1'b1;
    #2;
    run_tb = 1'b0;
    mode_tb = 0;
    #64
    loaddi = 1'b0;
    data_in_done_tb = 1'b1;
    #20
    //begin testing dataout function
    mode_tb = M_DATAOUT;
    run_tb = 1'b1;
    #2;
    run_tb = 1'b0;
    #200;
    //begin testing datain function
end

endmodule
