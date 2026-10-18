`timescale 1ns / 1ps

module user_top_stopwatch_v1 #(
    /* verilator lint_off UNUSEDPARAM */
    parameter int CYCLES_PER_SECOND = 50_000_000
    /* verilator lint_on UNUSEDPARAM */
) (
    input logic clk,
    input logic [3:0] button,
    input logic [9:0] sw,
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);

    // ------------------------------------------------------------
    // 1. Convert button presses into one-cycle rising-edge pulses
    // ------------------------------------------------------------

    logic rise_start_stop;
    logic rise_lap;

    rising_edge_detector u_start_stop_detector (
        .clk    (clk),
        .sig_in (button[0]),
        .rise   (rise_start_stop)
    );

    rising_edge_detector u_lap_detector (
        .clk    (clk),
        .sig_in (button[1]),
        .rise   (rise_lap)
    );

    // ------------------------------------------------------------
    // 2. Stopwatch control
    // ------------------------------------------------------------

    logic counter_rst;
    logic counter_enable;
    logic lap_hold;

    stopwatch_control u_stopwatch_control (
        .clk              (clk),
        .rise_start_stop  (rise_start_stop),
        .rise_lap         (rise_lap),
        .counter_rst      (counter_rst),
        .counter_enable   (counter_enable),
        .lap_hold         (lap_hold)
    );

    // ------------------------------------------------------------
    // 3. Stopwatch counter
    // ------------------------------------------------------------

    logic [6:0] live_minutes;
    logic [5:0] live_seconds;
    logic [6:0] live_centiseconds;

    stopwatch_counter #(
        .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
    ) u_stopwatch_counter (
        .clk          (clk),
        .rst          (counter_rst),
        .enable       (counter_enable),
        .minutes      (live_minutes),
        .seconds      (live_seconds),
        .centiseconds (live_centiseconds)
    );

    // ------------------------------------------------------------
    // 4. Freeze the displayed time during lap hold
    //
    // Pack all three time fields into one bus so that they are
    // captured and released together.
    // ------------------------------------------------------------

    logic [19:0] live_time;
    logic [19:0] displayed_time;

    assign live_time = {
        live_minutes,
        live_seconds,
        live_centiseconds
    };

    snapshot_mux #(
        .WIDTH(20)
    ) u_snapshot_mux (
        .clk  (clk),
        .hold (lap_hold),
        .d    (live_time),
        .q    (displayed_time)
    );

    // ------------------------------------------------------------
    // 5. Connect the time values to the decimal display driver
    //
    // decimal_display_driver converts each value into two digits.
    // ------------------------------------------------------------

    assign {
        hours_disp,
        minutes_disp,
        seconds_disp
    } = {
        7'd0,
        displayed_time[19:13],
        displayed_time[12:7],
        displayed_time[6:0]
    };

    // Display all three pairs, including leading zeros.
    assign blank_hours   = 1'b0;
    assign blank_minutes = 1'b0;
    assign blank_seconds = 1'b0;

    // ------------------------------------------------------------
    // 6. Status LEDs
    // ------------------------------------------------------------

    always_comb begin
        led = '0;
        led[0] = counter_enable;
        led[1] = lap_hold;
        led[2] = counter_rst;
    end

endmodule
