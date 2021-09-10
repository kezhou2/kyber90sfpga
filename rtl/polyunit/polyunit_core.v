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

wire      polyisrun; 

assign    polyisrun = run;

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

wire      modeisntt; 

assign    modeisntt = mode == M_NTT;

wire      modeisintt; 

assign    modeisintt = mode == M_INTT;

wire      modeisbypass; 

assign    modeisbypass = mode == M_BYPASS;

wire      modeisdatain; 

assign    modeisdatain = mode == M_DATAIN;

always@(posedge clk)
    begin
    if(rst)
        begin
        poly_state <= P_IDLE;
        end
    else
        begin
        if(polyisrun & polyisidle & modeisntt)
            begin
            poly_state <= P_NTT;            
            end
        else if(polyisrun & polyisidle & modeisintt)
            begin
            poly_state <= P_INTT;    
            end
        else if(polyisrun & polyisidle & modeisbypass)
            begin
            poly_state <= P_BYPASS;     
            end
        else if(polyisrun & polyisidle & modeisdatain)
            begin
            poly_state <= P_BYPASS;     
            end
        else if(polyisdone & !polyisidle)
            begin
            poly_state <= P_IDLE;     
            end
        else //default state because the sun
            begin
            poly_state <= poly_state;     
            end
        end
    end
//////////////////////////////
//BUFFER REWRITE TO RAM


/////////////////////////////
//ROM w00 w10 w11

mem_gen1 #(WID) imem_gen1 (clk,addr_mem1,wr_ena,data_mem1);//w00
mem_gen2 #(WID) imem_gen2 (clk,addr_mem2,wr_ena,data_mem2);//w10
mem_gen3 #(WID) imem_gen (clk,addr_mem3,wr_ena,data_mem3);//w11

////////////////////////////
//NTT_RAM
alram112x #(WID) ialram112x
    (
     .clkw(),//clock write
     .clkr(),//clock read
     .rst(),
     
     .rdo(),//data from ram
     .ra(),//read address
     
     .wdi(),//data to ram
     .wa(),//write address
     .we() //write enable
     );
/////////////////////////////////
endmodule