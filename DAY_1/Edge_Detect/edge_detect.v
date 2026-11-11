module edge_detect (
    input clk, rst, in,
    output rising_pulse
);
    reg in_d;
    always @(posedge clk) begin
        if (rst) in_d <= 1'b0;
        else in_d <= in;
    end
    assign rising_pulse = in & ~in_d; // Pulse on 0->1 transition
endmodule