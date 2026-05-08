`timescale 1ns / 1ps

module param_counter_tb();

    logic clk, rst, enable;

    logic [$clog2(10)-1:0] count_10; logic tick_10;
    logic [$clog2(100)-1:0] count_100; logic tick_100;

    // Device Under Test
    param_counter #(.MAX_COUNT(10)) dut_10 (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .count(count_10),
        .tick(tick_10)
    );

    param_counter #(.MAX_COUNT(100)) dut_100 (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .count(count_100),
        .tick(tick_100)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("param_counter_tb_sim.fst");
        $dumpvars(0, param_counter_tb);

        rst = 1;
        repeat(4) @(posedge clk);
        rst = 0;

        repeat (400) begin
            @(posedge clk) enable = 1;
            @(posedge clk) enable = 0;
            repeat (10) @(posedge clk);
        end

        #100 $finish;
    end

    always @(posedge clk) begin
        if (tick_10) $display("Tick_10 wrapped! count: %d, tick: %d", count_10, tick_10);
        if (tick_100) $display("Tick_100 wrapped! count: %d, tick: %d", count_100, tick_100);
    end

endmodule
