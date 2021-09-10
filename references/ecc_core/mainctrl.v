 ////////////////////////////////////////////////////////////////////////////////
//
// Ho Chi Minh City University of Technology
//
// Filename     : mainctrl.v
// Description  : Controller for main operation ecdsa ecdhe
//
// Author       : Vuong Dinh Hung (1511422)
// Created On   : Sun Mar 31 15:31:23 2019
// History (Date, Changed By)
// //changed by Hung to 762 bit input
////////////////////////////////////////////////////////////////////////////////

module mainctrl
    (
     clk,
     rst,
     // IP core
     din, //3*WID
     mode,
     start,
     dout,
     status,
     // AUC controller
     auc_dat,
     auc_start,
     auc_mode,
     auc_rslt,
     auc_status
     );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

parameter       WIDTH   = 256;

localparam      INIT    = 0;

// Main FSM parameter
localparam      IDLE    = 2'b00;
localparam      ECDSA_SIGN  = 2'b01;
localparam      ECDHE_GEN   = 2'b10;
localparam      ECDHE_COMP  = 2'b11;

// ECDSA_SIGN parameter
localparam      DSA_RX  = 3'b000;
localparam      DSARAN  = 3'b001;
localparam      DSAINV  = 3'b010;
localparam      DSAMUL  = 3'b011;
localparam      SIGN_R  = 3'b100;
localparam      SIGN_S  = 3'b101;

// ECDHE_GEN parameter
localparam      GENIDL  = 2'b00;
localparam      GENRAN  = 2'b01;
localparam      GENMUL  = 2'b10;

// ECDHE_COMP parameter
localparam      COM_RX  = 1'b0;
localparam      COMMUL  = 1'b1;

// P-256

localparam      XP256   = 256'h6B17D1F2_E12C4247_F8BCE6E5_63A440F2_77037D81_2DEB33A0_F4A13945_D898C296;
localparam      YP256   = 256'h4FE342E2_FE1A7F9B_8EE7EB4A_7C0F9E16_2BCE3357_6B315ECE_CBB64068_37BF51F5;

// X25519

localparam      X25519  = 256'h0900000000000000000000000000000000000000000000000000000000000000;

// STATUS SIGNAL

localparam      ST_IDLE = 2'b00;
localparam      ST_COMP = 2'b01;
localparam      ST_DONE = 2'b10;
localparam      ST_ERR  = 2'b11;

// AUC mode

localparam      AUC_RAND    = 3'b000;
localparam      AUC_INVS    = 3'b001;
localparam      AUC_R       = 3'b010;
localparam      AUC_S       = 3'b011;
localparam      AUC_WMUL    = 3'b100;
localparam      AUC_MMUL    = 3'b101;

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input               clk;
input               rst;

// IP core
input [3*WIDTH-1:0] din;
input [2:0]         mode; // MSB indicates EC
input               start;
output [WIDTH-1:0]  dout;
output [1:0]        status;

// AUC controller
output [WIDTH-1:0]  auc_dat;
output [3:0]        auc_mode;   // MSB indicates EC
output              auc_start;
input [WIDTH-1:0]   auc_rslt;
input [1:0]         auc_status;

////////////////////////////////////////////////////////////////////////////////
// Output declarations

reg [WIDTH-1:0]     dout;
reg [1:0]           status;
reg [WIDTH-1:0]     auc_dat;
reg                 auc_start;
reg [3:0]           auc_mode;

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

reg [2:0]           dsa_state;
reg [1:0]           gen_state;
reg                 com_state;

reg                 dsa_end;    // ECDSA_SIGN finish
reg                 gen_end;    // ECDHE_GEN finish
reg                 com_end;    // ECDHE_COMP finish
reg                 com_err;

reg [1:0]           main_state;

always @(posedge clk)
    begin
    if (rst)
        begin
        main_state  <= IDLE;
        end
    else 
        begin
        case(main_state)
            IDLE:
                case ({start, mode[1:0]})
                    3'b100: main_state  <= ECDSA_SIGN;
                    3'b101: main_state  <= ECDHE_GEN;
                    3'b110: main_state  <= ECDHE_COMP;
                    3'b111: main_state  <= ECDHE_COMP;
                    default: main_state <= IDLE;
                endcase
            ECDSA_SIGN:
                if (dsa_end)    main_state  <= IDLE;
            ECDHE_GEN:
                if (gen_end)    main_state  <= IDLE;
            ECDHE_COMP:
                if (com_end || com_err) main_state  <= IDLE;
            default:
                main_state  <= IDLE;
        endcase
        end
    end

//================================================
// Main controller memory

// The code below is used in case "start" is a one-cycle signal
// Unnecessarily complicated, use the 2nd one
/*
reg [WIDTH-1:0] inpt_mem [2:0];
reg             datcnt; // cnt from 2nd din

wire            dsa_dat2;
assign          dsa_dat2 = (main_state == ECDSA_SIGN) && (dsa_state == DSA_RX);
wire            com_dat2;
assign          com_dat2 = (main_state == ECDHE_COMP) && (com_state == COM_RX) && ~datcnt;
wire            dat2;
assign          dat2 = dsa_dat2 || com_dat2;
wire            dat3;
assign          dat3 = (main_state == ECDHE_COMP) && (com_state == COM_RX) && datcnt;

always @(posedge clk)
    begin
    if (rst)
        begin
        datcnt  <= 1'b0;
        end
    else if (start)
        begin
        datcnt  <= 1'b0;
        inpt_mem[0] <= din;
        end
    else if (dat2)
        begin
        datcnt  <= (com_dat2 && mode[2]) ? datcnt : ~datcnt;
        inpt_mem[1] <= din;
        end
    else if (dat3)
        begin
        datcnt  <= ~datcnt;
        inpt_mem[2]  <= din;
        end
    end
 */

// The code below is used in case "start" is a multiple-cycle signal
// The number of cycles equals the number of data sent in
/*
reg [WIDTH-1:0] inpt_mem [2:0];
reg [1:0]       datcnt;

wire [1:0]      datcnt_inc;
assign          datcnt = datcnt_inc + 2'b01; //sai ne`, nham` _inc


always @(posedge clk)
    begin
    if (rst)
        begin
        datcnt  <= 2'b00;
        end
    else if (start && (datcnt == 2'b00))
        begin
        datcnt  <= datcnt_inc;
        input_mem[0]    <= din;
        end
    else if (start && (datcnt == 2'b01))
        begin
        datcnt  <= datcnt_inc;
        input_mem[1]    <= din;
        end
    else if (start && (datcnt == 2'b10))
        begin
        datcnt  <= datcnt_inc;
        input_mem[2]    <= din;
        end
    else
        begin
        datcnt  <= 2'b00;
        end
    end
*/

reg [WIDTH-1:0] input_mem [2:0];

always @(posedge clk)
    begin
    if (rst)
        begin
        input_mem[0] <= INIT;
        input_mem[1] <= INIT;
        input_mem[2] <= INIT;
        end
    else if (start)
        begin
        input_mem[0]    <= din[WIDTH-1:0];
        input_mem[1]    <= din[2*WIDTH-1:WIDTH];
        input_mem[2]    <= din[3*WIDTH-1:2*WIDTH];
        end
    end

//================================================
// ECDSA_SIGN FSM

reg [2:0]       dsa_state_1;
reg [2:0]       dsa_state_2;
reg [2:0]       dsa_state_3;

wire            auc_done;
assign          auc_done = (auc_status == ST_DONE);

wire            auc_err;
assign          auc_err = (auc_status == ST_ERR);

always @(posedge clk)
    begin
    if (rst)
        begin
        dsa_state_3 <= DSA_RX;
        dsa_state_2 <= DSA_RX;
        dsa_state_1 <= DSA_RX;
        dsa_state   <= DSA_RX;
        dsa_end     <= 1'b0;
        end
    else if (main_state == ECDSA_SIGN)
        begin
        case(dsa_state)
            DSA_RX:
                begin
                if (dsa_end)                        // FSM end recently
                    begin
                    dsa_state_3 <= DSA_RX;
                    dsa_state_2 <= DSA_RX;
                    dsa_state_1 <= DSA_RX;
                    dsa_state   <= DSA_RX;
                    end
                else           
                    begin
                    dsa_state_3 <= DSARAN;
                    dsa_state_2 <= DSARAN;
                    dsa_state_1 <= DSARAN;
                    dsa_state   <= DSARAN;
                    end   
                dsa_end     <= 1'b0;
                end
            DSARAN:
                begin
                dsa_end     <= 1'b0;
                if (auc_done)        
                    begin
                    dsa_state_3 <= DSAINV;
                    dsa_state_2 <= DSAINV;
                    dsa_state_1 <= DSAINV;
                    dsa_state   <= DSAINV;
                    end
                end
            DSAINV:
                begin
                dsa_end     <= 1'b0;
                if (auc_err)   
                    begin
                    dsa_state_3 <= DSARAN;
                    dsa_state_2 <= DSARAN;
                    dsa_state_1 <= DSARAN;
                    dsa_state   <= DSARAN;
                    end
                else
                    begin
                    if (mode[2])                        // Montgomery
                        begin
                        dsa_state_3 <= auc_done? DSAMUL: dsa_state_3;
                        dsa_state_2 <= auc_done? DSAMUL: dsa_state_2;
                        dsa_state_1 <= dsa_state_2;
                        dsa_state   <= dsa_state_1;
                        end
                    else                                // Weirestrass
                        begin
                        dsa_state_3 <= auc_done? DSAMUL: dsa_state_3;
                        dsa_state_2 <= dsa_state_3;
                        dsa_state_1 <= dsa_state_2;
                        dsa_state   <= dsa_state_1;
                        end
                    end
                end
            DSAMUL:
                begin
                dsa_end     <= 1'b0;
                if (auc_done)        
                    begin
                    dsa_state_3 <= SIGN_R;
                    dsa_state_2 <= SIGN_R;
                    dsa_state_1 <= SIGN_R;
                    dsa_state   <= SIGN_R;
                    end
                else if (auc_err)    
                    begin
                    dsa_state_3 <= DSARAN;
                    dsa_state_2 <= DSARAN;
                    dsa_state_1 <= DSARAN;
                    dsa_state   <= DSARAN; 
                    end
                end
            SIGN_R:
                begin
                dsa_end     <= 1'b0;
                if (auc_err)   
                   begin
                   dsa_state_3 <= DSARAN;
                   dsa_state_2 <= DSARAN;
                   dsa_state_1 <= DSARAN;
                   dsa_state   <= DSARAN;
                   end
                else
                    begin
                    dsa_state_3 <= auc_done? SIGN_S: dsa_state_3;
                    dsa_state_2 <= auc_done? SIGN_S: dsa_state_2;
                    dsa_state_1 <= auc_done? SIGN_S: dsa_state_1;
                    dsa_state   <= dsa_state_1;
                    end
                end
            SIGN_S:
                begin
                if (auc_done)
                    begin
                    dsa_end     <= 1'b1;
                    dsa_state_3 <= DSA_RX;
                    dsa_state_2 <= DSA_RX;
                    dsa_state_1 <= DSA_RX;
                    dsa_state   <= DSA_RX;
                    end
                else if (auc_err)
                    begin
                    dsa_end     <= 1'b0;
                    dsa_state_3 <= DSARAN;
                    dsa_state_2 <= DSARAN;
                    dsa_state_1 <= DSARAN;
                    dsa_state   <= DSARAN;
                    end
                end
            default:;
        endcase
        end
    end

//================================================
// ECDHE_GEN FSM


reg [1:0]       gen_state_3;
reg [1:0]       gen_state_2;
reg [1:0]       gen_state_1;

always @(posedge clk)
    begin
    if (rst)
        begin
        gen_end     <= 1'b0;
        gen_state_3 <= GENIDL;
        gen_state_2 <= GENIDL;
        gen_state_1 <= GENIDL;
        gen_state   <= GENIDL;
        end
    else if (main_state == ECDHE_GEN)
        begin
        case(gen_state)
            GENIDL:
                begin
                gen_end     <= 1'b0;
                if (gen_end)    
                    begin
                    gen_state_3 <= GENIDL;
                    gen_state_2 <= GENIDL;
                    gen_state_1 <= GENIDL;
                    gen_state   <= GENIDL;
                    end
                else           
                    begin
                    gen_state_3 <= GENRAN;
                    gen_state_2 <= GENRAN;
                    gen_state_1 <= GENRAN;
                    gen_state   <= GENRAN;
                    end
                end
            GENRAN:
                begin
                if (auc_err)
                    begin
                    gen_state_3 <= GENRAN;
                    gen_state_2 <= GENRAN;
                    gen_state_1 <= GENRAN;
                    gen_state   <= GENRAN;
                    end
                else
                    begin
                    if (mode[2])                        // Montgomery
                        begin
                        gen_state_3 <= auc_done? GENMUL: gen_state_3;
                        gen_state_2 <= auc_done? GENMUL: gen_state_2;
                        gen_state_1 <= gen_state_2;
                        gen_state   <= gen_state_1;
                        end
                    else                                // Weierstrass
                        begin
                        gen_state_3 <= auc_done? GENMUL: gen_state_3;
                        gen_state_2 <= gen_state_3;
                        gen_state_1 <= gen_state_2;
                        gen_state   <= gen_state_1; 
                        end
                    end
                end
            GENMUL:
                begin
                if (auc_done)
                    begin
                    gen_end     <= 1'b1;
                    gen_state_3 <= GENIDL;
                    gen_state_2 <= GENIDL;
                    gen_state_1 <= GENIDL;
                    gen_state   <= GENIDL;
                    end
                else if (auc_err)
                    begin
                    gen_end     <= 1'b0;
                    gen_state_3 <= GENRAN;
                    gen_state_2 <= GENRAN;
                    gen_state_1 <= GENRAN;
                    gen_state   <= GENRAN;
                    end
                end
            default:;
        endcase
        end
    end

//================================================
// ECDHE_COMP FSM

reg             com_state_4;
reg             com_state_3;
reg             com_state_2;
reg             com_state_1;

always @(posedge clk)
    begin
    if (rst)
        begin
        com_end     <= 1'b0;
        com_state_4 <= COM_RX;
        com_state_3 <= COM_RX;
        com_state_2 <= COM_RX;
        com_state_1 <= COM_RX;
        com_state   <= COM_RX;
        com_err     <= 1'b0;
        end
    else if (main_state == ECDHE_COMP)
        begin
        case(com_state)
            COM_RX:
                begin
                com_end     <= 1'b0;
                if (com_end)
                    begin
                    com_state_4 <= COM_RX;
                    com_state_3 <= COM_RX;
                    com_state_2 <= COM_RX;
                    com_state_1 <= COM_RX;
                    com_state   <= COM_RX;
                    end
                else if (mode[2])                       // Montgomery
                    begin
                    com_state_4 <= COMMUL;
                    com_state_3 <= COMMUL;
                    com_state_2 <= com_state_3;
                    com_state_1 <= com_state_2;
                    com_state   <= com_state_1;
                    end
                else                                    // Weierstrass
                    begin
                    com_state_4 <= COMMUL;
                    com_state_3 <= com_state_4;
                    com_state_2 <= com_state_3;
                    com_state_1 <= com_state_2;
                    com_state   <= com_state_1;
                    end
                com_err     <= 1'b0;
                end
            COMMUL:
                begin
                if (auc_done)
                    begin
                    com_end     <= 1'b1;
                    com_state_4 <= COM_RX;
                    com_state_3 <= COM_RX;
                    com_state_2 <= COM_RX;
                    com_state_1 <= COM_RX;
                    com_state   <= COM_RX;
                    com_err     <= 1'b0;
                    end
                else if (auc_err)
                    begin
                    com_end     <= 1'b1;
                    com_state_4 <= COM_RX;
                    com_state_3 <= COM_RX;
                    com_state_2 <= COM_RX;
                    com_state_1 <= COM_RX;
                    com_state   <= COM_RX;
                    com_err     <= 1'b1;
                    end
                else;
                end
            default:;
        endcase
        end
    end

//================================================
// Tx data to AU controller

always @(posedge clk)
    begin
    if (rst)
        begin
        auc_dat     <= INIT;
        auc_start   <= INIT;
        auc_mode    <= INIT;
        end
    else if (main_state == IDLE)
        begin
        auc_dat     <= INIT;
        auc_start   <= INIT;
        auc_mode    <= INIT;
        end
    //============================================
    else if (main_state == ECDSA_SIGN)
        begin
        // input_mem[0]: hashed message
        // input_mem[1]: private key
        case(dsa_state)
            DSA_RX:
                begin
                if (dsa_end)                            //dsa_state   <= DSA_RX; 
                    begin
                    auc_dat     <= INIT;
                    auc_start   <= INIT;
                    auc_mode    <= {mode[2], AUC_RAND};       
                    end
                else                                    //dsa_state   <= DSARAN;
                    begin
                    auc_dat     <= INIT;
                    auc_start   <= 1'b1;
                    auc_mode    <= {mode[2], AUC_RAND};
                    end
                end 
            DSARAN:
                begin
                if (auc_done)        
                    begin
                    //dsa_state <= DSAINV;
                    auc_dat     <= INIT;                // stored in AUC
                    auc_start   <= 1'b1;
                    auc_mode    <= {mode[2], AUC_INVS}; // inverse
                    end
                else
                    begin
                    auc_dat     <= auc_dat;
                    auc_start   <= INIT;
                    auc_mode    <= auc_mode;
                    end
                end
            DSAINV:
                begin
                if (auc_err)                            //dsa_state <= DSARAN;
                    begin
                    auc_dat     <= INIT;
                    auc_start   <= 1'b1;
                    auc_mode    <= {mode[2], AUC_RAND};
                    end
                else if (mode[2])                       // Montgomery
                    begin
                    if (dsa_state_1 == DSAMUL)          
                        begin
                        auc_dat     <= X25519;
                        auc_start   <= 1'b1;
                        auc_mode    <= {mode[2], AUC_MMUL};
                        end
                    else if (dsa_state_2 == DSAMUL)            
                        begin
                        auc_dat     <= 256'd1;
                        auc_start   <= 1'b1;
                        auc_mode    <= {mode[2], AUC_MMUL};
                        end
                    else if (auc_done)                
                        begin
                        auc_dat     <= 256'd0;
                        auc_start   <= 1'b1;
                        auc_mode    <= {mode[2], AUC_MMUL};
                        end
                    else               
                        begin
                        auc_dat     <= auc_dat;
                        auc_start   <= INIT;
                        auc_mode    <= auc_mode;
                        end
                    end
                else if (dsa_state_1 == DSAMUL)         // Weierstrass                  
                    begin
                    auc_dat     <= YP256;
                    auc_start   <= 1'b1;
                    auc_mode    <= {mode[2], AUC_WMUL};
                    end
                else if (dsa_state_2 == DSAMUL)         // Weierstrass                  
                    begin
                    auc_dat     <= XP256;
                    auc_start   <= 1'b1;
                    auc_mode    <= {mode[2], AUC_WMUL};
                    end
                else if (dsa_state_3 == DSAMUL)         // Weierstrass                  
                    begin
                    auc_dat     <= 256'd1;
                    auc_start   <= 1'b1;
                    auc_mode    <= {mode[2], AUC_WMUL};
                    end
                else if (auc_done)                      // Weierstrass
                    begin
                    auc_dat     <= 256'd0;
                    auc_start   <= 1'b1;
                    auc_mode    <= {mode[2], AUC_WMUL};
                    end
                else
                    begin
                    auc_dat     <= auc_dat;
                    auc_start   <= INIT;
                    auc_mode    <= auc_mode;
                    end
                end
            DSAMUL:
                begin
                if (auc_done)                           //dsa_state <= SIGN_R;
                    begin
                    auc_dat     <= INIT;               
                    auc_start   <= 1'b1;
                    auc_mode    <= {mode[2], AUC_R};   
                    end   
                else if (auc_err)                       //dsa_state   <= DSARAN;
                    begin
                    auc_dat     <= INIT;
                    auc_start   <= 1'b1;
                    auc_mode    <= {mode[2], AUC_RAND};
                    end
                else
                    begin
                    auc_dat     <= auc_dat;
                    auc_start   <= INIT;
                    auc_mode    <= auc_mode;
                    end  
                end
            SIGN_R:
                begin
                if (auc_err)                            //dsa_state   <= DSARAN; 
                    begin
                    auc_dat     <= INIT;
                    auc_start   <= 1'b1;
                    auc_mode    <= {mode[2], AUC_RAND};
                    end
                else if (auc_done)
                    begin
                    auc_dat     <= input_mem[0];
                    auc_start   <= 1'b1;
                    auc_mode    <= {mode[2], AUC_S};
                    end
                else if (dsa_state_1 == SIGN_S)                        
                    begin
                    auc_dat     <= input_mem[1];
                    auc_start   <= 1'b1;
                    auc_mode    <= {mode[2], AUC_S};
                    end
                else
                    begin
                    auc_dat     <= auc_dat;
                    auc_start   <= INIT;
                    auc_mode    <= auc_mode;
                    end  
                end
            SIGN_S:
                begin
                if (auc_done)                           //dsa_state   <= DSA_RX;
                    begin
                    auc_dat     <= INIT;
                    auc_start   <= INIT;
                    auc_mode    <= {mode[2], AUC_RAND};
                    end
                else if (auc_err)                       // dsa_state   <= DSARAN;
                    begin
                    auc_dat     <= INIT;
                    auc_start   <= 1'b1;
                    auc_mode    <= {mode[2], AUC_RAND};
                    end
                else
                    begin
                    auc_dat     <= auc_dat;
                    auc_start   <= INIT;
                    auc_mode    <= auc_mode;
                    end
                end
            default:;
        endcase
        end
    //============================================
    else if (main_state == ECDHE_GEN)
        begin
        case(gen_state)
            GENIDL:
                begin
                 if (gen_end)                            //gen_state   <= GENIDL; 
                    begin
                    auc_dat     <= INIT;
                    auc_start   <= INIT;
                    auc_mode    <= {mode[2], AUC_RAND};       
                    end
                else                                    //gen_state   <= GENRAN;
                    begin
                    auc_dat     <= INIT;
                    auc_start   <= 1'b1;
                    auc_mode    <= {mode[2], AUC_RAND};
                    end
                end
            GENRAN:
                begin
                if (auc_err)                            //gen_state <= GENRAN;
                    begin
                    auc_dat     <= INIT;
                    auc_start   <= 1'b1;
                    auc_mode    <= {mode[2], AUC_RAND};
                    end
                else if (mode[2])                       // Montgomery    
                    begin
                    if (gen_state_1 == GENMUL)
                        begin
                        auc_dat     <= X25519;
                        auc_start   <= 1'b1;
                        auc_mode    <= {mode[2], AUC_MMUL};
                        end
                    else if (gen_state_2 == GENMUL)
                        begin
                        auc_dat     <= 256'd1;
                        auc_start   <= 1'b1;
                        auc_mode    <= {mode[2], AUC_MMUL};
                        end
                    else if (auc_done)
                        begin
                        auc_dat     <= 256'd0;
                        auc_start   <= 1'b1;
                        auc_mode    <= {mode[2], AUC_MMUL};
                        end
                    else 
                        begin
                        auc_dat     <= auc_dat;
                        auc_start   <= INIT;
                        auc_mode    <= auc_mode;
                        end
                    end
                else if (gen_state_1 == GENMUL)         // Weierstrass                  
                    begin
                    auc_dat     <= YP256;
                    auc_start   <= 1'b1;
                    auc_mode    <= {mode[2], AUC_WMUL};
                    end
                else if (gen_state_2 == GENMUL)         // Weierstrass                  
                    begin
                    auc_dat     <= XP256;
                    auc_start   <= 1'b1;
                    auc_mode    <= {mode[2], AUC_WMUL};
                    end
                else if (gen_state_3 == GENMUL)         // Weierstrass                  
                    begin
                    auc_dat     <= 256'd1;
                    auc_start   <= 1'b1;
                    auc_mode    <= {mode[2], AUC_WMUL};
                    end
                else if (auc_done)                      // Weierstrass
                    begin
                    auc_dat     <= 256'd0;
                    auc_start   <= 1'b1;
                    auc_mode    <= {mode[2], AUC_WMUL};
                    end
                else
                    begin
                    auc_dat     <= auc_dat;
                    auc_start   <= INIT;
                    auc_mode    <= auc_mode;
                    end
                end
            GENMUL:
                begin
                if (auc_done)                           //gen_state   <= GENIDL;
                    begin
                    auc_dat     <= INIT;
                    auc_start   <= INIT;
                    auc_mode    <= {mode[2], AUC_RAND};
                    end
                else if (auc_err)                       //gen_state   <= GENRAN;
                    begin
                    auc_dat     <= INIT;
                    auc_start   <= 1'b1;
                    auc_mode    <= {mode[2], AUC_RAND};
                    end
                else
                    begin
                    auc_dat     <= auc_dat;
                    auc_start   <= INIT;
                    auc_mode    <= auc_mode;
                    end
                end
            default:;
        endcase
        end
    //============================================
    else if (main_state == ECDHE_COMP)
        // input_mem[0] = X_Q
        // input_mem[1] = k / Y_Q
        // input_mem[2] = none / k 
        begin
        case(com_state)
            COM_RX:
                begin
                if (com_end)                            //com_state   <= COM_RX;
                    begin
                    auc_dat     <= INIT;
                    auc_start   <= INIT;
                    auc_mode    <= {mode[2], AUC_RAND};
                    end
                else if (mode[2])                       // Montgomery curve
                    begin
                    if (com_state_1 == COMMUL)
                        begin
                        auc_dat     <= input_mem[1];
                        auc_start   <= 1'b1;
                        auc_mode    <= {mode[2], AUC_MMUL};
                        end
                    else if (com_state_2 == COMMUL)
                        begin
                        auc_dat     <= input_mem[0];
                        auc_start   <= 1'b1;
                        auc_mode    <= {mode[2], AUC_MMUL};
                        end
                    
                    else if (com_state_3 == COMMUL)
                        begin
                        auc_dat     <= 256'd1;
                        auc_start   <= 1'b1;
                        auc_mode    <= {mode[2], AUC_MMUL};
                        end
                    else
                        begin
                        auc_dat     <= 256'd0;
                        auc_start   <= 1'b1;
                        auc_mode    <= {mode[2], AUC_MMUL};
                        end
                    end
                else                                    // Weierstrass curve
                    begin
                    if (com_state_1 == COMMUL)                          
                        begin
                        auc_dat     <= input_mem[2];
                        auc_start   <= 1'b1;
                        auc_mode    <= {mode[2], AUC_WMUL};
                        end
                    else if (com_state_2 == COMMUL)                               
                        begin
                        auc_dat     <= input_mem[1];
                        auc_start   <= 1'b1;
                        auc_mode    <= {mode[2], AUC_WMUL};
                        end
                    else if (com_state_3 == COMMUL)                               
                        begin
                        auc_dat     <= input_mem[0];
                        auc_start   <= 1'b1;
                        auc_mode    <= {mode[2], AUC_WMUL};
                        end
                    else if (com_state_4 == COMMUL)                               
                        begin
                        auc_dat     <= 256'd1;
                        auc_start   <= 1'b1;
                        auc_mode    <= {mode[2], AUC_WMUL};
                        end
                    else
                        begin
                        auc_dat     <= 256'd0;
                        auc_start   <= 1'b1;
                        auc_mode    <= {mode[2], AUC_WMUL};
                        end
                    end
                end
            COMMUL:
                begin
                if (auc_done)
                    begin
                    auc_dat     <= INIT;
                    auc_start   <= INIT;
                    auc_mode    <= {mode[2], AUC_RAND};
                    end
                else if (auc_err)
                    begin
                    auc_dat     <= INIT;
                    auc_start   <= INIT;
                    auc_mode    <= {mode[2], AUC_RAND};
                    end
                else
                    begin
                    auc_dat     <= auc_dat;
                    auc_start   <= INIT;
                    auc_mode    <= auc_mode;
                    end
                end
            default:;
        endcase
        end
    end

//================================================
// Rx data from AU controller

wire            rx_random;
assign          rx_random = (main_state == ECDHE_GEN) && (gen_state == GENRAN);

wire            rx_xcoord;
assign          rx_xcoord = (main_state == ECDHE_GEN) && (gen_state == GENMUL);

wire            rx_sign_r;
assign          rx_sign_r = (main_state == ECDSA_SIGN) && (dsa_state == SIGN_R);

wire            rx_sign_s;
assign          rx_sign_s = (main_state == ECDSA_SIGN) && (dsa_state == SIGN_S);

wire            rx_secret;
assign          rx_secret = (main_state == ECDHE_COMP) && (com_state == COMMUL) && ~com_err;

reg [WIDTH-1:0] rx_mem [1:0];

always @(posedge clk)
    begin
    if (auc_done)
        begin
        // ECDSA_SIGN
        if (rx_sign_r)      rx_mem[0]   <= auc_rslt;
        else if (rx_sign_s) rx_mem[1]   <= auc_rslt;
        // ECDHE_GEN
        else if (rx_random) rx_mem[0]   <= auc_rslt;
        else if (rx_xcoord) rx_mem[1]   <= auc_rslt;
        // ECDHE_COMP
        else if (rx_secret) rx_mem[0]   <= auc_rslt;
        end
    end

//================================================
// Tx data to outside

reg             dsa_end_ff;
reg             gen_end_ff;

always @(posedge clk)
    begin
    if (rst)
        begin
        dsa_end_ff  <= 1'b0;
        gen_end_ff  <= 1'b0;
        end
    else
        begin
        dsa_end_ff  <= dsa_end;
        gen_end_ff  <= gen_end;
        end
    end
    
always @(posedge clk)
    begin
    if (rst)
        begin
        dout    <= INIT;
        status  <= INIT;
        end
    else
        begin
        case(main_state)
            IDLE:
                begin
                if (dsa_end_ff || gen_end_ff)
                    begin
                    dout    <= rx_mem[1];
                    status  <= ST_DONE;
                    end
                else 
                    begin
                    dout    <= INIT;
                    status  <= ST_IDLE;
                    end
                end
            ECDSA_SIGN:
                begin
                if (dsa_end)
                    begin
                    dout    <= rx_mem[0];
                    status  <= ST_DONE;
                    end
                else
                    begin
                    dout    <= INIT;
                    status  <= ST_COMP;
                    end
                end
            ECDHE_GEN:
                begin
                if (gen_end)
                    begin
                    dout    <= rx_mem[0];
                    status  <= ST_DONE;
                    end
                else
                    begin
                    dout    <= INIT;
                    status  <= ST_COMP;
                    end
                end
            ECDHE_COMP:
                begin
                if (com_end & ~com_err)
                    begin
                    dout    <= rx_mem[0];
                    status  <= ST_DONE;
                    end
                else if (com_end & com_err)
                    begin
                    dout    <= INIT;
                    status  <= ST_ERR;
                    end
                else
                    begin
                    dout    <= INIT;
                    status  <= ST_COMP;
                    end
                end
        endcase
        end
    end

endmodule 
