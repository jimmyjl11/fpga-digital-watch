`timescale 1ns / 1ps

module stopwatch_counter #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [6:0] minutes,
    output logic [5:0] seconds,
    output logic [6:0] centiseconds
);

    logic centi_tick;
    logic counter_enable;

    assign counter_enable = enable && !rst;

    restartable_rate_generator #( // tick gen for every centisecond
        .CYCLE_COUNT(CYCLES_PER_SECOND / 100)
    ) u_centisecond_generator (
        .clk(clk),
        .run(counter_enable),
        .tick(centi_tick)
    );

    cascade_counter #( // cascade the tick gen into counter and connect to outputs
        .N2(100), .N1(60), .N0(100),
        .W2(7),   .W1(6),  .W0(7)
    ) u_stopwatch_counter (
        .clk(clk),
        .rst(rst),
        .enable(counter_enable && centi_tick),
        .count2(minutes),
        .count1(seconds),
        .count0(centiseconds)
    );

endmodule
