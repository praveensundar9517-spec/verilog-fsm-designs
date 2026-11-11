module lfsr (
    input clk, rst, load_seed,
    input [7:0] seed,
    output reg [7:0] q
);
    wire feedback = q[7] ^ q[5] ^ q[4] ^ q[3];
    
    always @(posedge clk) begin
        if (rst) q <= 8'h01; // Avoid all-zero state
        else if (load_seed) q <= seed;
        else q <= {q[6:0], feedback};
    end
endmodule