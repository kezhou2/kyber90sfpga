////////////////////////////////////////////////////////////////////////////////
//
// Ho Chi Minh City University of Technology
//
// Filename     : modfa
// Description  : .
//
// Author       : Vuong Dinh Hung
// Created On   : Fri Mar 08 09:33:17 2019
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module modfa
    (
     clk,
     rst,
     op1,
     op2,
     mod,
     cin,
     en,
     sum,
     vld
     );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

parameter WIDTH = 256;
parameter INIT  = 0;

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input     clk;
input     rst;
input [WIDTH-1:0] op1;
input [WIDTH-1:0] op2;
input [WIDTH-1:0] mod;
input             cin;
input             en;   // set in a cycle

output [WIDTH-1:0] sum;
output             vld; 

////////////////////////////////////////////////////////////////////////////////
// Output declarations

reg [WIDTH-1:0]    sum;
reg                vld;

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

reg [WIDTH-1:0]    a, b;    // CLA input
reg [WIDTH-1:0]    p;       // modulo input
reg                ci;      // CLA carry input

wire [WIDTH-1:0]   rslt;    // CLA output
wire               co;      // CLA carry output
 
reg                aldone;  // almost done

always @(posedge clk)
    begin
    if (rst)
        begin
        a   <= INIT;
        b   <= INIT;
        p   <= INIT;
        ci  <= INIT;
        aldone  <= INIT;
        end
    else if (en)
        begin
        a   <= op1;
        b   <= op2;
        p   <= mod;
        ci  <= cin;
        aldone  <= INIT;
        end
    else
        begin
        a   <= rslt;
        p   <= p;
        case({ci,co})
            2'b00:  
                begin
                b   <= p;
                ci  <= aldone ? 1'b0: 1'b1;
                aldone  <= aldone;
                end
            2'b01: 
                begin
                b   <= p;   // addition overflow
                ci  <= 1'b1;
                aldone  <= ~aldone;
                end
            2'b10:  
                begin
                b   <= p;
                ci  <= 1'b0;
                aldone  <= ~aldone;
                end
            2'b11:  
                begin
                b   <= p;
                ci  <= 1'b1;
                aldone  <= aldone;
                end
        endcase
        end
    end

// Carry Look-ahead Adder

wire [WIDTH:0] w_c;
wire [WIDTH-1:0] w_g,w_p,w_s;
wire [WIDTH-1:0] bxr;

genvar i;

generate
    for(i = 0; i<WIDTH; i = i+1)
        begin : FAgen
        assign bxr[i] = b[i] ^ ci;
        full_adder fai
            (
             .a(a[i]),
             .b(bxr[i]),
             .c_i(w_c[i]),
             .sum(w_s[i]),
             .c_o()
             );
        end
endgenerate

genvar j;
generate
    for (j=0;j<WIDTH;j=j+1)
        begin : clgen
        assign w_g[j] = a[j] & bxr[j];
        assign w_p[j] = a[j] | bxr[j];
        assign w_c[j+1] = w_g[j] | (w_p[j] & w_c[j]);
        end
endgenerate

assign         w_c[0] = ci;
assign         rslt = w_s;
assign         co   = w_c[WIDTH];

// Latch result if < p
reg            stop;

wire           ovf; // CLA overflow
//fflopx #(1) ifflopx (clk, rst, ci^co, ovf);
assign         ovf = ci^co;

wire           endcon;
assign         endcon = ((rslt < p) && (!stop)) && (~ovf | aldone); 

always @(posedge clk)
    begin
    if (rst)
        begin
        sum <= INIT;
        vld <= INIT;
        stop    <= INIT;
        end
    else if (en)
        begin
        vld <= INIT;
        stop    <= INIT;
        end
    else if (endcon)
        begin
        sum <= rslt;
        vld <= 1'b1;
        stop    <= 1'b1;
        end
    else
        begin
        vld <= INIT;
        end
    end

endmodule 
