module counter (
    input clk,
    input rst, // Synchronous reset
    input en,
    input up_down, // 1 for UP, 0 for DOWN
    input load,
    input [7:0] load_data,
    output reg [7:0] count
);

    always @(posedge clk) begin
        if (rst) begin
            count <= 8'b0;
        end else if (load) begin
            count <= load_data;
        end else if (en) begin
            if (up_down)
                count <= count + 1;
            else
                count <= count - 1;
        end
    end

endmodule