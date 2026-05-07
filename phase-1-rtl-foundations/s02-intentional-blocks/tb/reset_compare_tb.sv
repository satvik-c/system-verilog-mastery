`timescale 1ns / 1ps

module reset_compare_tb();

    logic clk, rst; logic [7:0] d;
    logic [7:0] q_sync, q_async;

    // Device Under Test
    reset_compare dut (
        .*
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("reset_compare_tb_sim.vcd");
        $dumpvars(0, reset_compare_tb);

        // Power-on reset
        rst = 1;
        d = 8'h00;
        repeat (5) @(posedge clk);
        @(posedge clk);
        rst = 0;
        $display("q_sync: %b, q_async: %b", q_sync, q_async);

        // Normal operation
        @(negedge clk) d = 8'hAA;
        @(posedge clk); #1 $display("d: %h -> q_sync: %h, q_async: %h", d, q_sync, q_async);
        @(negedge clk) d = 8'h55;
        @(posedge clk); #1 $display("d: %h -> q_sync: %h, q_async: %h", d, q_sync, q_async);
        @(negedge clk) d = 8'hFF;
        @(posedge clk); #1 $display("d: %h -> q_sync: %h, q_async: %h", d, q_sync, q_async);
        @(negedge clk) d = 8'h00;
        @(posedge clk); #1 $display("d: %h -> q_sync: %h, q_async: %h", d, q_sync, q_async);

        // Async reset
        @(negedge clk) d = 8'hFF;
        @(posedge clk) #3;

        rst = 1; #1 $display("d: %h -> q_sync: %h, q_async: %h", d, q_sync, q_async);
        @(posedge clk) #1;
        $display("d: %h -> q_sync: %h, q_async: %h", d, q_sync, q_async);

        // Resume
        repeat (2) @(negedge clk);
        rst = 0;

        #100 $finish;
    end

endmodule
