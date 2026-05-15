`timescale 1ns / 1ps

module counter_tb();

    parameter MAX_COUNT = 256;
    localparam WIDTH = $clog2(MAX_COUNT);

    logic clk, rst, enable;
    logic [WIDTH-1:0] count; logic tick;

    param_counter dut (
        .*
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task automatic drive_enable_burst(input int cycles);
        @(posedge clk);
        #1 enable = 1;
        repeat (cycles) @(posedge clk);
        #1 enable = 0;
    endtask

    function automatic int predicted_count(int start_val, int cycles, int max_val);
        return (start_val + cycles) % max_val;
    endfunction

    task automatic run_and_compare(input int cycles);
        int expected_val;
        expected_val = predicted_count(32'(count), cycles, 32'(MAX_COUNT));
        drive_enable_burst(cycles);
        #1 $display("Expected: %0d, Actual: %0d", expected_val, 32'(count));
    endtask

    initial begin
        $dumpfile("counter_tb_sim.fst");
        $dumpvars(0, counter_tb);

        rst = 1;
        enable = 0;
        repeat (5) @(posedge clk);
        #1 rst = 0;

        run_and_compare(10);
        run_and_compare(250);
        run_and_compare(35);
        run_and_compare(60);
        run_and_compare(500);
        run_and_compare(1);

        #100 $finish;
    end

endmodule
