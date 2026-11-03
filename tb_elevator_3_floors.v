`timescale 1ns / 1ps

module tb_elevator_3_floors;

    reg clk;
    reg reset;
    reg req_1;
    reg req_3;

    wire [1:0] current_floor;
    wire door_open;

    // Module name & instantiated ports match elevator_3_floors exactly
    elevator_3_floors uut (
        .clk(clk),
        .reset(reset),
        .req_1(req_1),
        .req_3(req_3),
        .current_floor(current_floor),
        .door_open(door_open)
    );

    // 100 MHz Clock Generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        req_1 = 0;
        req_3 = 0;

        #12 reset = 0;

        // --- Test 1: Travel from Floor 1 to Floor 3 ---
        @(negedge clk);
        req_3 = 1;
        @(negedge clk);
        req_3 = 0;

        #40; // Observe Floor 2 pass-through with door closed

        // --- Test 2: Travel from Floor 3 to Floor 1 ---
        @(negedge clk);
        req_1 = 1;
        @(negedge clk);
        req_1 = 0;

        #40;

        $display("Express Elevator Simulation Passed!");
        $finish;
    end

    initial begin
        $monitor("Time=%0t | Floor=%d | DoorOpen=%b | Req1=%b Req3=%b",
                 $time, current_floor, door_open, req_1, req_3);
    end

endmodule