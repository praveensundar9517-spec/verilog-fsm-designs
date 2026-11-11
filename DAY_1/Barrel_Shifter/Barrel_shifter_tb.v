`timescale 1ns/1ps

module shifter_tb;
    reg signed [31:0] in_data;
    reg [4:0] shamt;
    reg [1:0] shift_type;
    wire [31:0] out_data;
    
    integer i, errors = 0;
    reg [31:0] expected_out;

    shifter uut (.in_data(in_data), .shamt(shamt), .shift_type(shift_type), .out_data(out_data));

    initial begin
        in_data = 32'h87654321; // Mix of 1s and 0s, MSB is 1 (negative if signed)
        
        for (i = 0; i < 32; i = i + 1) begin
            shamt = i;
            
            // SLL
            shift_type = 2'b00; #1;
            expected_out = in_data << shamt;
            if (out_data !== expected_out) begin
                $display("FAIL: SLL by %0d | Exp: %h, Got: %h", shamt, expected_out, out_data);
                errors = errors + 1;
            end
            
            // SRL
            shift_type = 2'b01; #1;
            expected_out = $unsigned(in_data) >> shamt; // Force logical
            if (out_data !== expected_out) begin
                $display("FAIL: SRL by %0d | Exp: %h, Got: %h", shamt, expected_out, out_data);
                errors = errors + 1;
            end
            
            // SRA
            shift_type = 2'b10; #1;
            expected_out = in_data >>> shamt;
            if (out_data !== expected_out) begin
                $display("FAIL: SRA by %0d | Exp: %h, Got: %h", shamt, expected_out, out_data);
                errors = errors + 1;
            end
        end

        if (errors == 0) $display("PASS: All shifter tests completed successfully."); //[cite: 2]
        else $display("Finished with %0d errors.", errors);
        $finish;
    end
endmodule