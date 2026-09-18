module clock_divider(
    input clk,          // 100 MHz
    output reg clk25=0 // 25 MHz
);

    reg [1:0] count=0;

    always @(posedge clk) begin
        count <= count+1;
        clk25 <= count[1]; // divide by 4
    end
endmodule