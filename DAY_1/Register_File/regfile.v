module regfile (
    input clk,
    input we,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] wd,
    output [31:0] rd1,
    output [31:0] rd2
);

    reg [31:0] registers [0:31];
    integer i;

    // Initialize registers
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'b0;
        end
    end

    // Synchronous write
    always @(posedge clk) begin
        if (we && rd != 5'b00000) begin
            registers[rd] <= wd;
        end
    end

    // Asynchronous read with bypass logic
    assign rd1 = (rs1 == 5'b00000) ? 32'b0 : 
                 (we && (rs1 == rd)) ? wd : registers[rs1];
                 
    assign rd2 = (rs2 == 5'b00000) ? 32'b0 : 
                 (we && (rs2 == rd)) ? wd : registers[rs2];

endmodule