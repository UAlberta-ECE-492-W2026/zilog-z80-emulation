module keyboard_interface
#(
parameter FIFO_DEPTH = 16
)
(
    // sequential signals
    input logic clk,
    input logic reset,

    input logic[15:0] address,

    // read enable only ( cant write to keyboard lol )
    input logic r_en,

    // AXI signals
    input  logic [7:0] AXI_data_in,
    input  logic AXI_valid,

    output logic [7:0] data_out
);

logic [7:0] fifo[0 : FIFO_DEPTH - 1];
logic [$clog2(FIFO_DEPTH)-1 : 0] w_ptr;
logic [$clog2(FIFO_DEPTH)-1 : 0] r_ptr;
logic [$clog2(FIFO_DEPTH): 0] count;

// writing to FIFO from AXI
always_ff @( posedge clk ) begin
    if (reset) begin
        w_ptr <= 0;
        count <= 0;
    end
    else if (AXI_valid && count < FIFO_DEPTH) begin
        fifo[w_ptr] <= AXI_data_in;
        w_ptr <= w_ptr + 1;
        count <= count + 1;
    end
    
end

// reading data from fifo to data_out bus
always_ff @( posedge clk ) begin
    if (reset) begin
        r_ptr <= 0;
    end
    else if (r_en && count>0 && address[3:0] == 4'h1) begin
        r_ptr <= r_ptr + 1;
        count <= count - 1;
    end
end

always_comb begin
    case (address [3:0])
        4'h0:data_out = {7'b0, (count > 0)}; // the status flag/ whether or not there is data inside the fifo
        4'h1:data_out = fifo[r_ptr]; // outputting the next data to the data_out bus
        default: data_out = 8'h00;
    endcase
end

endmodule