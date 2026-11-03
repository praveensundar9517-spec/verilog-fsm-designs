`timescale 1ns / 1ps

module tb_d_flip_flop;
    reg clk;
    reg reset;
    reg d;
    wire q;

    d_flip_flop uut (
        .clk(clk),
        .reset(reset),
        .d(d),
        .q(q)
    );

    // Generate a 100 MHz clock (toggles every 5ns for a 10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize inputs
        clk = 0;
        reset = 1;
        d = 0;
        
        // Hold reset for a clock cycle
        #10;
        reset = 0;
        
        // Test data transitions
        d = 1;
        #13; // Wait an irregular time to show it only triggers on the clock edge
        
        d = 0;
        #17;
        
        d = 1;
        #10;
        
        $finish;
    end
endmodule