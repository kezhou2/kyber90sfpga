module polyunit_core(
    clk,
    rst,
    
    data_in,
    data_out, //NTT RAM
    add_in,
    add_out,

    mode,//see param
    run,
    done
);
////////////////////////////
parameter DATWID = 12;
parameter ADDWID = 7;//128 unit

//poly statemachine
localparam          POLYWID     = 3;
localparam          P_IDLE      = 3'd0;
localparam          P_NTT       = 3'd1;//
localparam          P_INTT      = 3'd2;//
localparam          P_BYPASS    = 3'd3;//
localparam          P_DATAIN    = 3'd4;//

//mode param
localparam          MODEWID     = 2;
localparam          M_DATAIN    = 2'd0;
localparam          M_NTT       = 2'd1;//
localparam          M_INTT      = 2'd2;//
localparam          M_BYPASS    = 2'd3;//

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
//POLY FSM
reg [POLYWID-1:0] poly_state;

wire      polyisidle; 

assign    polyisidle = poly_state == P_IDLE;

wire      polyisntt; 

assign    polyisntt = poly_state == P_NTT;

wire      polyisintt; 

assign    polyisintt = poly_state == P_INTT;

wire      polyisbypass; 

assign    polyisbypass = poly_state == P_BYPASS;

wire      polyisdatain; 

assign    polyisdatain = poly_state == P_DATAIN;

wire      polyisrun; 

assign    polyisrun = run;

always@(posedge clk)
    begin
    if(rst)
        begin
        poly_state <= P_IDLE;
        end
    else
        begin
        if(polyisrun & polyisidle & (mode == 2'b01))
            begin
            poly_state <= P_NTT;            
            end
        else if(polyisrun & polyisidle & (mode == 2'b11))
            begin
            poly_state <= P_INTT;    
            end
        else if(polyisrun & polyisidle & (mode == 2'b00))
            begin
            poly_state <= P_BYPASS;     
            end
        else if(polyisrun & polyisidle & (mode == 2'b11))
            begin
            poly_state <= P_BYPASS;     
            end
        end
    end

/////////////////////////////////
endmodule