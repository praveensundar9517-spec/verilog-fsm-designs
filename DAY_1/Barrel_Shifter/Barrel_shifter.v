module shifter (
    input signed [31:0] in_data,
    input [4:0] shamt,
    input [1:0] shift_type, // 00: SLL, 01: SRL, 10: SRA
    output reg [31:0] out_data
);

    always @(*) begin
        case (shift_type)
            2'b00: out_data = in_data << shamt;                 // SLL
            2'b01: out_data = in_data >> shamt;                 // SRL
            2'b10: out_data = in_data >>> shamt;                // SRA (Arithmetic shift requires signed input)
            default: out_data = 32'b0;
        endcase
    end

endmodule