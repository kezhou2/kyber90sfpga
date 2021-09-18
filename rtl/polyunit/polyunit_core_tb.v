module poly_mod_core_tb ();

///////////////////////////////////

parameter WIDTH = 12;

//////////not functional testbench

reg [WIDTH-1:0] data_in_tb;
wire [WIDTH-1:0] data_out_tb;

////////////////////////////////////

always begin
clk = 0;
#1 clk =1;
#1;
end

/////////////////////////////

initial begin

end

polyunit_core #(
    .clk(clk),
    .rst(rst),
    
    .data_in(data_in_tb),
    .data_out(data_out_tb), //NTT RAM

    .mode(mode_tb),//see param
    .run(run_tb),
    .done(done_tb)
);

always begin

end
endmodule