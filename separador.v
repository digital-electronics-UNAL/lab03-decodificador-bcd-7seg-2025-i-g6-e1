module separador_decimal ( 
    input clk,
    input [8:0] input_val,
    output reg [3:0] BCD,
    output reg [3:0] an
);
    reg algo;
    initial begin
        algo = 0;
        BCD = 0;
        an = 4'b1110;
    end

    
  
    always @(posedge clk) begin
        case (algo)
        0:begin
            BCD <= input_val % 10; 
            algo <= 1'b1;
            an <= 4'b1110;
        end
        1:begin 
            BCD  <= (input_val - input_val % 10) / 10; 
            algo <= 1'b0;
            an <= 4'b1101;
        end    
        endcase
    end

endmodule
