`timescale 1ns / 1ps

module spi_master_tb();

    parameter SYS_CLK_HZ = 100_000_000;
    parameter SPI_CLK_HZ = 20_000_000;
    parameter DATA_WIDTH = 8;
    parameter CPOL = 0;
    parameter CPHA = 0;
    parameter CS_SETUP_CYCLES = 10;
    parameter CS_HOLD_CYCLES = 10;

    logic clk, rst;
    logic miso, start;
    logic [7:0] num_bytes;
    logic [DATA_WIDTH-1:0] tx_data;
    logic sclk, mosi, cs;
    logic [DATA_WIDTH-1:0] rx_data;
    logic rx_valid, busy, tx_ready;

    int check_count, error_count;

    spi_master #(
        .SYS_CLK_HZ(SYS_CLK_HZ),
        .SPI_CLK_HZ(SPI_CLK_HZ),
        .DATA_WIDTH(DATA_WIDTH),
        .CPOL(CPOL),
        .CPHA(CPHA),
        .CS_SETUP_CYCLES(CS_SETUP_CYCLES),
        .CS_HOLD_CYCLES(CS_HOLD_CYCLES)
    ) master (.*);

    adxl362_model bfm (.*);

    bind spi_master spi_master_sva sva (.*);

    SpiCoverageTracker cov_tracker;

    initial clk = 0;
    always #5 clk = ~clk;

    task automatic reset();
        rst = 1;
        start = 0;
        num_bytes = 3;
        tx_data = 8'h0B;
        repeat (5) @(posedge clk);
        #1 rst = 0;
        repeat (5) @(posedge clk);
    endtask

    task automatic read(logic [7:0] addr, int bytes_to_read);
        num_bytes = bytes_to_read + 2;
        tx_data = 8'h0B;
        @(posedge clk) #1 start = 1;
        @(posedge clk) #1 start = 0;
        @(posedge clk iff tx_ready) #1 tx_data = addr;
        repeat (bytes_to_read) @(posedge clk iff tx_ready) #1 tx_data = 8'h00;
        @(posedge clk iff cs);
    endtask

    task automatic check_read(logic [7:0] addr, int bytes_to_read);
        repeat (2) @(posedge clk iff rx_valid);
        for (int i = 0; i < bytes_to_read; i++) begin
            @(posedge clk iff rx_valid) begin
                check_count++;
                if (rx_data !== bfm.mem[addr + i]) begin
                    error_count++;
                    $error("Read 0x%0h, expected 0x%0h", rx_data, bfm.mem[addr + i]);
                end
            end
        end
    endtask

    task automatic read_and_check(logic [7:0] addr, int bytes_to_read);
        cov_tracker.sample(8'h0B, addr, bytes_to_read, 8'h00);
        fork
            read(addr, bytes_to_read);
            check_read(addr, bytes_to_read);
        join
    endtask

    task automatic write(logic [7:0] addr, logic [7:0] data, int bytes_to_write);
        num_bytes = bytes_to_write + 2;
        tx_data = 8'h0A;
        @(posedge clk) #1 start = 1;
        @(posedge clk) #1 start = 0;
        @(posedge clk iff tx_ready) #1 tx_data = addr;
        repeat (bytes_to_write) @(posedge clk iff tx_ready) #1 tx_data = data;
        @(posedge clk iff cs);
    endtask

    task automatic check_write(logic [7:0] addr, logic [7:0] data, int bytes_to_write);
        repeat (2) @(posedge clk iff rx_valid);
        for (int i = 0; i < bytes_to_write; i++) begin
            @(posedge clk iff rx_valid) begin
                check_count++;
                if (data !== bfm.mem[addr + i]) begin
                    error_count++;
                    $error("Wrote 0x%0h, expected 0x%0h", data, bfm.mem[addr + i]);
                end
            end
        end
    endtask

    task automatic write_and_check(logic [7:0] addr, logic [7:0] data, int bytes_to_write);
        cov_tracker.sample(8'h0A, addr, bytes_to_write, data);
        fork
            write(addr, data, bytes_to_write);
            check_write(addr, data, bytes_to_write);
        join
    endtask

    initial begin
        logic [7:0] addr;
        logic [7:0] data;
        int bytes_to_run;
        static logic [7:0] corner_data [4] = '{8'h00, 8'hFF, 8'h55, 8'hAA};
        
        reset();

        cov_tracker = new();
        
        repeat (200000) begin
            addr = $urandom_range(0, 8'h1F);
            
            if ($urandom_range(0, 100) < 80) bytes_to_run = $urandom_range(1, 6);
            else bytes_to_run = $urandom_range(7, 16);
            
            if (bytes_to_run > (8'h1F - addr + 1)) begin
                bytes_to_run = 8'h1F - addr + 1;
            end
            
            if ($urandom_range(0, 100) < 80) data = corner_data[$urandom_range(0, 3)];
            else data = $urandom_range(0, 8'hFF);

            if ($urandom_range(0, 1)) begin
                write_and_check(addr, data, bytes_to_run);
            end else begin
                read_and_check(addr, bytes_to_run);
            end
        end

        #100 $finish;
    end

    final begin
        $display("========== CHECKS COMPLETE ============");
        if (error_count == 0) $display("ALL %0d CHECKS PASSED!", check_count);
        else $display("FAILED: %0d/%0d CHECKS FAILED", error_count, check_count);
        $display("========================================");
        cov_tracker.print_report();
    end

endmodule
