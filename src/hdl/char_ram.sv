//`timescale 1ns/1ps

//! Character RAM stores ASCII value for each screen cell
//! CHAR_COLL columns x CHAR_ROWS rows

module char_ram #(
    parameter CHAR_ROWS,
    parameter CHAR_COLL
)(
    input  logic clk,
    output logic [7:0] data_out,
    input  logic [15:0] address,
    input  logic WE,
    input  logic [7:0] data_in
);

localparam total_chars = CHAR_ROWS * CHAR_COLL;
logic [7:0] RW[0:total_chars - 1];

initial begin
    RW[0] = 8'd65;
    RW[total_chars / 4] = 8'd66;
    RW[total_chars / 2] = 8'd67;
    RW[total_chars * (3/4)] = 8'd68;
    //for (int i=0;i<total_chars / 4;i++)
    //    RW[i] = 8'd65;
    //for (int i=total_chars / 4; i < total_chars / 2;i++)
    //    RW[i] = 8'd66;  
    //for (int i=total_chars / 2;i < total_chars * (3/4);i++)
    //    RW[i] = 8'd67; 
    //for (int i=total_chars * (3/4);i < total_chars;i++)
    //    RW[i] = 8'd68; 
end

always_ff @(posedge clk) begin
    if (WE)
        RW[address] <= data_in;

    data_out <= RW[address];
end

endmodule
