// Verilog project: Verilog code for N-bit Adder 
// Top Level Verilog code for N-bit Adder using Structural Modeling
module fulladder2f(input1,input2,answer);
parameter N=32;
input [N-1:0] input1,input2;
   output [N-1:0] answer;

assign answer = input1 + input2;


endmodule 