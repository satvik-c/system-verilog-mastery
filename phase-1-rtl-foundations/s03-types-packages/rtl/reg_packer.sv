`default_nettype none

module reg_packer 
    import project_pkg::*;
(
    input logic [7:0] addr_in,
    input logic rw_in,
    input logic [6:0] reserved_in,
    output logic [15:0] packed_bits,
    output spi_cmd_t cmd_out
);

    assign cmd_out = '{addr: addr_in, rw: rw_in, reserved: reserved_in};
    assign packed_bits = cmd_out;

endmodule
