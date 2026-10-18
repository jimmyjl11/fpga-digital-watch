`timescale 1ns / 1ps
module top_time_display_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic CLOCK_50,
    input logic [1:0] SW,
    output logic [6:0] HEX5,
    output logic [6:0] HEX4,
    output logic [6:0] HEX3,
    output logic [6:0] HEX2,
    output logic [6:0] HEX1,
    output logic [6:0] HEX0
);

  localparam int SecPerMin = 60;
  localparam int MinPerHour = 60;
  localparam int HourPerDay = 24;
  localparam int HourWidth = $clog2(HourPerDay);
  localparam int MinWidth = $clog2(MinPerHour);
  localparam int SecWidth = $clog2(SecPerMin);
  localparam int BinToBCDWidth = 7;


  logic clock_1k, clock_25, clock_1s;
  logic enable = 1'b1;  // permanently on for now
  logic [SecWidth - 1:0] seconds;
  logic [MinWidth - 1:0] minutes;
  logic [HourWidth - 1:0] hours;
  logic [3:0] unit1;  //seconds ones
  logic [3:0] unit2;
  logic [3:0] unit3;
  logic [3:0] unit4;
  logic [3:0] unit5;
  logic [3:0] unit6;
  logic ssblank = '0;


  // Slower clock generator
  restartable_rate_generator #(CYCLES_PER_SECOND) u_gen_1hz (
      .clk (CLOCK_50),
      .run (enable),
      .tick(clock_1s)
  );
  restartable_rate_generator #(CYCLES_PER_SECOND / 25) u_gen_25hz (
      .clk (CLOCK_50),
      .run (enable),
      .tick(clock_25)
  );
  restartable_rate_generator #(CYCLES_PER_SECOND / 1000) u_gen_1khz (
      .clk (CLOCK_50),
      .run (enable),
      .tick(clock_1k)
  );


  logic selected_tick;

  always_comb begin
    case (SW)
      2'b00:   selected_tick = clock_1s;
      2'b01:   selected_tick = clock_25;
      2'b10:   selected_tick = clock_1k;
      2'b11:   selected_tick = 1'b1;
      default: selected_tick = 1'b0;
    endcase
  end

  hms_counter #(
      .N_HOURS  (HourPerDay),
      .N_MINUTES(MinPerHour),
      .N_SECONDS(SecPerMin),
      .W_HOURS  (HourWidth),
      .W_MINUTES(MinWidth),
      .W_SECONDS(SecWidth)
  ) u_hms_counter (
      .clk(CLOCK_50),
      .enable(selected_tick),
      .hours(hours),
      .minutes(minutes),
      .seconds(seconds)
  );
  binary_to_bcd u_hoursbcd (
      .bin ({(BinToBCDWidth - HourWidth)'(0), hours}),
      .tens(unit6),
      .ones(unit5)
  );
  binary_to_bcd u_minutesbcd (
      .bin ({(BinToBCDWidth - MinWidth)'(0), minutes}),
      .tens(unit4),
      .ones(unit3)
  );
  binary_to_bcd u_secondsbcd (
      .bin ({(BinToBCDWidth - SecWidth)'(0), seconds}),
      .tens(unit2),
      .ones(unit1)
  );

  seven_segment #(
      .ACTIVE_LOW(1)
  ) LCD6 (
      .digit(unit6),
      .blank(ssblank),
      .segments(HEX5)
  );
  seven_segment #(
      .ACTIVE_LOW(1)
  ) LCD5 (
      .digit(unit5),
      .blank(ssblank),
      .segments(HEX4)
  );
  seven_segment #(
      .ACTIVE_LOW(1)
  ) LCD4 (
      .digit(unit4),
      .blank(ssblank),
      .segments(HEX3)
  );
  seven_segment #(
      .ACTIVE_LOW(1)
  ) LCD3 (
      .digit(unit3),
      .blank(ssblank),
      .segments(HEX2)
  );
  seven_segment #(
      .ACTIVE_LOW(1)
  ) LCD2 (
      .digit(unit2),
      .blank(ssblank),
      .segments(HEX1)
  );
  seven_segment #(
      .ACTIVE_LOW(1)
  ) LCD1 (
      .digit(unit1),
      .blank(ssblank),
      .segments(HEX0)
  );
endmodule
