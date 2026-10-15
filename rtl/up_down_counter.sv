`timescale 1ns / 1ps
module up_down_counter #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic enable,
    input logic up,
    output logic [WIDTH-1:0] count
);
  localparam logic [WIDTH-1:0] Max = WIDTH'(MAX); // casts MAX into a correctly sized parameter for comparison
  logic [WIDTH-1:0] next_count;
  initial count = '0;

  always_ff @(posedge clk) if (enable) count <= next_count;

  always_comb
    if (up) next_count = (count < Max) ? count + WIDTH'(1) : WIDTH'(0);
    else next_count = (count > WIDTH'(0)) ? count - WIDTH'(1) : Max;
endmodule

//The count is initialised to 0.
//When enable is low, count does not change.
//When enable is high, count increments if up is high and decrements if up is low, wrapping
//from MAX to 0 on increment and from 0 to MAX on decrement.
