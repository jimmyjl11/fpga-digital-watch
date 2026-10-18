`timescale 1ns / 1ps

module key_synchroniser (
    input  logic       clk,
    input  logic [3:0] key_n,    // Active-low, asynchronous
    output logic [3:0] key_sync  // Active-high, synchronised
);

  logic [3:0] key_inv;
  logic [3:0] sync_shifted1 = 4'b0000;
  logic [3:0] sync_shifted2 = 4'b0000;

  assign key_inv = ~key_n;

  always_ff @(posedge clk) begin
    sync_shifted1 <= key_inv;
    sync_shifted2 <= sync_shifted1;
  end

  assign key_sync = sync_shifted2;

endmodule
