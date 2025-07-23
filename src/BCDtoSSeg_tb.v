`timescale 1ns / 1ps
`include "src/BCDtoSSeg.v"
module tb_BCDtoSSeg();

  reg [3:0] BCD;
  wire [0:6] SSeg;
  wire [3:0] an;

  BCDtoSSeg uut (
    .BCD(BCD),
    .SSeg(SSeg),
    .an(an)
  );

  initial begin
    $dumpfile("tb_BCDtoSSeg.vcd"); 
    $dumpvars(0, tb_BCDtoSSeg);

    // Prueba todos los valores posibles de 4 bits (0 a 15)
    BCD = 4'b0000; #10;
    BCD = 4'b0001; #10;
    BCD = 4'b0010; #10;
    BCD = 4'b0011; #10;
    BCD = 4'b0100; #10;
    BCD = 4'b0101; #10;
    BCD = 4'b0110; #10;
    BCD = 4'b0111; #10;
    BCD = 4'b1000; #10;
    BCD = 4'b1001; #10;
    BCD = 4'ha;    #10;
    BCD = 4'hb;    #10;
    BCD = 4'hc;    #10;
    BCD = 4'hd;    #10;
    BCD = 4'he;    #10;
    BCD = 4'hf;    #10;

    $finish;
  end

endmodule
