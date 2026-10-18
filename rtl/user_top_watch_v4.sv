`timescale 1ns / 1ps

module user_top_watch_v4 #(
    /* verilator lint_off UNUSEDPARAM */
    parameter int CYCLES_PER_SECOND = 50_000_000
    /* verilator lint_on UNUSEDPARAM */
) (
    input logic clk,
    /* verilator lint_off UNUSED */
    input logic [3:0] button,
    input logic [9:0] sw,
    /* verilator lint_on UNUSED*/
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);
  // ------------------
  // Core Functionality
  // ------------------

  // Seconds
  logic seconds_tick;
  logic seconds_edit;
  /* verilator lint_off UNDRIVEN */
  logic seconds_inc;
  logic seconds_dec;
  /* verilator lint_on UNDRIVEN */
  logic [5:0] seconds;
  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .tick(seconds_tick),
      .edit_mode(seconds_edit),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .count(seconds)
  );
  // Minutes
  logic minutes_tick;
  logic minutes_edit;
  /* verilator lint_off UNDRIVEN */
  logic minutes_inc;
  logic minutes_dec;
  /* verilator lint_on UNDRIVEN */
  logic [5:0] minutes;
  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .tick(minutes_tick),
      .edit_mode(minutes_edit),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .count(minutes)
  );

  // Hours
  logic hours_tick;
  logic hours_edit;
  /* verilator lint_off UNDRIVEN */
  logic hours_inc;
  logic hours_dec;
  /* verilator lint_on UNDRIVEN */
  logic [4:0] hours;
  editable_counter #(
      .N(24),
      .WIDTH(5)
  ) u_hours (
      .clk(clk),
      .tick(hours_tick),
      .edit_mode(hours_edit),
      .inc(hours_inc),
      .dec(hours_dec),
      .count(hours)
  );

  // Derive 1 Hz tick from system clock
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_divider_1_Hz (
      .clk (clk),
      .run (~seconds_edit),
      .tick(seconds_tick)
  );
  // unused signals
  assign led = 10'b0;
  // connect blank values to pwm signal
  assign blank_hours = mode_enable[2] && pwm_out;
  assign blank_minutes = mode_enable[1] && pwm_out;
  assign blank_seconds = mode_enable[0] && pwm_out;
  // Zero-extend counter values to display outputs
  assign hours_disp = {2'b0, hours};
  assign minutes_disp = {1'b0, minutes};
  assign seconds_disp = {1'b0, seconds};
  assign minutes_tick = (seconds_disp == 7'd59) && seconds_tick && !seconds_edit;
  assign hours_tick = (minutes_disp == 7'd59) &&
                      (seconds_disp == 7'd59) &&
                      seconds_tick &&
                      !seconds_edit &&
                      !minutes_edit; // gates against minutes and hours ticking when editing

  // --------------
  // Mode Selection
  // --------------

  logic [2:0] mode_enable;
  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)  // Fill in, based on CYCLES_PER_SECOND
  ) u_mode_selector (
      .clk(clk),
      .button(button[3]),
      .mode_enable(mode_enable)
  );
  always_comb begin
    seconds_edit = 1'b0;
    minutes_edit = 1'b0;
    hours_edit = 1'b0;

    seconds_inc = 1'b0;
    seconds_dec = 1'b0;
    minutes_inc = 1'b0;
    minutes_dec = 1'b0;
    hours_inc = 1'b0;
    hours_dec = 1'b0;

    case (mode_enable)
      3'b001: begin
        seconds_edit = 1'b1;
        seconds_inc  = inc_pulse;
        seconds_dec  = dec_pulse;
      end

      3'b010: begin
        minutes_edit = 1'b1;
        minutes_inc  = inc_pulse;
        minutes_dec  = dec_pulse;
      end

      3'b100: begin
        hours_edit = 1'b1;
        hours_inc  = inc_pulse;
        hours_dec  = dec_pulse;
      end

      default: begin
        // Normal mode: no field is editable.
      end
    endcase
  end
  logic pwm_out;

  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),
      .DUTY_CYCLES  (CYCLES_PER_SECOND / 10)
  ) u_display_pwm (
      .clk(clk),
      .rst(1'b0),
      .pwm_out(pwm_out)
  );

  // ----------
  // edit logic
  // ----------
  // key[1] increments
  // key [0] decrements
  // edit mode: 2hz, at 80% duty cycle
  // hold key[1] or key[0] for over 0.5s: repeat at 10hz
  // fields BELOW selected field continue to tick normally
  logic inc_pulse;
  logic dec_pulse;

  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_increment_repeat (
      .clk(clk),
      .button(button[1]),
      .pulse(inc_pulse)
  );

  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_decrement_repeat (
      .clk(clk),
      .button(button[0]),
      .pulse(dec_pulse)
  );
endmodule
