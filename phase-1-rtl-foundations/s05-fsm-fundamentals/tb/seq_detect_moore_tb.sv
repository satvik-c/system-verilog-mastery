`timescale 1ns / 1ps

module seq_detect_moore_tb();

    logic clk, rst, in;
    logic detected;

    seq_detect_moore dut (
        .*
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("seq_detect_moore_tb_sim.fst");
        $dumpvars(0, seq_detect_moore_tb);

        rst = 1;
        @(negedge clk) rst = 0;

        @(negedge clk) in = 1;
        @(negedge clk) in = 1;
        @(negedge clk) in = 0;
        @(negedge clk) in = 1;
////////////////////////////////////////////////
        @(negedge clk) in = 0;
        #20;
////////////////////////////////////////////////
        @(negedge clk) in = 1;
        @(negedge clk) in = 1;
        @(negedge clk) in = 0;
        @(negedge clk) in = 1;
        @(negedge clk) in = 1;
        @(negedge clk) in = 0;
        @(negedge clk) in = 1;
////////////////////////////////////////////////
        @(negedge clk) in = 0;
        #20;
////////////////////////////////////////////////
        @(negedge clk) in = 1;
        @(negedge clk) in = 1;
        @(negedge clk) in = 0;
        @(negedge clk) in = 0;
        @(negedge clk) in = 1;
////////////////////////////////////////////////
        @(negedge clk) in = 0;
        #20;
////////////////////////////////////////////////
        @(negedge clk) in = 1;
        @(negedge clk) in = 1;
        @(negedge clk) in = 1;
        @(negedge clk) in = 0;
        @(negedge clk) in = 1;
////////////////////////////////////////////////
        @(negedge clk) in = 0;
        #20;
////////////////////////////////////////////////        

        #100 $finish;
    end

    always @(posedge clk) begin
        $display("t=%0t, in=%b, out=%b", $time, in, detected);
    end

endmodule
