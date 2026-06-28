// display_controller.v
// Receives 2-bit credit, outputs segment display signal
// Purely combinational - no clock needed

module display_controller #(
    parameter SEGMENTS = 3
)(
    input  wire [1:0]          credit,
    output reg  [SEGMENTS-1:0] segments
);

    always @(*) begin
        case (credit)
            2'd0:    segments = 3'b000;
            2'd1:    segments = 3'b001;
            2'd2:    segments = 3'b010;
            default: segments = 3'b000;
        endcase
    end

endmodule