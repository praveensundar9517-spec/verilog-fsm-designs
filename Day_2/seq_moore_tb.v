`timescale 1ns/1ps
module seq_moore_tb;
    reg clk, rst, in;
    wire out;
    integer errors = 0;

    seq_moore dut (.clk(clk), .rst(rst), .in(in), .out(out));
    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1; in = 0; #15 rst = 0;
        
        // Feed 1011
        in=1; #10; in=0; #10; in=1; #10; in=1; #10;
        if (out !== 1) errors = errors + 1;
        
        // Feed overlapping 011 (making 1011011)
        in=0; #10; in=1; #10; in=1; #10;
        if (out !== 1) errors = errors + 1;

        if (errors == 0) $display("STATUS: PASS - Moore Seq Detector");
        else $display("STATUS: FAIL - Moore Seq Detector");
        $finish;
    end
endmodule