module uart_rx_sva
    import project_pkg::*;
#(
    parameter DATA_BITS = 8,
    parameter PARITY_BITS = 1,
    parameter PARITY_MODE = EVEN,
    parameter STOP_BITS = 1
)(
    input logic clk, rst, rx_in,
    input logic [DATA_BITS-1:0] rx_data,
    input logic rx_valid,
    input logic rx_error
);

    assert property (@(posedge clk) disable iff(rst)
       !(rx_valid && rx_error) === 1
    )
    else begin
       $error("Both rx_valid and rx_error pulsed");
    end

    assert property (@(posedge clk) disable iff(rst)
       (rx_valid) |=> (!rx_valid)
    )
    else begin
       $error("rx_valid held for more than 1 clock cycle");
    end

    assert property (@(posedge clk) disable iff(rst)
       (rx_error) |=> (!rx_error)
    )
    else begin
       $error("rx_error held for more than 1 clock cycle");
    end

    assert property (@(posedge clk) disable iff(rst)
       (rx_valid) |-> (!$isunknown(rx_data))
    )
    else begin
       $error("rx_data has X bits in it");
    end

endmodule
