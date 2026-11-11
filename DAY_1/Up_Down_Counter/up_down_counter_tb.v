`timescale 1ns/1ps

module counter_tb;
    reg clk, rst, en, up_down, load;
    reg [7:0] load_data;
    wire [7:0] count;
    
    integer errors = 0;

    counter uut (.clk(clk), .rst(rst), .en(en), .up_down(up_down), .load(load), .load_data(load_data), .count(count));

    always #5 clk = ~clk;

    task check_count;
        input [7:0] exp_count;
        input [80*8:1] msg;
        begin
            #1; // sample after clock edge
            if (count !== exp_count) begin
                $display("FAIL: %s | Expected: %h, Got: %h", msg, exp_count, count);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        clk = 0; rst = 1; en = 0; up_down = 1; load = 0; load_data = 8'h00;
        
        @(negedge clk) rst = 0; check_count(8'h00, "Reset release");
        
        // Test Load
        @(negedge clk) load = 1; load_data = 8'hAA; 
        @(negedge clk) load = 0; check_count(8'hAA, "Parallel Load");
        
        // Test Count Up
        en = 1; up_down = 1;
        @(negedge clk) check_count(8'hAB, "Count Up 1");
        @(negedge clk) check_count(8'hAC, "Count Up 2");
        
        // Test Count Down
        up_down = 0;
        @(negedge clk) check_count(8'hAB, "Count Down 1");
        @(negedge clk) check_count(8'hAA, "Count Down 2");
        
        // Test Disable
        en = 0;
        @(negedge clk) check_count(8'hAA, "Enable Low Hold");
        
        // Test Sync Reset overrides Enable
        en = 1; rst = 1;
        @(negedge clk) check_count(8'h00, "Sync Reset");

        if (errors == 0) $display("PASS: All counter tests completed successfully."); //[cite: 2]
        else $display("Finished with %0d errors.", errors);
        $finish;
    end
endmodule