/*
 * 
 */
module atmux1 (a, b, sela, o);

input   a,
        b,
        sela;

output  o;

// K-micro mux instant
/*
wire    o;
assign  o = sela ? a : b;
*/
reg     o;
always @(sela or a or b)
    begin
    case (sela) // synopsys infer_mux
        1'b0: o = b;
        1'b1: o = a;
    endcase
    end

endmodule