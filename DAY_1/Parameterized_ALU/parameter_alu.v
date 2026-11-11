module alu #(parameter DATA_WIDTH = 32) (
    input [DATA_WIDTH-1:0] a,
    input [DATA_WIDTH-1:0] b,
    input [3:0] alu_ctrl,
    output reg [DATA_WIDTH-1:0] result,
    output zero,
    output negative,
    output carry,
    output overflow
);

    wire [DATA_WIDTH:0] sum_res;
    wire is_sub = (alu_ctrl == 4'b0001) || (alu_ctrl == 4'b0111); // SUB or SLT
    wire [DATA_WIDTH-1:0] b_mux = is_sub ? ~b + 1 : b;
    
    assign sum_res = {1'b0, a} + {1'b0, b_mux};

    always @(*) begin
        case (alu_ctrl)
            4'b0000: result = sum_res[DATA_WIDTH-1:0]; // ADD
            4'b0001: result = sum_res[DATA_WIDTH-1:0]; // SUB
            4'b0010: result = a & b;                   // AND
            4'b0011: result = a | b;                   // OR
            4'b0100: result = a ^ b;                   // XOR
            4'b0101: result = a << b[4:0];             // SLL (assuming 32-bit for shift limit)
            4'b0110: result = a >> b[4:0];             // SRL
            4'b0111: result = { {(DATA_WIDTH-1){1'b0}}, (a[DATA_WIDTH-1] != b[DATA_WIDTH-1]) ? a[DATA_WIDTH-1] : sum_res[DATA_WIDTH-1] }; // SLT
            default: result = {DATA_WIDTH{1'b0}};
        endcase
    end

    assign zero = (result == {DATA_WIDTH{1'b0}});
    assign negative = result[DATA_WIDTH-1];
    assign carry = (alu_ctrl == 4'b0000 || alu_ctrl == 4'b0001) ? sum_res[DATA_WIDTH] : 1'b0;
    assign overflow = (alu_ctrl == 4'b0000 || alu_ctrl == 4'b0001) ? 
                      (a[DATA_WIDTH-1] == b_mux[DATA_WIDTH-1] && result[DATA_WIDTH-1] != a[DATA_WIDTH-1]) : 1'b0;

endmodule