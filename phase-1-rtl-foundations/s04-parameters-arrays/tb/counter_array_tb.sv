`timescale 1ns / 1ps

module counter_array_tb();

    logic clk, rst; logic [3:0] enable;
    logic [11:0] count; logic [3:0] tick;
 
    // Device Under Test
    counter_array #(.N(4), .MAX_COUNT(8)) dut (
        .*
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("counter_array_tb_sim.fst");
        $dumpvars(0, counter_array_tb);

        rst = 1;
        repeat (2) @(posedge clk);
        rst = 0;

        repeat (100) begin
            @(posedge clk) enable = 4'b1000;
            @(posedge clk) enable = 4'b1110;
            @(posedge clk) enable = 4'b1100;
            @(posedge clk) enable = 4'b1010;
            #1 $display("Count 1: %d", count[2:0]);
        end

        #100 $finish;
    end

endmodule
