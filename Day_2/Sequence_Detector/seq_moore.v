module seq_moore (
    input clk, rst, in,
    output out
);
    reg [2:0] state, next;
    
    always @(posedge clk) begin
        if (rst) state <= 3'd0;
        else state <= next;
    end
    
    always @(*) begin
        case(state)
            3'd0: next = in ? 3'd1 : 3'd0;
            3'd1: next = in ? 3'd1 : 3'd2;
            3'd2: next = in ? 3'd3 : 3'd0;
            3'd3: next = in ? 3'd4 : 3'd2;
            3'd4: next = in ? 3'd1 : 3'd2; // Overlap transition
            default: next = 3'd0;
        endcase
    end
    
    assign out = (state == 3'd4);
endmodule