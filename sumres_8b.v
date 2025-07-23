//`include "src/sum_res4b.v"
module sumres_8b (
    input  [7:0] A,
    input  [7:0] B,
    input        selec,      // 0 = suma, 1 = resta
    output [7:0] S,
    output       Cout
);

    wire [3:0] S0, S1;
    wire C4;

    // Parte baja (bits 0-3)
    sumres_4b low (
        .A(A[3:0]),
        .B(B[3:0]),
        .selec(selec),
        .S(S0),
        .Cout(C4)
    );

    // Parte alta (bits 4-7)
    sumador_4b high (
        .A(A[7:4]),
        .B({B[7]^selec, B[6]^selec, B[5]^selec, B[4]^selec}),
        .Ci(C4),
        .S(S1),
        .Cout(Cout)
    );

    assign S = {S1, S0};

endmodule
