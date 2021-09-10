////////////////////////////////////////////////////////////////////////////////
//
// Ho Chi Minh City University of Technology
//
// Filename     : auc_wmul_main.v
// Description  : .
//
// Author       : Vuong Dinh Hung (1511422)
// Created On   : Tue Apr 30 01:14:24 2019
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module auc_wmul_main
    (
     clk,
     rst,
     // Input
     main_en,
     main_dbl_end,
     main_add_end,
     main_naf_rdy,
     main_naf_last,
     main_paddx,
     main_paddy,
     main_paddz,
     main_nplus,
     // Output
     main_dbl_en,
     main_add_en,     
     main_shft,
     //=========
     main_dbl,
     main_ram_1st,
     main_done,   
     // RAM control
     main_radd,
     main_rdat,
     main_wen,
     main_wadd,
     main_wdat
     );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

parameter           WIDTH   = 256;
parameter           ADDR    = 5;

localparam          INIT    = 0;

localparam          X_G     = 0;
localparam          Y_G     = 1;
localparam          X_3G    = 2;
localparam          Y_3G    = 3;
localparam          Z_3G    = 4;
localparam          X_5G    = 5;
localparam          Y_5G    = 6;
localparam          Z_5G    = 7;
localparam          X_7G    = 8;
localparam          Y_7G    = 9;
localparam          Z_7G    = 10;

localparam          K_NUM   = 11;
localparam          K_INV   = 12;
localparam          R_NUM   = 13;
localparam          S_NUM   = 14;
localparam          X_KG    = 15;
localparam          HASH    = 16;
localparam          PKEY    = 17;
localparam          ZRRAM   = 18;   // NEED FIX
localparam          ONERAM  = 19;   // NEED FIX

localparam          TEMP0   = 20;
localparam          TEMP1   = 21;
localparam          TEMP2   = 22;
localparam          TEMP3   = 23;
localparam          TEMP4   = 24;
localparam          TEMP5   = 25;
localparam          TEMP6   = 26;   
localparam          TEMP7   = 27;
localparam          TEMP8   = 28;

localparam          S_RP    = 29;
localparam          S_RPH   = 30;
localparam          BLNK    = 31;

// local state

localparam          READ_XG = 4'd0;
localparam          READ_YG = 4'd1;
localparam          READ_ZG = 4'd2;
localparam          WRITE_XG    = 4'd3;
localparam          WRITE_YG    = 4'd4;
localparam          WRITE_ZG    = 4'd5;
localparam          DOUBLE  = 4'd6;
localparam          ADD     = 4'd7;
localparam          DONE    = 4'd8;


////////////////////////////////////////////////////////////////////////////////
// Port declarations

input               clk;
input               rst;

input               main_en;
input               main_dbl_end;
input               main_add_end;
input               main_naf_rdy;
input               main_naf_last;
input [ADDR-1:0]    main_paddx;
input [ADDR-1:0]    main_paddy;
input [ADDR-1:0]    main_paddz;
input               main_nplus;

output              main_dbl_en;
output              main_add_en;
output              main_shft;

output              main_dbl;
output              main_ram_1st;
output              main_done;

output [ADDR-1:0]   main_radd;
input [WIDTH-1:0]   main_rdat;
output              main_wen;
output [ADDR-1:0]   main_wadd;
output [WIDTH-1:0]  main_wdat;

////////////////////////////////////////////////////////////////////////////////
// Output declarations

reg                 main_dbl_en;
reg                 main_add_en;
reg                 main_shft;

reg                 main_dbl;
reg                 main_ram_1st;
reg                 main_done;

reg [ADDR-1:0]      main_radd;
reg                 main_wen;
reg [ADDR-1:0]      main_wadd;

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

reg [3:0]           main_step;

wire [3:0]          main_step_inc;
assign              main_step_inc = main_step + 1'b1;

wire [3:0]          main_step_dec;
assign              main_step_dec = main_step - 1'b1;

assign              main_wdat = main_rdat;

reg                 main_init_done;
always @(posedge clk)
    begin
    if (main_step == WRITE_ZG)
        main_init_done  <= 1'b1;
    else
        main_init_done  <= 1'b0;
    end

//================================================

reg                 main_en_sticky;

always @(posedge clk)
    begin
    if (rst)
        begin
        main_dbl_en <= INIT;
        main_add_en <= INIT;
        main_done   <= INIT;
        main_shft   <= INIT;
        //==================
        main_dbl    <= INIT;
        main_ram_1st <= INIT;       
        main_step   <= INIT;
        //==================
        main_radd   <= INIT;
        main_wen    <= INIT;
        main_wadd   <= INIT;
        //==================
        main_en_sticky  <= INIT;        
        end
    else if (main_en)
        begin
        main_dbl_en <= INIT;
        main_add_en <= INIT;
        main_done   <= INIT;
        main_shft   <= INIT;
        //==================
        main_dbl    <= INIT;
        main_ram_1st <= 1'b1;
        main_step   <= INIT;
        //==================
        main_radd   <= INIT;
        main_wen    <= INIT;
        main_wadd   <= INIT;  
        //==================
        main_en_sticky  <= 1'b1;      
        end
    else if (main_en_sticky)
        begin
        case(main_step)
            READ_XG:
                begin
                main_dbl_en <= INIT;
                main_add_en <= INIT;
                main_done   <= INIT;
                main_shft   <= INIT;
                //==================    
                main_dbl    <= INIT;
                main_ram_1st <= 1'b1;
                main_step   <= main_step_inc;
                //==================
                main_radd   <= main_paddx;
                main_wadd   <= TEMP0;
                main_wen    <= 1'b0;
                //==================
                main_en_sticky  <= 1'b1;
                end
            READ_YG:
                begin
                main_dbl_en <= INIT;
                main_add_en <= INIT;
                main_done   <= INIT;
                main_shft   <= INIT;
                //==================
                main_dbl    <= INIT;
                main_ram_1st <= 1'b1;
                main_step   <= main_step_inc;
                //==================
                main_radd   <= main_paddy;
                main_wadd   <= TEMP0;
                main_wen    <= 1'b0;
                //==================
                main_en_sticky  <= 1'b1;
                end
            READ_ZG:
                begin
                main_dbl_en <= INIT;
                main_add_en <= INIT;
                main_done   <= INIT;
                main_shft   <= 1'b1;                // read NAF MSB done    
                //==================
                main_dbl    <= INIT;
                main_ram_1st <= 1'b1;
                main_step   <= main_step_inc;
                //==================
                main_radd   <= main_paddz;
                main_wadd   <= TEMP0;
                main_wen    <= 1'b0;
                //==================
                main_en_sticky  <= 1'b1;
                end
            WRITE_XG:
                begin
                main_dbl_en <= INIT;
                main_add_en <= INIT;
                main_done   <= INIT;
                main_shft   <= INIT;
                //==================
                main_dbl    <= INIT;
                main_ram_1st <= 1'b1;
                main_step   <= main_step_inc;
                //==================
                main_radd   <= main_radd;
                main_wadd   <= TEMP0;
                main_wen    <= 1'b1;
                //==================
                main_en_sticky  <= 1'b1;
                end
            WRITE_YG:
                begin
                main_dbl_en <= INIT;
                main_add_en <= INIT;
                main_done   <= INIT;
                main_shft   <= INIT;
                //==================
                main_dbl    <= INIT;
                main_ram_1st <= 1'b1;
                main_step   <= main_step_inc;
                //==================
                main_radd   <= main_radd;
                main_wadd   <= TEMP1;
                main_wen    <= 1'b1;
                //==================
                main_en_sticky  <= 1'b1;
                end
            WRITE_ZG:
                begin
                main_dbl_en <= INIT;
                main_add_en <= INIT;
                main_done   <= INIT;
                main_shft   <= INIT;                
                //==================
                main_dbl    <= INIT;
                main_ram_1st <= 1'b1;
                main_step   <= main_step_inc;
                //==================
                main_radd   <= main_radd;
                main_wadd   <= TEMP2;
                main_wen    <= 1'b1;
                //==================
                main_en_sticky  <= 1'b1;
                end
            DOUBLE:
                if (main_add_end || main_init_done || main_nplus)
                    begin
                    main_dbl_en <= main_naf_rdy;
                    main_add_en <= INIT;
                    main_done   <= INIT;
                    main_shft   <= ~main_init_done & main_naf_rdy;
                    //==================
                    main_dbl    <= 1'b1;
                    main_ram_1st <= 1'b0;
                    main_step   <= main_naf_rdy? main_step_inc: DONE;
                    //==================
                    main_radd   <= main_radd;
                    main_wadd   <= main_wadd;
                    main_wen    <= 1'b0;
                    //==================
                    main_en_sticky  <= 1'b1;
                    end
                else
                    begin
                    main_dbl    <= INIT;
                    main_add_en <= INIT;
                    end
            ADD:
                if (main_dbl_end)
                    begin
                    main_dbl_en <= INIT;
                    main_add_en <= ~main_nplus;
                    main_done   <= INIT;
                    main_shft   <= INIT;
                    //==================
                    main_dbl    <= INIT;
                    main_ram_1st <= 1'b0;
                    main_step   <= (main_naf_rdy & ~main_naf_last)? 
                                   main_step_dec: main_step_inc;
                    //==================
                    main_radd   <= main_radd;
                    main_wadd   <= main_wadd;
                    main_wen    <= 1'b0;
                    //==================
                    main_en_sticky  <= 1'b1;
                    end
                else
                    begin
                    main_dbl_en <= INIT;
                    main_shft   <= INIT;
                    end
            DONE:
                if (main_add_end | ~main_naf_rdy | (main_naf_last & main_nplus))
                    begin
                    main_dbl_en <= INIT;
                    main_add_en <= INIT;
                    main_done   <= 1'b1;
                    main_shft   <= INIT;
                    //==================
                    main_dbl    <= INIT;
                    main_ram_1st <= 1'b0;
                    main_step   <= main_step_inc;
                    //==================
                    main_radd   <= main_radd;
                    main_wadd   <= main_wadd;
                    main_wen    <= 1'b0;
                    //==================
                    main_en_sticky  <= 1'b1;
                    end
                else
                    begin
                    main_add_en <= INIT;
                    main_done   <= INIT;
                    end
            default:
                begin
                main_dbl_en <= INIT;
                main_add_en <= INIT;
                main_done   <= INIT;
                main_shft   <= INIT;
                //==================
                main_dbl    <= INIT;
                main_ram_1st <= INIT;
                main_step   <= INIT;
                //==================
                main_radd   <= INIT;
                main_wen    <= INIT;
                main_wadd   <= INIT;  
                //==================
                main_en_sticky  <= 1'b0;
                end
        endcase
        end
    end

endmodule 
