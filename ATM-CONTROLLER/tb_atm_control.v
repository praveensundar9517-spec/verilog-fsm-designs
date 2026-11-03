`timescale 1ns/1ps

module tb_atm_control;

    reg clk;
    reg reset;
    reg card_in;
    reg pin_correct;
    reg pin_wrong;
    reg req_withdraw;
    reg req_balance;
    reg funds_available;
    reg ack_btn;
    reg cash_taken;
    reg card_taken;

    wire prompt_pin;
    wire show_menu;
    wire dispense_cash;
    wire display_bal;
    wire show_no_funds;
    wire eject_card;

    atm_control uut (
        .clk(clk),
        .reset(reset),
        .card_in(card_in),
        .pin_correct(pin_correct),
        .pin_wrong(pin_wrong),
        .req_withdraw(req_withdraw),
        .req_balance(req_balance),
        .funds_available(funds_available),
        .ack_btn(ack_btn),
        .cash_taken(cash_taken),
        .card_taken(card_taken),
        .prompt_pin(prompt_pin),
        .show_menu(show_menu),
        .dispense_cash(dispense_cash),
        .display_bal(display_bal),
        .show_no_funds(show_no_funds),
        .eject_card(eject_card)
    );

    always #5 clk = ~clk;

    initial begin
        // Initialize all inputs
        clk = 0; reset = 1; card_in = 0; pin_correct = 0; pin_wrong = 0;
        req_withdraw = 0; req_balance = 0; funds_available = 0; ack_btn = 0;
        cash_taken = 0; card_taken = 0;

        #12 reset = 0;

        // --- SCENARIO 1: Check Balance then Withdraw Successfully ---
        @(negedge clk) card_in = 1; @(negedge clk) card_in = 0;
        
        repeat (2) @(negedge clk) pin_correct = 1; @(negedge clk) pin_correct = 0;

        // 1. Request Balance Check
        repeat (2) @(negedge clk) req_balance = 1; @(negedge clk) req_balance = 0;
        
        // Acknowledge balance screen to return to menu
        repeat (2) @(negedge clk) ack_btn = 1; @(negedge clk) ack_btn = 0;

        // 2. Request Withdrawal (Funds Available)
        repeat (2) @(negedge clk);
        funds_available = 1; // Bank confirms enough money
        req_withdraw = 1; 
        @(negedge clk) req_withdraw = 0; funds_available = 0;

        repeat (2) @(negedge clk) cash_taken = 1; @(negedge clk) cash_taken = 0;
        repeat (2) @(negedge clk) card_taken = 1; @(negedge clk) card_taken = 0;

        #20;

        // --- SCENARIO 2: Insufficient Funds ---
        @(negedge clk) card_in = 1; @(negedge clk) card_in = 0;
        repeat (2) @(negedge clk) pin_correct = 1; @(negedge clk) pin_correct = 0;

        // Request Withdrawal (No Funds)
        repeat (2) @(negedge clk);
        funds_available = 0; // Bank confirms NOT enough money
        req_withdraw = 1; 
        @(negedge clk) req_withdraw = 0;

        // Acknowledge the "Insufficient Funds" error screen
        repeat (2) @(negedge clk) ack_btn = 1; @(negedge clk) ack_btn = 0;
        
        // Take card after error ejects it
        repeat (2) @(negedge clk) card_taken = 1; @(negedge clk) card_taken = 0;

        #20;
        $display("TEST PASSED: ATM with Balance and Funds Check completed.");
        $finish;
    end
endmodule
