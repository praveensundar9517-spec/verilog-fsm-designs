`timescale 1ns/1ps
module debounce_tb;
    reg clk, rst, noisy_in;
    wire clean_out, pulse;
    integer errors = 0, pulse_count = 0;

    debounce u_deb (.clk(clk), .rst(rst), .noisy_in(noisy_in), .clean_out(clean_out));
    edge_detect u_edge (.clk(clk), .rst(rst), .in(clean_out), .rising_pulse(pulse));

    always #5 clk = ~clk;
    
    always @(posedge clk) if (pulse) pulse_count = pulse_count + 1;

    initial begin
        clk = 0; rst = 1; noisy_in = 0;
        #15 rst = 0;
        
        // Simulate Bounce
        #12 noisy_in = 1; #10 noisy_in = 0; #15 noisy_in = 1; #8 noisy_in = 0;
        #12 noisy_in = 1; // Settles high
        
        #250; 
        if (pulse_count !== 1) begin
            $display("FAIL: Expected 1 clean pulse, got %0d", pulse_count);
            errors = errors + 1;
        end else $display("PASS: Debounce and edge detection produced a single clean pulse.");
        $finish;
    end
endmodule