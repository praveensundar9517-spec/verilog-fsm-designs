`timescale 1ns / 1ps

module elevator_3_floors (
    input wire clk,
    input wire reset,
    input wire req_1, // Button to call Floor 1
    input wire req_3, // Button to call Floor 3 (Floor 2 request port is removed)
    output reg [1:0] current_floor,
    output reg door_open
);

    // Moore FSM State Encoding
    parameter FLOOR_1           = 2'b00,
              PASS_FLOOR_2_UP   = 2'b01,
              FLOOR_3           = 2'b10,
              PASS_FLOOR_2_DOWN = 2'b11;

    reg [1:0] state, next_state;

    // 1. Sequential State Register
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= FLOOR_1;
        else
            state <= next_state;
    end

    // 2. Combinational Next-State Logic
    always @(*) begin
        next_state = state; // Default: stay in current state

        case (state)
            FLOOR_1: begin
                if (req_3)
                    next_state = PASS_FLOOR_2_UP;
            end

            PASS_FLOOR_2_UP: begin
                // Move to Floor 3 without stopping on Floor 2
                next_state = FLOOR_3;
            end

            FLOOR_3: begin
                if (req_1)
                    next_state = PASS_FLOOR_2_DOWN;
            end

            PASS_FLOOR_2_DOWN: begin
                // Move to Floor 1 without stopping on Floor 2
                next_state = FLOOR_1;
            end

            default: next_state = FLOOR_1;
        endcase
    end

    // 3. Combinational Moore Output Logic
    always @(*) begin
        case (state)
            FLOOR_1: begin
                current_floor = 2'd1;
                door_open     = 1'b1; // Stopped at Floor 1 -> Doors open
            end

            PASS_FLOOR_2_UP, PASS_FLOOR_2_DOWN: begin
                current_floor = 2'd2; // Physical transit through Floor 2
                door_open     = 1'b0; // Doors stay CLOSED
            end

            FLOOR_3: begin
                current_floor = 2'd3;
                door_open     = 1'b1; // Stopped at Floor 3 -> Doors open
            end

            default: begin
                current_floor = 2'd1;
                door_open     = 1'b0;
            end
        endcase
    end

endmodule