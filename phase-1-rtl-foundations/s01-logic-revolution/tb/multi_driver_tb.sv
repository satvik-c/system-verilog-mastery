`timescale 1ns / 1ps

module multi_driver_tb();

    logic a, b;
    wire y_wire;
    logic y_logic;

    // Device Under Test
    multi_driver dut (
        .*
    );

    initial begin
        $dumpfile("multi_driver_tb_sim.vcd");
        $dumpvars(0, multi_driver_tb);

        a = 0; b = 0;
        #10 a = 0; b = 1;
        #10 a = 1; b = 0;
        #10 a = 1; b = 1;

        #100 $finish;
    end

endmodule
