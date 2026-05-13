`timescale 1ns / 1ps

module multi_channel_tb();

    parameter NUM_CHANNELS = 4;
    logic clk, rst;
    logic [NUM_CHANNELS-1:0] enable;
    logic [NUM_CHANNELS-1:0][15:0] period;
    logic [NUM_CHANNELS-1:0] pulse;

    multi_channel #(.NUM_CHANNELS(NUM_CHANNELS)) dut (
        .*
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("multi_channel_tb_sim.fst");
        $dumpvars(0, multi_channel_tb);

        rst = 1;
        for (int i = 0; i < NUM_CHANNELS; i = i + 1) begin
            enable[i] = 1;
            period[i] = 16'(10*(i+1));
        end
        @(posedge clk) #1 rst = 0;

        repeat (200) @(posedge clk);

        #100 $finish;
    end

endmodule
