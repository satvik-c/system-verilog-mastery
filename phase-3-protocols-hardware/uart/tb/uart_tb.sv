`timescale 1ns / 1ps

import project_pkg::*;

module uart_tb();

    parameter CLK_HZ = 100_000_000;
    parameter BAUD_RATE = 115_200;
    parameter DATA_BITS = 8;
    parameter PARITY_BITS = 1;
    parameter PARITY_MODE = EVEN;
    parameter STOP_BITS = 1;

    logic clk, rst;
    logic tx_start, tx_busy;
    logic [DATA_BITS-1:0] tx_data;
    logic rx_in, rx_valid, rx_error;
    logic [DATA_BITS-1:0] rx_data;

    typedef struct packed {
        logic [DATA_BITS-1:0] data;
        logic expected_error;
    } uart_transaction_t;

    logic dirty_send_flag;

    uart_transaction_t expected_queue [$];
    int check_count, error_count = 0;

    uart_tx #(.PARITY_BITS(PARITY_BITS), .PARITY_MODE(PARITY_MODE)) dut_tx (.*, .tx_out(rx_in));
    uart_rx #(.PARITY_BITS(PARITY_BITS), .PARITY_MODE(PARITY_MODE)) dut_rx(.*);

    bind uart_tx uart_tx_sva tx_assertion (.*);
    bind uart_rx uart_rx_sva rx_assertion (.*);

    UartCoverageTracker cov_tracker;

    initial clk = 0;
    always #5 clk = ~clk;

    task automatic reset();
        rst = 1;

        tx_start = 0; tx_data = '0; dirty_send_flag = 0;

        repeat (5) @(posedge clk);
        #1 rst = 0;
        repeat (5) @(posedge clk);
    endtask

    task automatic clean_send(logic [DATA_BITS-1:0] data);
        automatic uart_transaction_t txn;
        txn.data = data;
        txn.expected_error = 0;
        expected_queue.push_back(txn);

        wait(!tx_busy);
        @(posedge clk) #1 tx_data = data;
        @(posedge clk) #1 tx_start = 1;
        @(posedge clk) #1 tx_start = 0;
        wait(tx_busy);
        wait(!tx_busy);
        wait(expected_queue.size() == 0);
    endtask

    task automatic dirty_send(logic [DATA_BITS-1:0] data, int baud_offset, logic corrupt_parity, logic corrupt_stop);
        longint num = 64'(CLK_HZ) * 100;
        int den = BAUD_RATE * (100 + baud_offset);
        int CLKS_PER_BIT = (num + (den / 2)) / den;

        automatic uart_transaction_t txn;
        cov_tracker.sample(data, baud_offset, corrupt_parity, corrupt_stop);

        dirty_send_flag = 1;
        txn.data = data;
        txn.expected_error = (corrupt_parity | corrupt_stop);
        expected_queue.push_back(txn);

        @(posedge clk) force rx_in = 0;
        repeat (CLKS_PER_BIT) @(posedge clk);
        for (int i = 0; i < DATA_BITS; i++) begin
            if (data[i] == 1) force rx_in = 1;
            else force rx_in = 0;
            repeat (CLKS_PER_BIT) @(posedge clk);
        end
        if (PARITY_BITS == 1) begin
            logic parity;
            if (PARITY_MODE == EVEN) parity = ^data;
            else parity = ~^data;
            if (corrupt_parity) parity = ~parity;
            if (parity == 1) force rx_in = 1;
            else force rx_in = 0;
            repeat (CLKS_PER_BIT) @(posedge clk);
        end
        if (corrupt_stop) force rx_in = 0;
        else force rx_in = 1;
        repeat (CLKS_PER_BIT) @(posedge clk); // DONE

        force rx_in = 1;
        repeat (CLKS_PER_BIT * 2) @(posedge clk); // PADDING
        release rx_in;
        dirty_send_flag = 0;
    endtask

    task automatic false_start();
        @(posedge clk) force rx_in = 0;
        repeat (5) @(posedge clk);
        force rx_in = 1;
        repeat (5) @(posedge clk);
        release rx_in;
    endtask

    always @(posedge clk) begin
        automatic uart_transaction_t expected;
        if (rx_valid || rx_error) begin
            if (expected_queue.size() == 0) begin
                $fatal(1, "FATAL: Faulty receiver output. Queue is empty. data is 0x%h", rx_data);
            end
            expected = expected_queue.pop_front();
            check_count++;
            if (expected.expected_error) begin
                if (rx_error & !rx_valid) begin
                    $display("PASS [protocol]: Receiver correctly flagged the injected error.");
                end
                else begin
                    $display("FAIL [protocol]: Injected an error but received missed it.");
                    error_count++;
                end
            end
            else begin
                if (rx_error) begin
                    $display("FAIL [data]: Receiver flagged an unexpected error.");
                    error_count++;
                end
                else if (rx_data === expected.data) begin
                    $display("PASS [data]: Successfully received 0x%h!", rx_data);
                end
                else begin
                    $display("FAIL [data]: Got 0x%h, expected 0x%h.", rx_data, expected.data);
                    error_count++;
                end
            end
        end
    end

    initial begin
        static int baud_offsets[3] = '{-4, 0, 4};
        reset();

        cov_tracker = new();

        false_start();

        for (int i = 0; i < 256; i++) begin
            clean_send(8'(i));
        end

        repeat (30000) begin
            dirty_send(
                8'($urandom_range(0, 255)),
                baud_offsets[$urandom_range(0, 2)],
                $urandom_range(0, 1),
                $urandom_range(0, 1)
            );
        end

        wait(expected_queue.size() == 0);
        #100 $finish;
    end

    final begin
        $display("================= TESTING COMPLETE =================");
        if (error_count == 0) $display("ALL %0d TESTS PASSED!", check_count);
        else $display("%0d/%0d TESTS FAILED.", error_count, check_count);
        cov_tracker.print_report();
    end

endmodule
