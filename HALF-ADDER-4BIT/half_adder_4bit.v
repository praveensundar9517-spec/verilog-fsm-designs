`timescale 1ns / 1ps

module half_adder_4bit (
    input [3:0] A,
    input [3:0] B,
    output [3:0] Sum,
    output Cout
);

    assign {Cout, Sum} = A + B;

endmodule
