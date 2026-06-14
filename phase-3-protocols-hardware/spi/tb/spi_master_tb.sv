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

    spi_master #(
        .SYS_CLK_HZ(SYS_CLK_HZ),
        .SPI_CLK_HZ(SPI_CLK_HZ),
        .DATA_WIDTH(DATA_WIDTH),
        .CPOL(CPOL),
        .CPHA(CPHA),
        .CS_SETUP_CYCLES(CS_SETUP_CYCLES),
        .CS_HOLD_CYCLES(CS_HOLD_CYCLES)
    ) master (.*);

    adxl362_model slave (.*);

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

    task automatic transact(logic [DATA_WIDTH-1:0] cmd, logic [DATA_WIDTH-1:0] addr, logic [DATA_WIDTH-1:0] data, logic [7:0] bytes);
        num_bytes = bytes;
        tx_data = cmd;
        @(posedge clk);
        #1 start = 1;
        @(posedge clk);
        #1 start = 0;
        @(posedge clk iff tx_ready);
        tx_data = addr;
        @(posedge clk iff tx_ready);
        if (cmd == 8'h0A) tx_data = data;
        else tx_data = 8'h00;
       @(posedge clk iff cs);
    endtask

    initial begin
        reset();
        transact(8'h0B, 8'h00, 8'h00, 3);
        transact(8'h0B, 8'h01, 8'h00, 3);
        transact(8'h0B, 8'h02, 8'h00, 3);
        transact(8'h0B, 8'h03, 8'h00, 3);
        transact(8'h0B, 8'h00, 8'h00, 5);

        transact(8'h0A, 8'h04, 8'h55, 3);
        transact(8'h0B, 8'h04, 8'h00, 3);

        #100 $finish;
    end

endmodule
