`timescale 1ns / 1ps
`include "src/separador.v"


module tb_separador_decimal;

    reg clk;
    reg [4:0] input_val;
    wire [3:0] BCD;
    wire [3:0] an;


    // Instanciar el DUT
    separador_decimal dut (
        .clk(clk),
        .input_val(input_val),
        .BCD(BCD),
        .an(an)
    );

    // Generar reloj (10 ns de periodo)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Cambiar el estado del reloj cada 5 ns
    end
    

    initial begin
        

        input_val = 0;

        // Activar dumping para GTKWave
        $dumpfile("separador_decimal.vcd");  // Archivo de salida para GTKWave
        $dumpvars(0, tb_separador_decimal);  // Registrar todas las señales del testbench

        // Cambios de entrada
        #10 input_val = 25;
        
        #100 $finish; 
    end

endmodule

