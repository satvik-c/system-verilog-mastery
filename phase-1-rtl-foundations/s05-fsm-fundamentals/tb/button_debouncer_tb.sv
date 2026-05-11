`timescale 1ns / 1ps

module button_debouncer_tb();

    parameter CLK_HZ = 1000, DEBOUNCE_MS = 10;
    logic clk, rst, btn_raw;
    logic btn_clean;

    button_debouncer #(.CLK_HZ(CLK_HZ), .DEBOUNCE_MS(DEBOUNCE_MS)) dut (
        .*
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("button_debouncer_tb_sim.fst");
        $dumpvars(0, button_debouncer_tb);

        rst = 1;
        @(negedge clk) rst = 0;

        repeat (100) begin
            @(negedge clk) btn_raw = 0;
            @(negedge clk) btn_raw = 1;
        end

        btn_raw = 1;
        repeat (200) @(negedge clk);
        
        repeat (100) begin
            @(negedge clk) btn_raw = 0;
            @(negedge clk) btn_raw = 1;
        end

        btn_raw = 0;
        repeat (200) @(negedge clk);

        #100 $finish;
    end

endmodule
