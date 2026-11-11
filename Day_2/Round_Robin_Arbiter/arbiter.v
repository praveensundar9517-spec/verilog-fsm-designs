module arbiter (
    input clk, rst,
    input [3:0] req,
    output reg [3:0] grant
);
    reg [1:0] turn;
    
    always @(posedge clk) begin
        if (rst) begin 
            grant <= 0; turn <= 0; 
        end else if (grant == 0) begin
            if (req[turn]) grant[turn] <= 1;
            else if (req[(turn+1)%4]) begin grant[(turn+1)%4] <= 1; turn <= (turn+1)%4; end
            else if (req[(turn+2)%4]) begin grant[(turn+2)%4] <= 1; turn <= (turn+2)%4; end
            else if (req[(turn+3)%4]) begin grant[(turn+3)%4] <= 1; turn <= (turn+3)%4; end
        end else if (req[turn] == 0) begin
            grant <= 0; turn <= (turn + 1) % 4; // Move to next requester when released
        end
    end
endmodule
