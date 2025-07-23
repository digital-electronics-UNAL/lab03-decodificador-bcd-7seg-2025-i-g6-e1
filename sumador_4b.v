//`include "src/sum1b_estruc.v"
module sumador_4b(
   input [3:0] A,
   input [3:0] B,
   input Ci,
   output [3:0] S,
   output Cout
);
   wire Co1, Co2, Co3;
  
   sum1b_estruc s1 (
       .A(A[0]),
       .B(B[0]),
       .Ci(Ci),
       .Cout(Co1),
       .S(S[0])
   );
  
   sum1b_estruc s2 (
       .A(A[1]),
       .B(B[1]),
       .Ci(Co1),
       .Cout(Co2),
       .S(S[1])
   );
  
   sum1b_estruc s3 (
       .A(A[2]),
       .B(B[2]),
       .Ci(Co2),
       .Cout(Co3),
       .S(S[2])
   );
  
   sum1b_estruc s4 (
       .A(A[3]),
       .B(B[3]),
       .Ci(Co3),
       .Cout(Cout),
       .S(S[3])
   );


endmodule
