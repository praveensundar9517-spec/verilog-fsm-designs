module ram (
    input clk, we,
    input [3:0] addr,
    input [7:0] din,
    output [7:0] dout
);
    reg [7:0] mem [0:15];
    always @(posedge clk) begin
        if (we) mem[addr] <= din;
    end
    assign dout = mem[addr];
endmodule

module rom (
    input clk,
    input [3:0] addr,
    output reg [7:0] dout
);
    reg [7:0] mem [0:15];
    initial $readmemh("rom.hex", mem); // Ensure a rom.hex file exists in your Vivado project dir
    always @(posedge clk) dout <= mem[addr];
endmodule

module watchdog (
    input clk, rst, kick,
    output reg wdt_rst
);
    reg [3:0] timer; // Shortened to 4 bits (15 cycles) for fast simulation
    always @(posedge clk) begin
        if (rst || kick) begin 
            timer <= 0; wdt_rst <= 0; 
        end else if (timer == 4'd15) begin
            wdt_rst <= 1; 
        end else begin
            timer <= timer + 1;
        end
    end
endmodule