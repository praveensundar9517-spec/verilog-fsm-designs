module traffic (
    input clk, rst, ped_req,
    output reg r, y, g, walk
);
    reg [1:0] state, next;
    reg [3:0] count;
    reg ped_pending;

    always @(posedge clk) begin
        if (rst) begin 
            state <= 0; count <= 5; ped_pending <= 0; 
        end else begin
            if (ped_req && state != 3) ped_pending <= 1;
            
            if (count > 0) count <= count - 1;
            else begin
                state <= next;
                case(next)
                    0: count <= 5; // Green
                    1: count <= 2; // Yellow
                    2: count <= 5; // Red
                    3: begin count <= 4; ped_pending <= 0; end // Walk
                endcase
            end
        end
    end

    always @(*) begin
        next = state;
        r = 0; y = 0; g = 0; walk = 0;
        case(state)
            0: begin g = 1; if (count == 0) next = 1; end
            1: begin y = 1; if (count == 0) next = ped_pending ? 3 : 2; end
            2: begin r = 1; if (count == 0) next = 0; end
            3: begin walk = 1; r = 1; if (count == 0) next = 2; end
        endcase
    end
endmodule