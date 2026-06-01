`timescale 1ns / 1ps

module uart_tx_tb();

    parameter CLK_HZ = 100_000_000;
    parameter BAUD_RATE = 115_200;
    parameter DATA_BITS = 8;
    parameter PARITY_BITS = 1;
    parameter STOP_BITS = 1;
    localparam CLKS_PER_BIT = CLK_HZ / BAUD_RATE;

    logic clk, rst, tx_start; logic [DATA_BITS-1:0] tx_data;
    logic tx_busy, tx_out;

    uart_tx #(.PARITY_BITS(PARITY_BITS)) dut (
        .*
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task automatic decode_data(output logic [DATA_BITS-1:0] expected_data, output logic false_start, output logic framing_error);
        false_start = 0;
        framing_error = 0;

        wait(!tx_out);
        repeat (CLKS_PER_BIT/2) @(posedge clk);
        if (tx_out !== 0) false_start = 1;

        for (int i = 0; i < DATA_BITS; i++) begin
            repeat (CLKS_PER_BIT) @(posedge clk);
            expected_data[i] = tx_out;
        end

        if (PARITY_BITS > 0) begin
            repeat (CLKS_PER_BIT * PARITY_BITS) @(posedge clk);
        end

        repeat (CLKS_PER_BIT) @(posedge clk);
        if (tx_out !== 1) framing_error = 1;
    endtask

    task automatic send_data(logic[DATA_BITS-1:0] data);
        wait(!tx_busy);
        @(posedge clk);
        #1 tx_data = data;
        @(posedge clk);
        #1 tx_start = 1;
        @(posedge clk);
        #1 tx_start = 0;
    endtask

    initial begin
        logic [DATA_BITS-1:0] expected_data;
        logic false_start;
        logic framing_error;

        rst = 1;
        tx_start = 0;
        repeat (5) @(posedge clk);
        #1 rst = 0;
        repeat (5) @(posedge clk);

        repeat (5) begin
            fork
                send_data(DATA_BITS'($urandom_range(0, 255)));
                decode_data(expected_data, false_start, framing_error);
            join

            if (expected_data === tx_data && !false_start && !framing_error) begin
                $display("SUCCESS!");
            end else $display("FAILED");
        end

        $finish;
    end

endmodule
