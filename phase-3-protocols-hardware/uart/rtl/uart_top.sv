module uart_top
    import project_pkg::*;
#(
    parameter CLK_HZ = 100_000_000,
    parameter BAUD_RATE = 115_200,
    parameter DATA_BITS = 8,
    parameter PARITY_BITS = 1,
    parameter PARITY_MODE = EVEN,
    parameter STOP_BITS = 1
)(
    input logic clk, rst,
    input logic rx_in,
    output logic tx_out,
    output logic [DATA_BITS-1:0] led
);

    logic [DATA_BITS-1:0] rx_data; logic rx_valid, rx_error;
    logic tx_start; logic tx_busy;

    logic [DATA_BITS-1:0] to_upper_character;
    assign to_upper_character = (rx_data >= 8'h61 && rx_data <= 8'h7A) ? (rx_data - 8'd32) : rx_data;

    uart_tx #(
        .CLK_HZ(CLK_HZ),
        .BAUD_RATE(BAUD_RATE),
        .DATA_BITS(DATA_BITS),
        .PARITY_BITS(PARITY_BITS),
        .PARITY_MODE(PARITY_MODE),
        .STOP_BITS(STOP_BITS)
    ) tx_mod (
        .tx_data(to_upper_character),
        .*
    );

    uart_rx #(
        .CLK_HZ(CLK_HZ),
        .BAUD_RATE(BAUD_RATE),
        .DATA_BITS(DATA_BITS),
        .PARITY_BITS(PARITY_BITS),
        .PARITY_MODE(PARITY_MODE),
        .STOP_BITS(STOP_BITS)
    ) rx_mod (
        .*
    );

    always_ff @(posedge clk) begin
        if (rst) begin
            tx_start <= 0;
        end
        else begin
            tx_start <= 0;
            if (rx_valid) tx_start <= 1;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) led <= '0;
        else if (rx_valid) led <= rx_data;
    end

endmodule
