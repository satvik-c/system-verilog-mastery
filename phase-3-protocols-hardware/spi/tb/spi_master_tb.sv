`timescale 1ns / 1ps

module spi_master_tb();

    parameter SYS_CLK_HZ = 100_000_000;
    parameter SPI_CLK_HZ = 1_000_000;
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
    ) dut (.*);

    initial clk = 0;
    always #5 clk = ~clk;

    task automatic reset();
        rst = 1;
        start = 0;
        num_bytes = 2;
        tx_data = 8'h55;
        repeat (5) @(posedge clk);
        #1 rst = 0;
        repeat (5) @(posedge clk);
    endtask

    task automatic send(logic [DATA_WIDTH-1:0] data, logic [7:0] bytes);
        tx_data = data;
        num_bytes = bytes;
        @(posedge clk);
        #1 start = 1;
        @(posedge clk);
        #1 start = 0;
    endtask

    logic [DATA_WIDTH-1:0] slave;
    always @(negedge sclk or negedge cs or rst) begin
        if (rst) slave <= 8'hAA;
        else if (!cs) begin
            miso <= slave[DATA_WIDTH-1];
            slave <= {slave[DATA_WIDTH-2:0], slave[DATA_WIDTH-1]};
        end
    end

    initial begin

        reset();
        send(8'h55, 3);

        #30000 $finish;
    end

endmodule
