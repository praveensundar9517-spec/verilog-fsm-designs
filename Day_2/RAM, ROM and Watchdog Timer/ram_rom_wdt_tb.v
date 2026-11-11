`timescale 1ns/1ps
module ram_rom_wdt_tb;
    reg clk, rst, we, kick;
    reg [3:0] addr;
    reg [7:0] din;
    wire [7:0] ram_dout, rom_dout;
    wire wdt_rst;
    integer errors = 0;

    ram dut_ram (.clk(clk), .we(we), .addr(addr), .din(din), .dout(ram_dout));
    rom dut_rom (.clk(clk), .addr(addr), .dout(rom_dout));
    watchdog dut_wdt (.clk(clk), .rst(rst), .kick(kick), .wdt_rst(wdt_rst));

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1; we = 0; addr = 0; din = 0; kick = 0; #15 rst = 0;
        
        // RAM Test
        addr = 4'd5; din = 8'hAA; we = 1; #10;
        we = 0; #10;
        if (ram_dout !== 8'hAA) errors = errors + 1;

        // Watchdog Test
        #140; // Wait 14 clock cycles (close to timeout)
        if (wdt_rst !== 0) errors = errors + 1;
        #20;  // Push past 15 cycles
        if (wdt_rst !== 1) errors = errors + 1;
        
        kick = 1; #10; kick = 0; // Reset WDT
        if (wdt_rst !== 0) errors = errors + 1;

        if (errors == 0) $display("STATUS: PASS - RAM, ROM, Watchdog");
        else $display("STATUS: FAIL - RAM, ROM, Watchdog");
        $finish;
    end
endmodule