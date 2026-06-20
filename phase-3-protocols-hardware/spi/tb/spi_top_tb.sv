`timescale 1ns / 1ps

module spi_top_tb();

    logic clk, rst;
    logic start;
    logic miso;
    logic sclk, cs, mosi;
    logic [7:0] led;
    logic valid;

    spi_top master (
        .*
    );

    adxl362_model slave (.*);

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin

        rst = 1;
        start = 0;
        repeat (5) @(posedge clk);
        #1 rst = 0;
        repeat (5) @(posedge clk);

        start = 1;
        #1000 start = 0;

        #100000 $finish;
    end

endmodule
