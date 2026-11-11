`timescale 1ns/1ps
module arbiter_tb;
    reg clk, rst;
    reg [3:0] req;
    wire [3:0] grant;
    integer errors = 0;

    arbiter dut (.clk(clk), .rst(rst), .req(req), .grant(grant));
    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1; req = 0; #15 rst = 0;
        
        // Request 0 and 1
        req = 4'b0011; #10;
        if (grant !== 4'b0001) errors = errors + 1;
        
        // Release 0, 1 should get grant
        req = 4'b0010; #10;
        if (grant !== 4'b0010) errors = errors + 1;

        if (errors == 0) $display("STATUS: PASS - Arbiter");
        else $display("STATUS: FAIL - Arbiter");
        $finish;
    end
endmodule