`timescale 1ns/1ps
module enc_dec_tb;
    reg [7:0] in_enc;
    wire [2:0] out_casez, out_ifelse;
    wire val_casez, val_ifelse;
    
    reg [2:0] in_dec;
    reg en_dec;
    wire [7:0] out_dec;
    
    integer i, errors = 0;

    priority_encoder_casez u_enc1 (.in(in_enc), .out(out_casez), .valid(val_casez));
    priority_encoder_ifelse u_enc2 (.in(in_enc), .out(out_ifelse), .valid(val_ifelse));
    decoder_3to8 u_dec (.in(in_dec), .en(en_dec), .out(out_dec));

    initial begin
        // Test Encoder match
        for (i = 0; i < 256; i = i + 1) begin
            in_enc = i; #1;
            if (out_casez !== out_ifelse || val_casez !== val_ifelse) begin
                $display("FAIL: Encoders mismatch at in=%b", in_enc);
                errors = errors + 1;
            end
        end
        
        // Test Decoder
        for (i = 0; i < 16; i = i + 1) begin // loop includes enable bit
            en_dec = i[3]; in_dec = i[2:0]; #1;
            if (en_dec && out_dec !== (8'd1 << in_dec)) begin
                $display("FAIL: Decoder en=1 in=%d", in_dec); errors = errors + 1;
            end else if (!en_dec && out_dec !== 8'b0) begin
                $display("FAIL: Decoder en=0 in=%d", in_dec); errors = errors + 1;
            end
        end
        
        if (errors == 0) $display("PASS: All Encoder/Decoder tests passed.");
        $finish;
    end
endmodule