`timescale 1ns/1ps

module alu_tb;
    parameter DATA_WIDTH = 32;
    reg [DATA_WIDTH-1:0] a, b;
    reg [3:0] alu_ctrl;
    wire [DATA_WIDTH-1:0] result;
    wire zero, negative, carry, overflow;

    integer errors = 0;
    integer test_count = 0;

    alu #(DATA_WIDTH) uut (
        .a(a), .b(b), .alu_ctrl(alu_ctrl),
        .result(result), .zero(zero), .negative(negative),
        .carry(carry), .overflow(overflow)
    );

    task check_output;
        input [DATA_WIDTH-1:0] exp_res;
        input exp_z, exp_n, exp_c, exp_v;
        input [80*8:1] test_name;
        begin
            #1; // wait for combinational logic
            test_count = test_count + 1;
            if (result !== exp_res || zero !== exp_z || negative !== exp_n || carry !== exp_c || overflow !== exp_v) begin
                $display("FAIL: %s | a=%h b=%h ctrl=%b | Got: res=%h z=%b n=%b c=%b v=%b | Exp: res=%h z=%b n=%b c=%b v=%b",
                          test_name, a, b, alu_ctrl, result, zero, negative, carry, overflow, exp_res, exp_z, exp_n, exp_c, exp_v);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        // ADD Tests
        a = 32'h00000005; b = 32'h0000000A; alu_ctrl = 4'b0000; check_output(32'h0000000F, 0, 0, 0, 0, "ADD Basic");
        a = 32'hFFFFFFFF; b = 32'h00000001; alu_ctrl = 4'b0000; check_output(32'h00000000, 1, 0, 1, 0, "ADD Carry out");
        a = 32'h7FFFFFFF; b = 32'h00000001; alu_ctrl = 4'b0000; check_output(32'h80000000, 0, 1, 0, 1, "ADD Overflow (Pos+Pos)");
        a = 32'h80000000; b = 32'h80000000; alu_ctrl = 4'b0000; check_output(32'h00000000, 1, 0, 1, 1, "ADD Overflow (Neg+Neg)");
        
        // SUB Tests
        a = 32'h0000000A; b = 32'h00000005; alu_ctrl = 4'b0001; check_output(32'h00000005, 0, 0, 1, 0, "SUB Basic");
        a = 32'h00000005; b = 32'h00000005; alu_ctrl = 4'b0001; check_output(32'h00000000, 1, 0, 1, 0, "SUB Zero");
        a = 32'h80000000; b = 32'h00000001; alu_ctrl = 4'b0001; check_output(32'h7FFFFFFF, 0, 0, 1, 1, "SUB Overflow (Neg-Pos)");
        
        // Logic Tests
        a = 32'hF0F0F0F0; b = 32'h0F0F0F0F; alu_ctrl = 4'b0010; check_output(32'h00000000, 1, 0, 0, 0, "AND Mask");
        a = 32'hF0F0F0F0; b = 32'h0F0F0F0F; alu_ctrl = 4'b0011; check_output(32'hFFFFFFFF, 0, 1, 0, 0, "OR Mask");
        a = 32'hAAAAAAAA; b = 32'h55555555; alu_ctrl = 4'b0100; check_output(32'hFFFFFFFF, 0, 1, 0, 0, "XOR Inv");
        
        // Shift Tests
        a = 32'h00000001; b = 32'h0000001F; alu_ctrl = 4'b0101; check_output(32'h80000000, 0, 1, 0, 0, "SLL Max");
        a = 32'h80000000; b = 32'h0000001F; alu_ctrl = 4'b0110; check_output(32'h00000001, 0, 0, 0, 0, "SRL Max");
        
        // SLT Tests
        a = 32'h00000005; b = 32'h0000000A; alu_ctrl = 4'b0111; check_output(32'h00000001, 0, 0, 0, 0, "SLT (Pos < Pos)");
        a = 32'hFFFFFFF6; b = 32'h0000000A; alu_ctrl = 4'b0111; check_output(32'h00000001, 0, 0, 0, 0, "SLT (Neg < Pos)");
        a = 32'h0000000A; b = 32'hFFFFFFF6; alu_ctrl = 4'b0111; check_output(32'h00000000, 1, 0, 0, 0, "SLT (Pos > Neg)");
        a = 32'h80000000; b = 32'h7FFFFFFF; alu_ctrl = 4'b0111; check_output(32'h00000001, 0, 0, 0, 0, "SLT (Max Neg < Max Pos)");

        if (errors == 0 && test_count >= 25) $display("PASS: All %0d ALU tests completed successfully.", test_count); //[cite: 2, 3]
        else $display("Finished with %0d errors out of %0d tests.", errors, test_count);
        $finish;
    end
endmodule