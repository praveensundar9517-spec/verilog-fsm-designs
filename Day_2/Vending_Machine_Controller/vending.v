module vending (
    input clk, rst, coin_5, coin_10, cancel,
    output reg dispense, return_change, refund
);
    reg [4:0] balance, next_balance;
    
    always @(posedge clk) begin
        if (rst) balance <= 0;
        else balance <= next_balance;
    end
    
    always @(*) begin
        // Default assignments to prevent inferred latches
        dispense = 0; 
        return_change = 0; 
        refund = 0; 
        next_balance = balance;
        
        if (cancel) begin
            if (balance > 0) refund = 1;
            next_balance = 0;
        end else if (coin_5) begin
            next_balance = balance + 5;
        end else if (coin_10) begin
            next_balance = balance + 10;
        end
        
        if (next_balance >= 15) begin
            dispense = 1;
            if (next_balance > 15) return_change = 1;
            next_balance = 0;
        end
    end
endmodule