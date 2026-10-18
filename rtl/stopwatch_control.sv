`timescale 1ns / 1ps

module stopwatch_control (
    input logic clk,
    input logic rise_start_stop,
    input logic rise_lap,
    output logic counter_rst,
    output logic counter_enable,
    output logic lap_hold
);

    initial begin
        counter_rst    = 1'b0;
        counter_enable = 1'b0;
        lap_hold       = 1'b0;
    end

    always_ff @(posedge clk) begin
        // Default: reset pulse lasts one cycle.
        counter_rst <= 1'b0;

        // Ignore simultaneous button presses.
        if (rise_start_stop && rise_lap) begin
            // Leave control state unchanged.
        end
        else if (rise_start_stop) begin
            // Toggle running/stopped; preserve lap state.
            counter_enable <= ~counter_enable;
        end
        else if (rise_lap) begin
            if (counter_enable) begin
                // Running: toggle frozen/live display.
                lap_hold <= ~lap_hold;
            end
            else if (lap_hold) begin
                // Stopped and frozen: return to live display.
                lap_hold <= 1'b0;
            end
            else begin
                // Stopped and live: reset the stopwatch.
                counter_rst <= 1'b1;
            end
        end
    end

endmodule
