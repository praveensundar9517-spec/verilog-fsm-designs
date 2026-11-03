`timescale 1ns / 1ps

module tb_d_flip_flop_4bit;
    // Inputs
    reg clk;
    reg reset;
    reg [3:0] d;

    // Outputs
    wire [3:0] q;

    // Instantiate the top module
    d_flip_flop_4bit uut (
        .clk(clk),
        .reset(reset),
        .d(d),
        .q(q)
    );

    // 100 MHz Clock Generation
    always #5 clk = ~clk;

    initial begin
        // Initialize inputs
        clk = 0;
        reset = 1;
        d = 4'b0000;
        
        // Hold reset for one clock cycle
        #10;
        reset = 0;
        
        // Test Case 1: Send decimal 10 (binary 1010)
        d = 4'b1010;
        #13; // Irregular delay to verify edge-triggering
        
        // Test Case 2: Send decimal 5 (binary 0101)
        d = 4'b0101;
        #17;
        
        // Test Case 3: Send decimal 15 (binary 1111)
        d = 4'b1111;
        #10;
        
        $finish;
    end
endmodule
