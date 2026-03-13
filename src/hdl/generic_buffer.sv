module buffer #(
    parameter integer width=8 
) (
    input wire [width-1:0] in,
    input wire w,
    input wire clk,
    input wire reset,
    output wire [width-1:0] out
);
    reg [width-1:0] r;

    assign out = r;
    always_ff @(clk, reset) begin
        if (w == 1 && reset == 0) begin
            r <= in;
        end else if(reset == 1) begin
            r <= 0;
        end
    end
endmodule