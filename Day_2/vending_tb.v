`timescale 1ns/1ps
module vending_tb;
    reg clk, rst, coin_5, coin_10, cancel;
    wire dispense, return_change, refund;
    integer errors = 0;

    vending dut (
        .clk(clk), .rst(rst), .coin_5(coin_5), .coin_10(coin_10), 
        .cancel(cancel), .dispense(dispense), .return_change(return_change), .refund(refund)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1; coin_5 = 0; coin_10 = 0; cancel = 0; 
        #15 rst = 0;

        // Scenario 1: Insert 10 then 10 (Total 20: dispense + change)
        coin_10 = 1; #10; coin_10 = 0; #10;
        coin_10 = 1; #1;
        if (dispense !== 1 || return_change !== 1) errors = errors + 1;
        #9; coin_10 = 0; #10;

        // Scenario 2: Insert 5 then Cancel (Total 5: refund)
        coin_5 = 1; #10; coin_5 = 0; #10;
        cancel = 1; #1;
        if (refund !== 1) errors = errors + 1;
        #9; cancel = 0;

        if (errors == 0) $display("STATUS: PASS - Vending Machine");
        else $display("STATUS: FAIL - Vending Machine (%0d errors)", errors);
        $finish;
    end
endmodule
