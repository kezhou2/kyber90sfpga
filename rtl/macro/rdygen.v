////////////////////////////////////////////////////////////////////////////////
//
// Arrive Technologies
//
// Filename     : rdygen.v
// Description  : Stretch cpu ready signals for cpu interface
//                
// Author       : ddduc@HW-DDDUC
// Created On   : Wed Feb 18 13:30:44 2004
// History (Date, Changed By)
//
////////////////////////////////////////////////////////////////////////////////

module rdygen
    (
     rst_,
     clk,
     pce_,
     scanmode,
     rdyin,
     rdyout
     );

////////////////////////////////////////////////////////////////////////////////
// Port declarations

input   rst_;
input   clk;
input   pce_;
input   scanmode;
input   rdyin;
output  rdyout;

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

reg     rdystatic;
always @(posedge clk or negedge cerst_)
    if (!cerst_)    rdystatic <= 1'b0;
    else
        begin
//        if(rdyin)   rdystatic <= 1'b1;
        if(rdyin)   rdystatic <= rdyin;
        else        rdystatic <= rdystatic;
        end

assign rdyout   = rdystatic;

endmodule