`default_nettype none

module bus_master
    import bus_pkg::*;
#(
    // Parameters
)(
    input logic clk, rst, start_write, start_read,
    input logic [15:0] req_addr, input logic [31:0] req_wdata,
    bus_if.master bus
);

    logic [31:0] latched_rdata;

    state_t CS, NS;

    always_ff @(posedge clk) begin
        if (rst) CS <= IDLE;
        else CS <= NS;
    end

    always_comb begin
        NS = CS;
        case (CS)
            IDLE: begin
                if (start_write) NS = WRITE;
                else if (start_read) NS = READ;
            end
            WRITE: if (bus.ready) NS = DONE;
            READ: if (bus.ready) NS = DONE;
            DONE: NS = IDLE;
        endcase
    end

    always_comb begin
        bus.addr = req_addr;
        bus.wdata = req_wdata;
        bus.write_en = 0;
        bus.read_en = 0;

        case (CS)
            IDLE: ;
            WRITE: bus.write_en = 1;
            READ: bus.read_en = 1;
            DONE: ;
        endcase
    end

    always_ff @(posedge clk) begin
        if (bus.read_en) latched_rdata <= bus.rdata;
    end

endmodule
