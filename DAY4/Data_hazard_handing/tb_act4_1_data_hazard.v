`timescale 1ns/1ps
module tb_data_hazard_unit;
    reg [4:0] id_ex_rs, id_ex_rt, ex_mem_rd, mem_wb_rd, if_id_rs, if_id_rt;
    reg ex_mem_regwrite, mem_wb_regwrite, id_ex_memread;
    wire [1:0] forward_a, forward_b;
    wire stall;

    data_hazard_unit dut (
        .id_ex_rs(id_ex_rs), .id_ex_rt(id_ex_rt),
        .ex_mem_rd(ex_mem_rd), .ex_mem_regwrite(ex_mem_regwrite),
        .mem_wb_rd(mem_wb_rd), .mem_wb_regwrite(mem_wb_regwrite),
        .id_ex_memread(id_ex_memread), .if_id_rs(if_id_rs), .if_id_rt(if_id_rt),
        .forward_a(forward_a), .forward_b(forward_b), .stall(stall)
    );

    initial begin
        $display("time  fwdA fwdB stall");
        id_ex_rs=5'd1; id_ex_rt=5'd2; ex_mem_rd=5'd1; ex_mem_regwrite=1;
        mem_wb_rd=5'd2; mem_wb_regwrite=1; id_ex_memread=0;
        if_id_rs=0; if_id_rt=0;
        #10;
        $display("%4t   %b   %b    %b", $time, forward_a, forward_b, stall);
        if (forward_a !== 2'b10 || forward_b !== 2'b01) $fatal(1,"Forwarding priority test failed");

        id_ex_memread=1; id_ex_rt=5'd5; if_id_rs=5'd5; if_id_rt=0;
        #10;
        $display("%4t   %b   %b    %b", $time, forward_a, forward_b, stall);
        if (stall !== 1'b1) $fatal(1,"Load-use stall test failed");

        if_id_rs=5'd3; if_id_rt=5'd4;
        #10;
        if (stall !== 1'b0) $fatal(1,"Unexpected stall");
        $display("Activity 4.1 PASS");
        $finish;
    end
endmodule
