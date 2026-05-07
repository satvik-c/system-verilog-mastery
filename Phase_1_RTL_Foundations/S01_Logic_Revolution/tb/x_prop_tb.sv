`timescale 1ns / 1ps

module x_prop_tb();

    logic a, b, c;
    logic y_and, y_or, y_chain;

    // Device Under Test
    x_prop dut (
        .*
    );

    initial begin
        $dumpfile("x_prop_tb_sim.vcd");
        $dumpvars(0, x_prop_tb);

        // Test 1: y_and = 0, y_or = X, y_chain = 0
        a = 1'bx; b = 1'b0; c = 1'b0;
        #10 $display("y_and = %b, y_or = %b, y_chain = %b", y_and, y_or, y_chain);

        // Test 2: y_and = X, y_or = 1, y_chain = 1
        #10 a = 1'bx; b = 1'b1; c = 1'b1;
        #10 $display("y_and = %b, y_or = %b, y_chain = %b", y_and, y_or, y_chain);
        
        // Test 3: y_and = X, y_or = X, y_chain = X
        #10 a = 1'bx; b = 1'bx; c = 1'b0;
        #10 $display("y_and = %b, y_or = %b, y_chain = %b", y_and, y_or, y_chain);

        #100 $finish;
    end

endmodule
