// vending_machine.v
// Moore FSM vending machine controller
// Parameterised: COINS_NEEDED configurable at instantiation

module vending_machine #(
    parameter COINS_NEEDED = 2
)(
    input  wire clk,
    input  wire rst,
    input  wire coin,
    input  wire cancel,
    output reg  dispense,
    output reg  [1:0] credit
);

    // State encoding - localparam: internal constants only
    localparam IDLE = 2'b00;
    localparam ONE  = 2'b01;
    localparam TWO  = 2'b10;

    // Internal state registers
    reg [1:0] current_state;
    reg [1:0] next_state;

    // assign: busy goes high instantly when machine is occupied
    wire busy;
    assign busy = (current_state != IDLE);

    // Sequential block: moves state on rising clock edge
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Combinational block: calculates next state
    // cancel has priority - checked first with if/else
    always @(*) begin
        if (cancel) begin
            next_state = IDLE;
        end else begin
            case (current_state)
                IDLE:    next_state = coin ? ONE  : IDLE;
                ONE:     next_state = coin ? TWO  : ONE;
                TWO:     next_state = IDLE;
                default: next_state = IDLE;
            endcase
        end
    end

    // Output logic: dispense (Moore - state only)
    always @(*) begin
        if (current_state == TWO)
            dispense = 1;
        else
            dispense = 0;
    end

    // Output logic: credit (Moore - state only)
    always @(*) begin
        case (current_state)
            IDLE:    credit = 2'd0;
            ONE:     credit = 2'd1;
            TWO:     credit = 2'd2;
            default: credit = 2'd0;
        endcase
    end

endmodule