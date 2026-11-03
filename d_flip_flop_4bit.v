`timescale 1ns / 1ps

module d_flip_flop_4bit (
    input clk,
    input reset,
    input [3:0] d,
    output reg [3:0] q
);

    always @(posedge clk) begin
        if (reset)
            q <= 4'b0000;
        else
            q <= d; // Captures all 4 bits simultaneously on the rising edge
    end

endmodule