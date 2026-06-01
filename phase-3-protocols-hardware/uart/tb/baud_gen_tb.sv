`timescale 1ns / 1ps

module baud_gen_tb();

    parameter CLK_HZ = 100_000_000;
    parameter BAUD_RATE = 115_200;
    localparam CLKS_PER_BIT = CLK_HZ / BAUD_RATE;

    logic clk, rst, enable;
    logic baud_tick;

    baud_gen dut (
        .*
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        int expected_ticks;

        rst = 1;
        enable = 0;
        repeat (5) @(posedge clk);
        #1 rst = 0;

        repeat (5) @(posedge clk);
        #1 enable = 1;

        repeat (10) begin
            expected_ticks = 0;

            do begin
                @(posedge clk);
                expected_ticks++;
            end
            while (baud_tick === 0);

            if (expected_ticks != CLKS_PER_BIT) $display("FAILED");
            else $display("SUCCESS");
        end

        $finish;
    end

endmodule
