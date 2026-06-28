// tb_top.v
// Testbench for full hierarchy through top level module

module tb_top;

    // Testbench drives inputs  -> reg
    // Testbench observes outputs -> wire
    reg        clk;
    reg        rst;
    reg        coin;
    reg        cancel;
    wire       dispense;
    wire [2:0] segments;

    // Instantiate top with default parameters
    top #(
        .COINS_NEEDED(2),
        .SEGMENTS    (3)
    ) u_top (
        .clk     (clk),
        .rst     (rst),
        .coin    (coin),
        .cancel  (cancel),
        .dispense(dispense),
        .segments(segments)
    );

    // Clock generation: 10 time unit period
    initial clk = 0;
    always #5 clk = ~clk;

    // Waveform dump
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top);
    end

    // Monitor: prints whenever any watched signal changes
    initial begin
        $monitor("t=%0t | coin=%b | cancel=%b | state=%b | credit=%0d | dispense=%b | segments=%b",
                  $time,
                  coin,
                  cancel,
                  u_top.u_vending.current_state,
                  u_top.u_vending.credit,
                  dispense,
                  segments);
    end

    // Stimulus
    initial begin

        // Reset - initialise all inputs
        rst    = 1;
        coin   = 0;
        cancel = 0;
        #20;
        rst = 0;
        $display("--- Reset done. Expect state=IDLE, credit=0 ---");

        // TEST 1: Insert 1 coin
        // Expect: state IDLE->ONE, credit=1, dispense=0
        #10; coin = 1;
        #10; coin = 0;
        #10;
        $display("--- Test 1: After 1 coin ---");
        if (u_top.u_vending.credit == 2'd1)
            $display("PASS: credit=1 after 1 coin");
        else
            $display("FAIL: credit=%0d, expected 1", u_top.u_vending.credit);

        // TEST 2: Insert 2nd coin -> dispense
        // Expect: state ONE->TWO, dispense=1 briefly, back to IDLE
        #10; coin = 1;
        #10; coin = 0;
        #10;
        $display("--- Test 2: After 2nd coin ---");
        if (dispense == 0 && u_top.u_vending.current_state == 2'b00)
            $display("PASS: dispensed and returned to IDLE");
        else
            $display("FAIL: unexpected state after dispense");

        // TEST 3: Cancel after 1 coin
        // Expect: IDLE->ONE, cancel forces back to IDLE, no dispense
        #20;
        $display("--- Test 3: Insert coin then cancel ---");
        coin   = 1; #10;
        cancel = 1; #10;
        cancel = 0; coin = 0; 
        #20;

        if (u_top.u_vending.current_state == 2'b00 && dispense == 0)
            $display("PASS: cancel returned to IDLE, no dispense");
        else
            $display("FAIL: cancel did not work correctly");

        // TEST 4: Cancel from IDLE - edge case
        // Expect: stays in IDLE, no side effects
        #20;
        $display("--- Test 4: Cancel from IDLE ---");
        cancel = 1; #10;
        cancel = 0; #10;

        if (u_top.u_vending.current_state == 2'b00)
            $display("PASS: cancel from IDLE stays in IDLE");
        else
            $display("FAIL: cancel from IDLE broke state");

        // TEST 5: Two coins back to back
        // Expect: IDLE->ONE->TWO->IDLE, dispense fires
        #20;
        $display("--- Test 5: Two coins consecutive ---");
        coin = 1; #10;
        coin = 1; #10;
        coin = 0; #20;

        if (u_top.u_vending.current_state == 2'b00)
            $display("PASS: returned to IDLE after back-to-back coins");
        else
            $display("FAIL: unexpected state after back-to-back coins");

        // TEST 6: Check segments output
        // Insert 1 coin and verify segments reflects credit=1
        #20;
        $display("--- Test 6: Check segments display output ---");
        coin = 1; #10;
        coin = 0; #10;

        if (segments == 3'b001)
            $display("PASS: segments=001 for credit=1");
        else
            $display("FAIL: segments=%b, expected 001", segments);

        // Return to IDLE
        coin = 1; #10;
        coin = 0; #20;

        $display("--- Simulation complete ---");
        $finish;
    end

endmodule