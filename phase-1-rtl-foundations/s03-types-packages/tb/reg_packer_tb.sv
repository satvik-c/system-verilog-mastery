`timescale 1ns / 1ps

module reg_packer_tb();

    logic [7:0] addr_in; logic rw_in; logic [6:0] reserved_in;
    logic [15:0] packed_bits; project_pkg::spi_cmd_t cmd_out;

    // Device Under Test
    reg_packer dut (
        .*
    );

    initial begin
        $dumpfile("reg_packer_tb_sim.fst");
        $dumpvars(0, reg_packer_tb);

        addr_in = 8'h2C; rw_in = 1; reserved_in = 0;
        #1 $display("Packed bits: %h, Command: %h", packed_bits, cmd_out);
        #20;

        addr_in = 8'hFF; rw_in = 0; reserved_in = 7'h55;
        #1 $display("Packed bits: %h, Command: %h", packed_bits, cmd_out);
        #20;

        addr_in = 8'hAA; rw_in = 1; reserved_in = 7'h2C;
        #1 $display("Packed bits: %h, Command: %h", packed_bits, cmd_out);
        #20;

        #100 $finish;
    end

endmodule
