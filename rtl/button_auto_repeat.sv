`timescale 1ns / 1ps
module button_auto_repeat #(
    parameter int HOLD_CYCLES   = 50_000_000,
    // REPEAT_CYCLES must be smaller than HOLD_CYCLES
    parameter int REPEAT_CYCLES = 5_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);

  logic rise;
  logic held;
  logic held_shifted_1;
  logic pulse_train_rise;
  logic pulse_train_repeat;
  assign pulse = rise | (button & (pulse_train_rise | pulse_train_repeat));

  rising_edge_detector RED_button (
      .clk(clk),
      .sig_in(button),
      .rise(rise)
  );

  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES)
  ) u_button_hold_detect (
      .clk(clk),
      .button(button),
      .held(held)
  );
  // rising edge detection for held signal to output first pulse of pulse train

  rising_edge_detector RED_held (
      .clk(clk),
      .sig_in(held),
      .rise(pulse_train_rise)
  );

  always_ff @(posedge clk) held_shifted_1 <= held;

  restartable_rate_generator #(REPEAT_CYCLES) u_rrg (
      .clk (clk),
      .run (held_shifted_1),
      .tick(pulse_train_repeat)
  );
endmodule
