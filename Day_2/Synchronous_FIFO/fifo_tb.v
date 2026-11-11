`timescale 1ns/1ps
module fifo_tb;
    reg clk, rst, we, re;
    reg [7:0] din;
    wire [7:0] dout;
    wire full, empty;
    integer i;
    integer errors = 0;

    fifo #(16, 8) dut (
        .clk(clk), .rst(rst), .we(we), .re(re), 
        .din(din), .dout(dout), .full(full), .empty(empty)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1; we = 0; re = 0; din = 0; 
        #15 rst = 0;

        // Test 1: Fill to full
        we = 1;
        for (i = 0; i < 16; i = i + 1) begin
            din = i; #10;
        end
        we = 0;
        if (full !== 1) errors = errors + 1;

        // Test 2: Drain to empty
        re = 1;
        for (i = 0; i < 16; i = i + 1) begin
            if (dout !== i) errors = errors + 1;
            #10;
        end
        re = 0;
        if (empty !== 1) errors = errors + 1;

        if (errors == 0) $display("STATUS: PASS - FIFO");
        else $display("STATUS: FAIL - FIFO (%0d errors)", errors);
        $finish;
    end
endmodule