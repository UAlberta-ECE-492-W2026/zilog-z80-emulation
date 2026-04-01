`timescale 1ns/1ps

module keyboard_interface
#(
parameter FIFO_DEPTH = 16
)
(
    // sequential signals
    input logic clk,
    input logic reset,

    input logic r_en,
    input logic w_en,

    input  logic [7:0] data_in,
    output logic [7:0] data_out,

    // status
    output logic empty,
    output logic full
);

logic [7:0] fifo[0 : FIFO_DEPTH - 1];
logic [$clog2(FIFO_DEPTH)-1 : 0] w_ptr;
logic [$clog2(FIFO_DEPTH)-1 : 0] r_ptr;
logic [$clog2(FIFO_DEPTH) : 0] count;

assign empty = (count == 0);
assign full  = (count == FIFO_DEPTH);
assign data_out = fifo[r_ptr];

always_ff @( posedge clk ) begin
    if ( reset ) begin
        w_ptr <= 0;
        r_ptr <= 0;
        count <= 0;
    end else begin
        if ( w_en && !full && r_en && !empty ) begin
            count <= count;
        end else if ( w_en && !full ) begin
            fifo[w_ptr] <= data_in;
            w_ptr <= w_ptr + 1;
            count <= count + 1;
        end else if ( r_en && !empty ) begin
            r_ptr <= r_ptr + 1;
            count <= count - 1;
        end
    end
end

endmodule
