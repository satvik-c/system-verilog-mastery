`timescale 1ns / 1ps

import project_pkg::*;

module traffic_light_tb();

    parameter COUNT_MAX = 8;

    logic clk, rst; mode_t mode;
    light_t ns_light, ew_light;

    fsm_state_t last_state;

    traffic_light #(.COUNT_MAX(COUNT_MAX)) dut (
        .*
    );

    bind traffic_light traffic_light_sva #(.COUNT_MAX(COUNT_MAX)) u_traffic_light_sva(.*);
    bind traffic_light traffic_light_coverage u_traffic_light_cov(.*);

    initial clk = 0;
    always #5 clk = ~clk;

    task automatic drive_normal();
        @(posedge clk);
        #1 mode = NORMAL;
        repeat (5*COUNT_MAX) @(posedge clk);
    endtask

    task automatic drive_flash();
        @(posedge clk);
        #1 mode = FLASH;
        repeat (5*COUNT_MAX) @(posedge clk);
    endtask

    task automatic drive_ped();
        @(posedge clk);
        #1 mode = PED;
        repeat (5*COUNT_MAX) @(posedge clk);
    endtask

    initial begin
        $dumpfile("traffic_light_tb_sim.fst");
        $dumpvars(0, traffic_light_tb);

        rst = 1;
        mode = NORMAL;
        last_state = GO_NS;
        repeat (5) @(posedge clk);
        rst = 0;

        drive_flash();
        drive_ped();
        drive_normal();

        #100 $finish;
    end

    always_ff @(posedge clk) begin
        if (last_state != dut.CS) $display("[%0t] State: %s", $time, dut.CS.name());
        last_state <= dut.CS;
    end


endmodule
