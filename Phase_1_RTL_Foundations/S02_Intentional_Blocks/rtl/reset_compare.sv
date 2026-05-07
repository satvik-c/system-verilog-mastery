`default_nettype none

module reset_compare (
    input logic clk, rst,
    input logic [7:0] d,
    output logic [7:0] q_sync, q_async
);

    always_ff @(posedge clk) begin
        if (rst) q_sync <= '0;
        else q_sync <= d;
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) q_async <= '0;
        else q_async <= d;
    end

endmodule
