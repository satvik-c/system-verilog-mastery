`timescale 1ns / 1ps

module latch_lab_tb();

    logic x; logic [2:0] op;
    logic y_a, y_b, y_c1, y_c2;

    // Device Under Test
    latch_lab dut (
        .*
    );

    initial begin
        $dumpfile("latch_lab_tb_sim.vcd");
        $dumpvars(0, latch_lab_tb);

        for (int i = 0; i < 32; i++) begin
            {x, op} = 4'(i);
            $display("x: %b, op: %b | y_a: %b, y_b: %b, y_c1: %b, y_c2: %b", 
            x, op, y_a, y_b, y_c1, y_c2);
            #10;
        end

        #100 $finish;
    end

endmodule
