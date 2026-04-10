`timescale 1ns / 1ps

module float_demo_tb();

    logic sel;
    logic out_logic, out_wire;

    // Device Under Test
    float_demo dut (
        .*
    );

    initial begin
        $dumpfile("float_demo_tb_sim.vcd");
        $dumpvars(0, float_demo_tb);

        sel = 0;        // out_logic is initially X
        #10 sel = 1;    // out_logic is 1
        #10 sel = 0;    // out_logic will latch onto previous value
        #10 sel = 1;    // ...

        #100 $finish;
    end

endmodule
