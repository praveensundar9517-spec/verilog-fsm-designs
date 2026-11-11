module shiftreg (
    input clk, rst,
    input [1:0] mode, // 00: Hold, 01: SLL, 10: SRL, 11: Load
    input [7:0] load_data,
    input s_in,       // Serial input for shifting
    output reg [7:0] q
);
    always @(posedge clk) begin
        if (rst) q <= 8'b0;
        else case (mode)
            2'b00: q <= q;
            2'b01: q <= {q[6:0], s_in};
            2'b10: q <= {s_in, q[7:1]};
            2'b11: q <= load_data;
        endcase
    end
endmodule