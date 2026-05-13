`timescale 1ns / 1ps

module bus_if_tb();

    logic clk, rst, start_write, start_read;
    logic [15:0] req_addr; logic [31:0] req_wdata;

    bus_if bus();

    bus_master m (
        .*
    );

    bus_slave s (
        .*
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("bus_if_tb_sim.fst");
        $dumpvars(0, bus_if_tb);

        rst = 1;
        start_read = 0;
        start_write = 0;
        req_addr = 0;
        req_wdata = 0;
        @(posedge clk) #1 rst = 0;


        for (int i = 0; i < 8; i = i + 1) begin
            req_addr = 16'(i);
            req_wdata = i * 10;
            @(posedge clk) #1 start_write = 1;
            @(posedge clk) #1 start_write = 0;
            repeat (5) @(posedge clk);
        end

        for (int i = 0; i < 8; i = i + 1) begin
            req_addr = 16'(i);
            @(posedge clk) #1 start_read = 1;
            @(posedge clk) #1 start_read = 0;
            repeat (5) @(posedge clk);
        end

        #100 $finish;
    end

endmodule
