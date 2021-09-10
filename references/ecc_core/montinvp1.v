////////////////////////////////////////////////////////////////////////////////
//
// Ho Chi Minh City Unviersity of Technology
//
// Filename     : montinvp1.v
// Description  : .
//
// Author       : Vuong Dinh Hung (1511422)
// Created On   : Wed Mar 06 10:20:00 2019
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module montinvp1
    (
     clk,
     rst,
     din,
     mod,
     en,
     ainv,
     exp,
     vld
     );

////////////////////////////////////////////////////////////////////////////////
// Parameter declarations

parameter WIDTH = 256;
parameter CWID  = 10;

parameter INIT0 = 0;
parameter INIT1 = 1;

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input clk;
input rst;
input [WIDTH-1:0] din;
input [WIDTH-1:0] mod;
input             en;

output [WIDTH-1:0] ainv;    // almost montgomery inverse
output [CWID-1:0]  exp;
output             vld;     // set in a cycle

////////////////////////////////////////////////////////////////////////////////
// Output declarations

//reg [WIDTH-1:0]    ainv;
reg [CWID-1:0]     exp;
reg                vld;

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

reg [WIDTH-1:0]    u, v, r, s, p;

always @(posedge clk)
    begin
    if (rst)
        begin
        p   <= INIT0;
        end
    else if (en)
        begin
        p   <= mod;
        end
    end

wire [WIDTH-1:0] u_v;
wire             u_lrg_eq_v;

full_sub    #(WIDTH)  ifull_sub_uv
    (
     .a(u),
     .b(v),
     .sub(u_v),
     .c(u_lrg_eq_v)
     );

wire [WIDTH-1:0] v_u;
wire             v_lrg_eq_u;

full_sub    #(WIDTH)  ifull_sub_vu
    (
     .a(v),
     .b(u),
     .sub(v_u),
     .c(v_lrg_eq_u)
     );

wire [WIDTH-1:0] sr;

cla #(WIDTH) icla
    (
     .a(s),
     .b(r),
     .sum(sr),
     .c()
     );

// stop and hold results

reg stop;

always @(posedge clk)
    begin
    if (rst)
        begin
        stop    <= 1'b1;
        vld     <= 1'b0;
        end
    else if (en)
        begin
        stop    <= 1'b0;
        vld     <= 1'b0;
        end
    else if ((v == 0) && (!stop))
        begin
        stop    <= 1'b1;
        vld     <= 1'b1;
        end
    else
        begin
        stop    <= stop;
        vld     <= 1'b0;
        end
    end

// main computation

reg msb;    // save MSB of reg r

always @(posedge clk)
    begin
    if (rst)
        begin
        u   <= INIT0;
        v   <= INIT0;
        r   <= INIT0;
        s   <= INIT0;
        exp <= INIT0;
        msb <= INIT0;
        end
    else if (en)
        begin
        u   <= mod;
        v   <= din;
        r   <= INIT0;
        s   <= INIT1;
        exp <= INIT0;
        msb <= INIT0;
        end
    else if (v > 0)
        begin
        if (u[2:0] == 3'b000)
            begin
            u   <= {3'b0, u[WIDTH-1:3]};
            s   <= {s[WIDTH-4:0], 3'b0};
            exp <= exp + 3;
            end
        else if (u[2:0] == 3'b100)
            begin
            u   <= {2'b0, u[WIDTH-1:2]};
            s   <= {s[WIDTH-3:0], 2'b0};
            exp <= exp + 2;
            end
        else if (u[1:0] == 2'b10)
            begin
            u   <= {1'b0, u[WIDTH-1:1]};
            s   <= {s[WIDTH-2:0], 1'b0};
            exp <= exp + 1;
            end
        else if (v[2:0] == 3'b000)
            begin
            v   <= {3'b0, v[WIDTH-1:3]};
            r   <= {r[WIDTH-4:0], 3'b0};
            exp <= exp + 3;
            end
        else if (v[2:0] == 3'b100)
            begin
            v   <= {2'b0, v[WIDTH-1:2]};
            r   <= {r[WIDTH-3:0], 2'b0};
            exp <= exp + 2;
            end
        else if (v[1:0] == 2'b10)
            begin
            v   <= {1'b0, v[WIDTH-1:1]};
            r   <= {r[WIDTH-2:0], 1'b0};
            exp <= exp + 1;
            end
        else if (v_lrg_eq_u)    // only this condition needs to save r's MSB
            begin
            v   <= {1'b0, v_u[WIDTH-1:1]};
            r   <= {r[WIDTH-2:0], 1'b0};
            s   <= sr;
            exp <= exp + 1;
            msb <= r[WIDTH-1];
            end
        else    // v < u
            begin
            u   <= {1'b0, u_v[WIDTH-1:1]};
            r   <= sr;
            s   <= {s[WIDTH-2:0], 1'b0};
            exp <= exp + 1;
            end
        end
    else if ((v == 0) && (!stop))   // end loop
        begin
        if ((r >= p) || msb)        // msb: r has been overflowed
            begin
            r   <= {p[WIDTH-2:0], 1'b0} - r;
            end
        else
            begin
            r   <= p - r;
            end
        end
    end

assign ainv = r;

endmodule 
