// top.v
// Top level: pure glue logic, no always blocks, no reg
// Instantiates vending_machine and display_controller
// Connects them via internal wire credit_wire

module top #(
    parameter COINS_NEEDED = 2,
    parameter SEGMENTS     = 3
)(
    input  wire clk,
    input  wire rst,
    input  wire coin,
    input  wire cancel,
    output wire dispense,
    output wire [SEGMENTS-1:0] segments
);

    // Internal wire connecting vending_machine output to display input
    // Must be wire - driven by module output, not an always block
    wire [1:0] credit_wire;

    // Child module 1: vending machine
    vending_machine #(
        .COINS_NEEDED(COINS_NEEDED)
    ) u_vending (
        .clk     (clk),
        .rst     (rst),
        .coin    (coin),
        .cancel  (cancel),
        .dispense(dispense),
        .credit  (credit_wire)
    );

    // Child module 2: display controller
    display_controller #(
        .SEGMENTS(SEGMENTS)
    ) u_display (
        .credit  (credit_wire),
        .segments(segments)
    );

endmodule