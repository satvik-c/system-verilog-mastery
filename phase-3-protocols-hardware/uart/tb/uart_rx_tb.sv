`timescale 1ns / 1ps

import project_pkg::*;

module uart_rx_tb();

    parameter CLK_HZ = 100_000_000;
    parameter BAUD_RATE = 115_200;
    parameter DATA_BITS = 8;
    parameter PARITY_BITS = 1;
    parameter PARITY_MODE = EVEN;
    parameter STOP_BITS = 1;
    localparam CLKS_PER_BIT = CLK_HZ / BAUD_RATE;

    logic clk, rst, rx_in;
    logic [DATA_BITS-1:0] rx_data; logic rx_valid, rx_framing_error, rx_parity_error;

    uart_rx #(.PARITY_BITS(PARITY_BITS)) dut (
        .*
    );

    task automatic send_data(logic [DATA_BITS-1:0] data);
        @(posedge clk);
        #1 rx_in = 0;
        repeat (CLKS_PER_BIT) @(posedge clk);
        for (int i = 0; i < DATA_BITS; i++) begin
            #1 rx_in = data[i];
            repeat (CLKS_PER_BIT) @(posedge clk);
        end
        if (PARITY_BITS == 1) begin
            if (PARITY_MODE == EVEN) #1 rx_in = ^data;
            else #1 rx_in = ~^data;
            repeat (CLKS_PER_BIT) @(posedge clk);
        end
        #1 rx_in = 1;
        repeat (CLKS_PER_BIT * STOP_BITS) @(posedge clk);

        if (rx_data === data && rx_valid && !rx_framing_error && !rx_parity_error) begin
            $display("SUCCESS: received 0x%h", rx_data);
        end
        else $display("FAILED: got 0x%h, expected 0x%h", rx_data, data);
    endtask

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("uart_rx_tb_sim.fst");
        $dumpvars(0, uart_rx_tb);

        rst = 1;
        rx_in = 1;
        repeat (5) @(posedge clk);
        #1 rst = 0;
        repeat (5) @(posedge clk);

        for (int i = 0; i < 256; i++) begin
            send_data(8'(i));
            repeat ($urandom_range(0, 10)) @(posedge clk);
        end

        #100 $finish;
    end

endmodule
