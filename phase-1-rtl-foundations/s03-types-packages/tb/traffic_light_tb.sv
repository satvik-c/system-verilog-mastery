`timescale 1ns / 1ps

module traffic_light_tb();

    logic clk, rst, tick;
    project_pkg::light_outputs_t lights;
    project_pkg::light_state_t state;

    // Device Under Test
    traffic_light dut (
        .*
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("traffic_light_tb_sim.fst");
        $dumpvars(0, traffic_light_tb);

        rst = 1;
        repeat (5) @(posedge clk);
        rst = 0;

        repeat (8) begin
            @(posedge clk) tick = 1;
            @(posedge clk) tick = 0;
            #1 $display("State: %s, Outputs: %b", state.name, lights);
            #200;
        end

        #100 $finish;
    end

endmodule
