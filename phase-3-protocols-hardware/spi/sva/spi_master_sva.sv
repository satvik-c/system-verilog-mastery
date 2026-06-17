module spi_master_sva
    import project_pkg::*;
#(
    parameter SYS_CLK_HZ = 100_000_000,
    parameter SPI_CLK_HZ = 1_000_000,
    parameter DATA_WIDTH = 8,
    parameter CPOL = 0,
    parameter CPHA = 0,
    parameter CS_SETUP_CYCLES = 0,
    parameter CS_HOLD_CYCLES = 0
)(
    input logic clk, rst,
    input logic miso, start,
    input logic [7:0] num_bytes,
    input logic [DATA_WIDTH-1:0] tx_data,
    input logic sclk, mosi, cs,
    input logic [DATA_WIDTH-1:0] rx_data,
    input logic rx_valid, busy, tx_ready
);

    assert property (@(posedge clk) disable iff(rst)
       ($changed(sclk)) |-> (cs == 0)
    )
    else begin
       $error("cs is high when sclk is changing");
    end

    assert property (@(posedge clk) disable iff(rst)
       (cs) |-> (sclk == 0)
    )
    else begin
       $error("sclk isn't 0 when cs is high");
    end

    assert property (@(posedge clk) disable iff(rst)
       $rose(sclk) |-> !$changed(mosi)
    )
    else begin
       $error("Mosi changing on sclk sample edge");
    end

    assert property (@(posedge clk) disable iff(rst)
       $rose(rx_valid) |=> $fell(rx_valid)
    )
    else begin
       $error("rx_valid is high for multiple cycles");
    end

endmodule
