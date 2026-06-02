`timescale 1ns / 1ps

import project_pkg::*;

module uart_top_tb();

    parameter CLK_HZ = 100_000_000;
    parameter BAUD_RATE = 115_200;
    parameter DATA_BITS = 8;
    parameter PARITY_BITS = 1;
    parameter PARITY_MODE = EVEN;
    parameter STOP_BITS = 1;
    localparam CLKS_PER_BIT = CLK_HZ / BAUD_RATE;

    logic clk, rst;
    logic rx_in, tx_out;
    logic [DATA_BITS-1:0] led;

    uart_top dut (
        .*
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task automatic reset();
        rst = 1;
        rx_in = 1;
        repeat (5) @(posedge clk);
        #1 rst = 0;
        repeat (5) @(posedge clk);
    endtask //automatic

    task automatic send_data(logic [DATA_BITS-1:0] data);
        @(posedge clk);
        rx_in = 0;
        repeat (CLKS_PER_BIT) @(posedge clk);
        for (int i = 0; i < DATA_BITS; i++) begin
            rx_in = data[i];
            repeat (CLKS_PER_BIT) @(posedge clk);
        end
        if (PARITY_BITS == 1) begin
            if (PARITY_MODE == EVEN) rx_in = ^data;
            else rx_in = ~^data;
            repeat (CLKS_PER_BIT) @(posedge clk);
        end
        rx_in = 1;
        repeat (CLKS_PER_BIT * STOP_BITS) @(posedge clk);
    endtask

    initial begin
        reset();

        send_data(8'h55);
        #100000 send_data(8'hAA);
        #100000 send_data(8'h88);

        #100000 $finish;
    end

endmodule
