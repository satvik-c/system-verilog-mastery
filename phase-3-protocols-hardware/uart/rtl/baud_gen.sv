`default_nettype none

module baud_gen
    // Imports;
#(
    parameter CLK_HZ = 100_000_000,
    parameter BAUD_RATE = 115_200,
    localparam CLKS_PER_BIT = CLK_HZ / BAUD_RATE,
    localparam BAUD_CNT_W = $clog2(CLKS_PER_BIT)
)(
    input logic clk, rst, enable,
    output logic baud_tick
);

    logic [BAUD_CNT_W-1:0] baud_counter;

    assign baud_tick = (baud_counter == CLKS_PER_BIT - 1);

    always_ff @(posedge clk) begin
        if (rst || baud_counter == CLKS_PER_BIT - 1 || !enable) baud_counter <= '0;
        else baud_counter <= baud_counter + 1;
    end

endmodule
