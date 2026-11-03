`timescale 1ns/1ps

(* dont_touch = "true" *) // Forces Vivado to synthesize the full CPU and prevents "empty design" errors
module riscv_5stage (
    input wire clk,
    input wire reset,
    output wire [31:0] probe_pc // Dummy output to prevent logic deletion
);

    // Memory & Registers
    reg [31:0] pc;
    
    // Wire the internal PC to the output port
    assign probe_pc = pc;

    reg [31:0] instruction_mem [0:63];
    reg [31:0] data_mem        [0:63];
    reg [31:0] registers       [0:31];

    // IF/ID Pipeline Register
    reg [31:0] if_id_pc, if_id_inst;

    // ID/EX Pipeline Register
    reg [31:0] id_ex_pc, id_ex_r1, id_ex_r2, id_ex_imm;
    reg [4:0]  id_ex_rs1, id_ex_rs2, id_ex_rd;
    reg [2:0]  id_ex_alu_ctrl; 
    reg        id_ex_alu_src, id_ex_mem_write, id_ex_mem_read, id_ex_branch, id_ex_reg_write, id_ex_mem_to_reg;

    // EX/MEM Pipeline Register
    reg [31:0] ex_mem_alu_res, ex_mem_r2;
    reg [4:0]  ex_mem_rd;
    reg        ex_mem_mem_write, ex_mem_mem_read, ex_mem_reg_write, ex_mem_mem_to_reg;

    // MEM/WB Pipeline Register
    reg [31:0] mem_wb_alu_res, mem_wb_mem_data;
    reg [4:0]  mem_wb_rd;
    reg        mem_wb_reg_write, mem_wb_mem_to_reg;

    // Global wire for Writeback data so the Decode stage can intercept it
    wire [31:0] wb_write_data = mem_wb_mem_to_reg ? mem_wb_mem_data : mem_wb_alu_res;

    // =========================================================================
    // CREATIVE FEATURE 2 & 3: DECODE STAGE, HAZARD DETECTION & INTERNAL BYPASS
    // =========================================================================
    wire [6:0] opcode = if_id_inst[6:0];
    wire [4:0] rd     = if_id_inst[11:7];
    wire [2:0] funct3 = if_id_inst[14:12];
    wire [4:0] rs1    = if_id_inst[19:15];
    wire [4:0] rs2    = if_id_inst[24:20];
    wire [6:0] funct7 = if_id_inst[31:25];

    // INTERNAL BYPASS: If WB stage is writing to the register we want to read, 
    // grab the new value immediately instead of reading the old register value.
    wire [31:0] rdata1 = (rs1 == 0) ? 32'd0 : 
                         (mem_wb_reg_write && (mem_wb_rd == rs1)) ? wb_write_data : 
                         registers[rs1];
                         
    wire [31:0] rdata2 = (rs2 == 0) ? 32'd0 : 
                         (mem_wb_reg_write && (mem_wb_rd == rs2)) ? wb_write_data : 
                         registers[rs2];

    wire [31:0] imm_i = {{20{if_id_inst[31]}}, if_id_inst[31:20]};
    wire [31:0] imm_s = {{20{if_id_inst[31]}}, if_id_inst[31:25], if_id_inst[11:7]};
    wire [31:0] imm_b = {{19{if_id_inst[31]}}, if_id_inst[31], if_id_inst[7], if_id_inst[30:25], if_id_inst[11:8], 1'b0};

    reg [31:0] imm;
    reg        c_alu_src, c_mem_write, c_mem_read, c_branch, c_reg_write, c_mem_to_reg;
    reg [2:0]  c_alu_ctrl;

    always @(*) begin
        c_alu_src = 0; c_mem_write = 0; c_mem_read = 0; c_branch = 0; 
        c_reg_write = 0; c_mem_to_reg = 0; c_alu_ctrl = 3'b000;
        imm = 32'd0;

        case (opcode)
            7'b0110011: begin // R-type
                c_reg_write = 1;
                if (funct3 == 3'b000 && funct7 == 7'b0100000) c_alu_ctrl = 3'b001; // SUB
                else if (funct3 == 3'b000) c_alu_ctrl = 3'b000; // ADD
                else if (funct3 == 3'b111) c_alu_ctrl = 3'b010; // AND
                else if (funct3 == 3'b110) c_alu_ctrl = 3'b011; // OR
            end
            7'b0010011: begin // ADDI
                c_reg_write = 1; c_alu_src = 1; imm = imm_i; c_alu_ctrl = 3'b000;
            end
            7'b0000011: begin // LW
                c_reg_write = 1; c_alu_src = 1; c_mem_read = 1; c_mem_to_reg = 1; imm = imm_i; c_alu_ctrl = 3'b000;
            end
            7'b0100011: begin // SW
                c_mem_write = 1; c_alu_src = 1; imm = imm_s; c_alu_ctrl = 3'b000;
            end
            7'b1100011: begin // BEQ
                c_branch = 1; imm = imm_b; c_alu_ctrl = 3'b001; // SUB to compare
            end
            default: ; 
        endcase
    end

    // Hazard Detection Logic: Stalls pipeline if a Load-Use hazard is detected
    wire load_use_hazard = id_ex_mem_read && (id_ex_rd != 0) && ((id_ex_rd == rs1) || (id_ex_rd == rs2));

    // =========================================================================
    // CREATIVE FEATURE 1: EXECUTE STAGE & DYNAMIC FORWARDING UNIT
    // =========================================================================
    wire [1:0] forward_a = (ex_mem_reg_write && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs1) ? 2'b10 :
                           (mem_wb_reg_write && mem_wb_rd != 0 && mem_wb_rd == id_ex_rs1) ? 2'b01 : 2'b00;

    wire [1:0] forward_b = (ex_mem_reg_write && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs2) ? 2'b10 :
                           (mem_wb_reg_write && mem_wb_rd != 0 && mem_wb_rd == id_ex_rs2) ? 2'b01 : 2'b00;

    wire [31:0] alu_in1 = (forward_a == 2'b10) ? ex_mem_alu_res :
                          (forward_a == 2'b01) ? wb_write_data : id_ex_r1;
                          
    wire [31:0] fwd_in2 = (forward_b == 2'b10) ? ex_mem_alu_res :
                          (forward_b == 2'b01) ? wb_write_data : id_ex_r2;
                          
    wire [31:0] alu_in2 = id_ex_alu_src ? id_ex_imm : fwd_in2;

    reg [31:0] alu_result;
    always @(*) begin
        case (id_ex_alu_ctrl)
            3'b000: alu_result = alu_in1 + alu_in2; // ADD
            3'b001: alu_result = alu_in1 - alu_in2; // SUB
            3'b010: alu_result = alu_in1 & alu_in2; // AND
            3'b011: alu_result = alu_in1 | alu_in2; // OR
            default: alu_result = 32'd0;
        endcase
    end

    wire branch_taken = id_ex_branch && (alu_in1 == fwd_in2);
    wire [31:0] branch_target = id_ex_pc + id_ex_imm;

    // =========================================================================
    // PIPELINE CLOCKING SYSTEM
    // =========================================================================
    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 0;
            if_id_inst <= 32'h00000013; if_id_pc <= 0; // NOP
            id_ex_alu_ctrl <= 0; id_ex_reg_write <= 0; id_ex_mem_write <= 0; id_ex_branch <= 0; id_ex_mem_read <= 0; id_ex_rd <= 0;
            ex_mem_reg_write <= 0; ex_mem_mem_write <= 0; ex_mem_rd <= 0; ex_mem_mem_read <= 0;
            mem_wb_reg_write <= 0; mem_wb_rd <= 0;
            for (i = 0; i < 32; i = i + 1) registers[i] <= 32'd0;
        end else begin
            
            // --- STAGE 5: WRITE BACK (WB) ---
            if (mem_wb_reg_write && mem_wb_rd != 0) 
                registers[mem_wb_rd] <= wb_write_data;
                
            registers[0] <= 32'd0; // Hardwire x0

            // --- STAGE 4: MEMORY (MEM) ---
            mem_wb_alu_res    <= ex_mem_alu_res;
            mem_wb_rd         <= ex_mem_rd;
            mem_wb_reg_write  <= ex_mem_reg_write;
            mem_wb_mem_to_reg <= ex_mem_mem_to_reg;
            
            if (ex_mem_mem_read)
                mem_wb_mem_data <= data_mem[ex_mem_alu_res[7:2]];
            else
                mem_wb_mem_data <= 32'd0;

            if (ex_mem_mem_write)
                data_mem[ex_mem_alu_res[7:2]] <= ex_mem_r2;

            // --- STAGE 3: EXECUTE (EX) ---
            ex_mem_alu_res    <= alu_result;
            ex_mem_r2         <= fwd_in2;
            ex_mem_rd         <= id_ex_rd;
            ex_mem_mem_write  <= id_ex_mem_write;
            ex_mem_mem_read   <= id_ex_mem_read;
            ex_mem_reg_write  <= id_ex_reg_write;
            ex_mem_mem_to_reg <= id_ex_mem_to_reg;

            // --- STAGE 2: INSTRUCTION DECODE (ID) ---
            if (branch_taken || load_use_hazard) begin
                // Inject Bubble (NOP) if branch taken OR load-use hazard detected
                id_ex_reg_write <= 0; id_ex_mem_write <= 0; id_ex_branch <= 0; id_ex_mem_read <= 0;
            end else begin
                id_ex_pc         <= if_id_pc;
                id_ex_r1         <= rdata1;
                id_ex_r2         <= rdata2;
                id_ex_imm        <= imm;
                id_ex_rs1        <= rs1;
                id_ex_rs2        <= rs2;
                id_ex_rd         <= rd;
                id_ex_alu_ctrl   <= c_alu_ctrl;
                id_ex_alu_src    <= c_alu_src;
                id_ex_mem_write  <= c_mem_write;
                id_ex_mem_read   <= c_mem_read;
                id_ex_branch     <= c_branch;
                id_ex_reg_write  <= c_reg_write;
                id_ex_mem_to_reg <= c_mem_to_reg;
            end

            // --- STAGE 1: INSTRUCTION FETCH (IF) ---
            if (branch_taken) begin
                pc <= branch_target;
                if_id_inst <= 32'h00000013; // Flush IF/ID with NOP
                if_id_pc   <= branch_target;
            end else if (!load_use_hazard) begin
                // Only fetch new instruction if there is NO hazard. 
                if_id_inst <= instruction_mem[pc[7:2]];
                if_id_pc   <= pc;
                pc         <= pc + 32'd4;
            end

        end
    end

endmodule