`timescale 1ns / 1ps

module d_flip_flop (
    input clk,
    input reset,
    input d,
    output reg q
);

    always @(posedge clk) begin
        if (reset)
            q <= 1'b0;
        else
            q <= d; // Input is captured on the clock's rising edge
    end

endmodule
