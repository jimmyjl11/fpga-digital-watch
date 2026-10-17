`timescale 1ns / 1ps
module hms_counter #(
    parameter int N_HOURS   = 24,  // number of hours
    parameter int N_MINUTES = 60,  // number of minutes
    parameter int N_SECONDS = 60,  // number of seconds
    // Output port widths
    parameter int W_HOURS   = 5,
    parameter int W_MINUTES = 6,
    parameter int W_SECONDS = 6
) (
    input logic clk,
    input logic enable,
    output logic [W_HOURS-1:0] hours,
    output logic [W_MINUTES-1:0] minutes,
    output logic [W_SECONDS-1:0] seconds
);
  localparam logic [W_MINUTES-1:0] MaxMinutes = W_MINUTES'(N_MINUTES - 1);
  localparam logic [W_SECONDS-1:0] MaxSeconds = W_SECONDS'(N_SECONDS - 1);

  logic seconds_rollover;
  logic minutes_rollover;

  up_down_counter #(
      .MAX  (N_SECONDS - 1),
      .WIDTH(W_SECONDS)
  ) u_seconds (
      .clk(clk),
      .enable(enable),
      .up(1'b1),
      .count(seconds)
  );
  up_down_counter #(
      .MAX  (N_MINUTES - 1),
      .WIDTH(W_MINUTES)
  ) u_minutes (
      .clk(clk),
      .enable(seconds_rollover),
      .up(1'b1),
      .count(minutes)
  );
  up_down_counter #(
      .MAX  (N_HOURS - 1),
      .WIDTH(W_HOURS)
  ) u_hours (
      .clk(clk),
      .enable(minutes_rollover),
      .up(1'b1),
      .count(hours)
  );

  assign seconds_rollover = enable && (seconds == MaxSeconds);
  assign minutes_rollover = enable && (minutes == MaxMinutes) && (seconds == MaxSeconds);

endmodule
