//`include "src/sumador_4b.v"
module sumres_4b (
   input  [3:0] A,     
   input  [3:0] B,     
   input        selec,    
   output [3:0] S,     
   output       Cout   
);


   wire c0, c1, c2, c3;


   xor(c0,B[0],selec);
   xor(c1,B[1],selec);
   xor(c2,B[2],selec);
   xor(c3,B[3],selec);


   sumador_4b FA0 (.A(A), .B({c3, c2, c1, c0}), .Ci(selec),  .Cout(Cout), .S(S));


endmodule
