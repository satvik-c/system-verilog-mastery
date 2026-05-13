`default_nettype none

module bus_slave
    // Imports;
#(
    localparam NUM_REG = 8,
    localparam ADDR_WIDTH = $clog2(NUM_REG)
)(
    input logic clk,
    bus_if.slave bus
);

    logic [31:0] regs [NUM_REG];

    assign bus.ready = 1;
    assign bus.rdata = (bus.read_en) ? regs[ADDR_WIDTH'(bus.addr)] : 0;

    always_ff @(posedge clk) begin
        if (bus.write_en) regs[ADDR_WIDTH'(bus.addr)] <= bus.wdata;
    end

endmodule
