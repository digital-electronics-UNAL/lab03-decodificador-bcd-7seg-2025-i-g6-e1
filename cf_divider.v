module cf_divider(
input clk_50,
input rst,
output reg fdiv 
);

parameter cont = 80000;
parameter tam = $clog2(cont); // log2(800000) ≈ 20
reg [tam-1:0] counter;

always @ (posedge clk_50 or negedge rst) begin
    if (rst==0) begin
        counter <= 'd0;
        fdiv <= 1'b0;
    end 
    else if (counter == cont-1) begin
            counter <= 'd0;
            fdiv <= ~fdiv; // Toggle the output frequency
    end else begin
        counter <= counter+1;
    end
end
endmodule