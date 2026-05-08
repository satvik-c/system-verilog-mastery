`default_nettype none

module counter_array #(
    parameter N = 4,
    parameter MAX_COUNT = 8,
    localparam WIDTH = $clog2(MAX_COUNT)
)(
    input logic clk, rst, input logic [N-1:0] enable,
    output logic [N*WIDTH-1:0] count, output logic [N-1:0] tick
);

    logic [N-1:0][WIDTH-1:0] temp;

    generate
        for (genvar i = 0; i < N; i = i + 1) begin : g_count
            param_counter #(.MAX_COUNT(MAX_COUNT)) u_count(
                .clk(clk),
                .rst(rst),
                .enable(enable[i]),
                .tick(tick[i]),
                .count(temp[i])
            );
        end
    endgenerate

    assign count = temp;

endmodule
