module fifo #(parameter DEPTH = 16, W = 8)(
    input clk, rst, we, re,
    input [W-1:0] din,
    output [W-1:0] dout,
    output full, empty
);
    reg [W-1:0] mem [0:DEPTH-1];
    reg [3:0] wp, rp;
    reg [4:0] count;
    
    always @(posedge clk) begin
        if (rst) begin
            wp <= 0; rp <= 0; count <= 0;
        end else begin
            case ({we & ~full, re & ~empty})
                2'b10: begin // Write only
                    mem[wp] <= din; 
                    wp <= wp + 1; 
                    count <= count + 1; 
                end
                2'b01: begin // Read only
                    rp <= rp + 1; 
                    count <= count - 1; 
                end
                2'b11: begin // Simultaneous read and write
                    mem[wp] <= din; 
                    wp <= wp + 1; 
                    rp <= rp + 1; 
                    // Count remains unchanged
                end
            endcase
        end
    end
    
    assign dout = mem[rp];
    assign full = (count == DEPTH);
    assign empty = (count == 0);
endmodule
