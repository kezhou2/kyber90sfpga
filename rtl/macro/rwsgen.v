////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : rwsgen.v
// Description  : read/write strobe generator
//
// Author       : ddduc@HW-DDDUC
// Created On   : Wed Feb 18 10:51:31 2004
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module rwsgen
    (
     clk,
     rst_,
     pce_,
     prnw,
     pws,
     prs,
     scanmode
     );

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input   clk,
        rst_,
        pce_,
        prnw;
input   scanmode;
output  pws,
        prs;

////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation

// removed this equation due to erroring under scan synthesis
//wire cerst_ = ~((pce_ | ~rst_) & (!scanmode)); // in case chip enable is short

//wire cerst_ = scanmode ? rst_ :
//                         (~(pce_ | ~rst_)); // in case chip enable is short

wire    cerst_;

atmux1 scmux
    (
     .a(rst_),
     .b(~(pce_ | ~rst_)),
     .sela(scanmode),
     .o(cerst_)
     );
 
//wire cerst_ = ~((pce_ & (!scanmode)) | ~rst_); // in case chip enable is short

reg [2:0]   rin;
always @(posedge clk or negedge cerst_)
begin
    if(!cerst_) rin <= 3'b0;
// removed this equation due to erroring under scan synthesis
//    else rin <= {rin[1:0],1'b1};
    else rin <= {rin[1:0],(~pce_)};
end

wire    pul = ~rin[2] & rin[1];
reg     pws,prs;
always @(posedge clk or negedge cerst_)
    begin
    if(!cerst_)
        begin
        pws <= 1'b0;
        prs <= 1'b0;
        end
    else 
        begin
        pws <= ~prnw & pul;
        prs <= prnw & pul;
        end
    end

endmodule 


