module priority_encoder_casez (
    input [7:0] in,
    output reg [2:0] out,
    output valid
);
    assign valid = |in;
    always @(*) begin
        casez (in)
            8'b1???????: out = 3'd7;
            8'b01??????: out = 3'd6;
            8'b001?????: out = 3'd5;
            8'b0001????: out = 3'd4;
            8'b00001???: out = 3'd3;
            8'b000001??: out = 3'd2;
            8'b0000001?: out = 3'd1;
            8'b00000001: out = 3'd0;
            default: out = 3'd0;
        endcase
    end
endmodule

module priority_encoder_ifelse (
    input [7:0] in,
    output reg [2:0] out,
    output valid
);
    assign valid = |in;
    always @(*) begin
        if (in[7]) out = 3'd7;
        else if (in[6]) out = 3'd6;
        else if (in[5]) out = 3'd5;
        else if (in[4]) out = 3'd4;
        else if (in[3]) out = 3'd3;
        else if (in[2]) out = 3'd2;
        else if (in[1]) out = 3'd1;
        else if (in[0]) out = 3'd0;
        else out = 3'd0;
    end
endmodule