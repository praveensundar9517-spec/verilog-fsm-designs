// Activity 4.1: Data hazard detection and forwarding unit
// Verilog-2001, synthesizable.
module data_hazard_unit (
    input  wire [4:0] id_ex_rs,
    input  wire [4:0] id_ex_rt,
    input  wire [4:0] ex_mem_rd,
    input  wire       ex_mem_regwrite,
    input  wire [4:0] mem_wb_rd,
    input  wire       mem_wb_regwrite,
    input  wire       id_ex_memread,
    input  wire [4:0] if_id_rs,
    input  wire [4:0] if_id_rt,
    output reg  [1:0] forward_a,
    output reg  [1:0] forward_b,
    output wire      stall
);
    // 00 = ID/EX value, 10 = EX/MEM value, 01 = MEM/WB value
    always @* begin
        forward_a = 2'b00;
        forward_b = 2'b00;

        // EX/MEM has priority over MEM/WB when both match.
        if (ex_mem_regwrite && (ex_mem_rd != 5'd0) &&
            (ex_mem_rd == id_ex_rs))
            forward_a = 2'b10;
        else if (mem_wb_regwrite && (mem_wb_rd != 5'd0) &&
                 (mem_wb_rd == id_ex_rs))
            forward_a = 2'b01;

        if (ex_mem_regwrite && (ex_mem_rd != 5'd0) &&
            (ex_mem_rd == id_ex_rt))
            forward_b = 2'b10;
        else if (mem_wb_regwrite && (mem_wb_rd != 5'd0) &&
                 (mem_wb_rd == id_ex_rt))
            forward_b = 2'b01;
    end

    // Load-use hazard: the value being loaded is not ready for the next EX cycle.
    assign stall = id_ex_memread && (id_ex_rt != 5'd0) &&
                   ((id_ex_rt == if_id_rs) || (id_ex_rt == if_id_rt));
endmodule
