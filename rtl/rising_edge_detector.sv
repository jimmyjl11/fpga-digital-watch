`timescale 1ns / 1ps
module rising_edge_detector (
    input  logic clk,
    input  logic sig_in,
    output logic rise
);
  logic state = '0;
  logic next_state;

  always_ff @(posedge clk) state <= next_state;

  always_comb
    case ({
      state, sig_in
    })
      {1'b0, 1'b1} : next_state = 1'b1;
      {1'b1, 1'b0} : next_state = 1'b0;
      default: next_state = state;
    endcase
  always_comb rise = ({state, sig_in} == {1'b0, 1'b1});

endmodule
