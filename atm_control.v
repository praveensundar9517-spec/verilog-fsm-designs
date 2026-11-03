`timescale 1ns / 1ps

module atm_control (
    input wire clk,
    input wire reset,
    input wire card_in,
    input wire pin_correct,
    input wire pin_wrong,
    input wire req_withdraw,
    input wire req_balance,      // New: User requests balance
    input wire funds_available,  // New: Datapath says funds are sufficient
    input wire ack_btn,          // New: User presses OK to dismiss screen
    input wire cash_taken,
    input wire card_taken,

    output reg prompt_pin,
    output reg show_menu,
    output reg dispense_cash,
    output reg display_bal,      // New: Show balance on screen
    output reg show_no_funds,    // New: Show insufficient funds error
    output reg eject_card
);

    // Moore FSM state encoding (Expanded to 3 bits for up to 8 states)
    parameter IDLE       = 3'b000,
              AUTH       = 3'b001,
              MENU       = 3'b010,
              PROCESS    = 3'b011,
              SHOW_BAL   = 3'b100, // New State
              NO_FUNDS   = 3'b101, // New State
              EJECT      = 3'b110;

    reg [2:0] state, next_state;

    // 1. State register
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    // 2. Next-state logic
    always @(*) begin
        next_state = state; 

        case (state)
            IDLE:
                if (card_in)
                    next_state = AUTH;

            AUTH:
                if (pin_correct)
                    next_state = MENU;
                else if (pin_wrong)
                    next_state = EJECT;

            MENU:
                if (req_balance) begin
                    next_state = SHOW_BAL;
                end else if (req_withdraw) begin
                    if (funds_available)
                        next_state = PROCESS;  // Has money -> Dispense
                    else
                        next_state = NO_FUNDS; // No money -> Error state
                end

            SHOW_BAL:
                if (ack_btn)
                    next_state = MENU; // Return to menu after checking balance

            NO_FUNDS:
                if (ack_btn)
                    next_state = EJECT; // Kick card out after acknowledging error

            PROCESS:
                if (cash_taken)
                    next_state = EJECT; 

            EJECT:
                if (card_taken)
                    next_state = IDLE;  

            default:
                next_state = IDLE;
        endcase
    end

    // 3. Moore output logic
    always @(*) begin
        prompt_pin    = 1'b0;
        show_menu     = 1'b0;
        dispense_cash = 1'b0;
        display_bal   = 1'b0;
        show_no_funds = 1'b0;
        eject_card    = 1'b0;

        case (state)
            AUTH:     prompt_pin    = 1'b1;
            MENU:     show_menu     = 1'b1;
            PROCESS:  dispense_cash = 1'b1;
            SHOW_BAL: display_bal   = 1'b1; // Trigger balance screen
            NO_FUNDS: show_no_funds = 1'b1; // Trigger error screen
            EJECT:    eject_card    = 1'b1;
            default: ; 
        endcase
    end

endmodule