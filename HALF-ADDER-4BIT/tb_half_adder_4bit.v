`timescale 1ns / 1ps

module tb_half_adder_4bit;
    reg [3:0] A;
    reg [3:0] B;

    wire [3:0] Sum;
    wire Cout;

    half_adder_4bit uut (
        .A(A), 
        .B(B), 
        .Sum(Sum), 
        .Cout(Cout)
    );

    initial begin
        // Test Case 1: No carry out (3 + 5 = 8)
        A = 4'b0011; B = 4'b0101; 
        #10;
        
        // Test Case 2: Carry out triggers (15 + 1 = 16)
        A = 4'b1111; B = 4'b0001; 
        #10;
        
        // Test Case 3: Carry out with remaining sum (10 + 10 = 20)
        A = 4'b1010; B = 4'b1010; 
        #10;
        
        $finish;
    end
endmodule
