module polyunit_core(
    clk,
    rst,
    
    data_in,
    data_out, //NTT RAM
    add_in,
    add_out,

    mode,//00 Data_in 01 NTT 11 INTT
    done
);
////////////////////////////
parameter DATWID = 12;
parameter ADDWID = 7;//128 unit

//poly statemachine
localparam          POLYWID     = 2;
localparam          P_IDLE      = 2'd0;
localparam          P_NTT       = 2'd1;//
localparam          P_INTT      = 2'd2;//
localparam          P_BYPASS    = 2'd3;//
////////////////////////////
input    clk;
input    rst;
    
input [DATWID-1:0] data_in;
input [DATWID-1:0] data_out; //NTT RAM
input [ADDWID-1:0] add_in;
input [ADDWID-1:0] add_out;

input [1:0] mode;//mode of operation
input run;

output done;
/////////////////////////////////



/////////////////////////////////
endmodule