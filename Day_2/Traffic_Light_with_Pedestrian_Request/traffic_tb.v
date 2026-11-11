`timescale 1ns/1ps
module traffic_tb;
    reg clk, rst, ped_req;
    wire r, y, g, walk;
    integer errors = 0;

    traffic dut (.clk(clk), .rst(rst), .ped_req(ped_req), .r(r), .y(y), .g(g), .walk(walk));
    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1; ped_req = 0; #15 rst = 0;
        
        // Wait for Green, trigger pedestrian request
        #20 ped_req = 1; #10 ped_req = 0;
        
        // Wait for Yellow to finish, check if it goes to Walk
        #60; 
        if (walk !== 1) errors = errors + 1;

        if (errors == 0) $display("STATUS: PASS - Traffic Light");
        else $display("STATUS: FAIL - Traffic Light");
        $finish;
    end
endmodule