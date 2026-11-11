`timescale 1ns/1ps
module lfsr_tb;
    reg clk, rst, load_seed; reg [7:0] seed;
    wire [7:0] q;
    
    integer count = 0, errors = 0;
    reg [7:0] first_val;

    lfsr uut (.clk(clk), .rst(rst), .load_seed(load_seed), .seed(seed), .q(q));

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1; load_seed = 0; seed = 8'hAA;
        @(negedge clk) rst = 0; load_seed = 1; 
        @(negedge clk) load_seed = 0;
        
        first_val = q;
        
        repeat (300) begin
            @(negedge clk);
            count = count + 1;
            if (q == 8'h00) begin
                $display("FAIL: LFSR hit all-zero state"); errors = errors + 1;
            end
            if (q == first_val && count > 0) begin
                if (count !== 255) begin
                    $display("FAIL: LFSR repeated after %0d states, expected 255", count);
                    errors = errors + 1;
                end
                $display("LFSR repeated at %0d states.", count);
                count = 0; // reset for next check
            end
        end
        
        if (errors == 0) $display("PASS: LFSR verified 255 max-length sequence.");
        $finish;
    end
endmodule