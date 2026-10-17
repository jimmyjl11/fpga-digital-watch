`timescale 1ns / 1ps
module pwm_generator #(
    // Number of clock cycles in one PWM period
    parameter int PERIOD_CYCLES = 50_000_000,
    // Number of clock cycles output is high
    parameter int DUTY_CYCLES   = 25_000_000
) (
    input  logic clk,
    input  logic rst,
    output logic pwm_out
);

  localparam int CounterWidth = $clog2(PERIOD_CYCLES);
  localparam logic [CounterWidth-1:0] CriticalCount = CounterWidth'(DUTY_CYCLES);
  logic [CounterWidth-1:0] count;

  always_comb
    if (count >= CriticalCount) pwm_out = 1'b0;
    else pwm_out = 1'b1;

  mod_n_counter #(
      .N(PERIOD_CYCLES),
      .WIDTH(CounterWidth)
  ) u_pwm_counter (
      .clk(clk),
      .rst(rst),
      .enable(1'b1),  //permanently enabled for now.
      .count(count)
  );

endmodule
