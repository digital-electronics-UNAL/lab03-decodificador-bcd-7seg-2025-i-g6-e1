
//`include "src/sumador_restador.v"
//`include "src/cf_divider.v"
//`include "src/separador.v"
//`include "src/BCDtoSSeg.v"
//`include "src/sumres_8b.v"

module top_module (
    input clk_50,         // Reloj de 50 MHz
    input rst,            // Reset para el divisor
    input [7:0] A,        // Operando A
    input [7:0] B,        // Operando B
    input op,             // Operación: 0 = suma, 1 = resta
    output [0:6] SSeg,    // Segmentos del display
    output [3:0] an       
);

    wire [7:0] result;     // Resultado de A ± B
    wire fdiv;             // Reloj lento (~1kHz o similar)
    wire [3:0] BCD;        // Dígito BCD a mostrar
    wire [3:0] select;     // Señal de activación del display correspondiente
    wire Cout;
    // ↓ Instancia del sumador/restador
    sumres_8b sr (
    .A(A),
    .B(B),
    .selec(op),
    .S(result),
    .Cout(Cout)      // o usa el acarreo si quieres visualizarlo
        );


    // ↓ Instancia del divisor de frecuencia (para el display)
    cf_divider div (
        .clk_50(clk_50),
        .rst(rst),
        .fdiv(fdiv)
    );

   

    // ↓ Separador que alterna entre unidades y decenas
    separador_decimal sep (
        .clk(fdiv),             // reloj lento
        .input_val({Cout, result}),     // valor de entrada de 8 bits
        .BCD(BCD),              // salida BCD
        .an(select)             // selección de display activo
    );

    // ↓ Decodifica el dígito BCD a segmentos
    BCDtoSSeg decod (
        .BCD(BCD),
        .select(select),
        .SSeg(SSeg),
        .an(an)
    );

endmodule
