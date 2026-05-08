//`default_nettype none

module bram_sp #(
    parameter DEPTH = 256,
    parameter WIDTH = 8,
    localparam ADDR_W = $clog2(DEPTH)
)
(
    input logic clk,
    input logic we,
    input logic [ADDR_W-1:0] addr,
    input logic [WIDTH-1:0] wr_data,
    output logic [WIDTH-1:0] rd_data
);

    logic [WIDTH-1:0] mem [0:DEPTH-1];

    always_ff @(posedge clk) begin
        if (we) mem[addr] <= wr_data;
        rd_data <= mem[addr];
    end

endmodule
