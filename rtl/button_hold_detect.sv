`timescale 1ns / 1ps
module button_hold_detect #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input  logic clk,
    input  logic button,
    output logic held
);
  localparam int CountMax = HOLD_CYCLES - 1;
  localparam int CountWidth = $clog2(CountMax + 1);

  logic count_rst;
  logic count_enable;
  logic [CountWidth-1:0] count;
  logic next_held;

  mod_n_counter #(
      .N(CountMax + 1),
      .WIDTH(CountWidth)
  ) u_counter (
      .clk(clk),
      .rst(count_rst),
      .enable(count_enable),
      .count(count)
  );
  // button held means start counting, as soon as button is released, trigger reset.
  assign count_rst    = !button;
  assign count_enable = button;

  always_comb begin
    if (!button) next_held = 1'b0;
    else if (held) next_held = 1'b1;
    else if (count == CountWidth'(CountMax)) next_held = 1'b1;
    else next_held = 1'b0;
  end

  always_ff @(posedge clk) begin
    held <= next_held;
  end

endmodule
