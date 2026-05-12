`timescale 1ns / 1ps

import project_pkg::*;

module traffic_light_tb();

    parameter COUNT_MAX = 8;
    logic clk, rst; mode_t mode;
    light_t ns_light, ew_light;

    traffic_light #(.COUNT_MAX(COUNT_MAX)) dut (
        .*
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("traffic_light_tb_sim.fst");
        $dumpvars(0, traffic_light_tb);

        rst = 1;
        mode = NORMAL;
        @(negedge clk) rst = 0;

        #300 mode = FLASH;

        #300 mode = PED;

        #300 mode = NORMAL;

        #300 $finish;
    end

endmodule
