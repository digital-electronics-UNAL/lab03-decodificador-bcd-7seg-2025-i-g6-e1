`timescale 1ns / 1ps
`include "src/modulo_top.v"

module top_module_tb;

    // Entradas
    reg clk_50;
    reg rst;
    reg [7:0] A;
    reg [7:0] B;
    reg op;

    // Salidas
    wire [0:6] SSeg;
    wire [3:0] an;

    // Instancia del módulo
    top_module uut (
        .clk_50(clk_50),
        .rst(rst),
        .A(A),
        .B(B),
        .op(op),
        .SSeg(SSeg),
        .an(an)
    );

    // Reloj simulado de 50 MHz (20 ns de periodo)
    initial begin
        clk_50 = 0;
        forever #10 clk_50 = ~clk_50;
    end

    // Generar archivo VCD para GTKWave
    initial begin
        $dumpfile("top_module_tb.vcd");
        $dumpvars(0, top_module_tb);
        #100000000 $finish;
    end

    // Estímulos
    initial begin
        // Inicialización
        rst = 1;
        A = 0;
        B = 0;
        op = 0;

        // Liberar reset
        #100;
        rst = 0;

       
        A = 8'd15;
        B = 8'd15;
        op = 0;       
    end

endmodule
