module sumador_restador (
    input [7:0] A,
    input [7:0] B,
    input op,              // 0 = suma, 1 = resta
    output reg [7:0] result
);

    always @(*) begin
        if (op == 1'b0)
            result = A + B;
        else
            result = A - B;
    end

endmodule
