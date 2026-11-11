module adder_sub (
    input [7:0] a,
    input [7:0] b,
    input mode, // 0 = Add, 1 = Subtract
    output [7:0] result,
    output cout,
    output overflow
);
    wire [8:0] carry;
    wire [7:0] b_mux;
    
    assign carry[0] = mode;
    
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : rca_loop
            assign b_mux[i] = b[i] ^ mode;
            full_adder fa (
                .a(a[i]),
                .b(b_mux[i]),
                .cin(carry[i]),
                .sum(result[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate

    assign cout = carry[8];
    assign overflow = carry[8] ^ carry[7]; // Signed overflow flag
endmodule