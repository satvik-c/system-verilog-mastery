`default_nettype none

module param_counter #(
    parameter MAX_COUNT = 256,
    localparam WIDTH = $clog2(MAX_COUNT)
)(
    input logic clk, rst, enable,
    output logic [WIDTH-1:0] count, output logic tick
);

    always_ff @(posedge clk) begin
        tick <= 0;
        if (rst) count <= '0;
        else if (enable) begin
            if (count == MAX_COUNT - 1) begin
                count <= '0;
                tick <= 1;
            end
            else count <= count + 1;
        end
    end

endmodule
