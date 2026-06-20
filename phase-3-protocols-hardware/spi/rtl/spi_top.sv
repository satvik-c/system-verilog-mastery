module spi_top
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
    input logic start, 
    input logic miso,
    output logic sclk, cs, mosi, 
    output logic [DATA_WIDTH-1:0] led,
    output logic valid
);

    logic [7:0] num_bytes;
    logic [DATA_WIDTH-1:0] tx_data;
    logic [DATA_WIDTH-1:0] rx_data;
    logic rx_valid, tx_ready, busy;

    wrapper_state_t CS, NS;
    logic [1:0] tx_counter, rx_counter;
    logic start_prev, master_start;
    assign master_start = (CS == REST && !start_prev && start);

    spi_master #(
        .SYS_CLK_HZ(SYS_CLK_HZ),
        .SPI_CLK_HZ(SPI_CLK_HZ),
        .DATA_WIDTH(DATA_WIDTH),
        .CPOL(CPOL),
        .CPHA(CPHA),
        .CS_SETUP_CYCLES(CS_SETUP_CYCLES),
        .CS_HOLD_CYCLES(CS_HOLD_CYCLES)
    ) master (
        .start(master_start),
        .*
    );

    always_ff @(posedge clk) begin
        if (rst) begin
            CS <= REST;
            num_bytes <= 3;
            start_prev <= 0;
        end
        else begin
            CS <= NS;
            start_prev <= start;
        end
    end

    always_comb begin
        NS = CS;
        case (CS)
            REST: if (!start_prev && start) NS = RUN;
            RUN: if (rx_counter == 3 && rx_valid) NS = REST;
        endcase
    end

    logic rst_counter, inc_counter;
    assign valid = (led == 8'hAD);
    assign tx_data = (tx_counter == 1) ? 8'h0B : 8'h00;

    always_comb begin
        rst_counter = 0;
        inc_counter = 0;
        case (CS)
            REST: rst_counter = 1;
            RUN: if (tx_ready) inc_counter = 1;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            tx_counter <= 1;
            rx_counter <= 1;
            led <= '0;
        end
        else begin
            if (rst_counter) begin
                tx_counter <= 1;
                rx_counter <= 1;
            end
            if (CS == RUN && rx_valid) rx_counter <= rx_counter + 1;
            if (inc_counter) tx_counter <= tx_counter + 1;
            if (CS == RUN && rx_counter == 3 && rx_valid) led <= rx_data;
        end
    end

endmodule
