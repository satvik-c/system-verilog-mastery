`timescale 1ns / 1ps

import project_pkg::*;

module alu_tb();

    localparam W = 32;

    opcode_t opcode; logic [W-1:0] a, b;
    flags_t flags; logic [W-1:0] result;
    logic clk, rst;

    alu #(.W(W)) dut (
        .*
    );

    bind alu alu_sva u_alu_sva (
        .clk   (alu_tb.clk),    // no clk in alu.sv
        .rst   (alu_tb.rst),    // no rst in alu.sv
        .opcode(opcode),
        .a     (a),
        .b     (b),
        .flags (flags),
        .result(result)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    int check_ct = 0;
    int error_ct = 0;
    int sva_errors = 0;
    logic test_done;

    task automatic check_alu(opcode_t op, logic [W-1:0] av, logic [W-1:0] bv);
        logic [W-1:0] expected_result;
        flags_t expected_flags;

        expected_flags.C = 0;
        expected_flags.V = 0;

        case (op)
            ALU_ADD: begin
                {expected_flags.C, expected_result} = av + bv;
                expected_flags.V = ($signed(av) >= 0 && $signed(bv) >= 0 && $signed(expected_result) < 0) ||
                                   ($signed(av) < 0 && $signed(bv) < 0 && $signed(expected_result) >= 0);
            end
            ALU_SUB: begin
                expected_result = av - bv;
                expected_flags.C = (av >= bv);
                expected_flags.V = ($signed(av) >= 0 && $signed(bv) < 0 && $signed(expected_result) < 0) ||
                                   ($signed(av) < 0 && $signed(bv) >= 0 && $signed(expected_result) >= 0);
            end
            ALU_AND: expected_result = av & bv;
            ALU_OR: expected_result = av | bv;
            ALU_XOR: expected_result = av ^ bv;
            ALU_SLL: expected_result = av << bv[$clog2(W)-1:0];
            ALU_SRL: expected_result = av >> bv[$clog2(W)-1:0];
            ALU_SRA: expected_result = $signed(av) >>> bv[$clog2(W)-1:0];
            ALU_SLT: expected_result = ($signed(av) < $signed(bv)) ? 1 : 0;
            ALU_SLTU: expected_result = (av < bv) ? 1 : 0;
            default: begin
                expected_result = 0;
                $fatal;
            end
        endcase

        expected_flags.N = ($signed(expected_result) < 0);
        expected_flags.Z = (expected_result == '0);

        @(posedge clk) #1;
        opcode = op;
        a = av;
        b = bv;
        #1;

        check_ct++;
        if (result !== expected_result || flags !== expected_flags) begin
            error_ct++;
            $display("[%0t] op=%s a=%h b=%h | got result=%h flags=%b | exp result=%h flags=%b"
            , $time, opcode.name(), a, b, result, flags, expected_result, expected_flags);
        end
    endtask

    typedef struct packed {
        opcode_t opcode;
        logic [W-1:0] a;
        logic [W-1:0] b;
        logic [W-1:0] expected_result;
        flags_t expected_flags;
    } alu_vec_t;

    localparam VECTOR_NUM = 35;

    alu_vec_t vectors [0:VECTOR_NUM-1]; // Vectors for W=32

    task automatic check_alu_vector(alu_vec_t v);
        @(posedge clk) #1;
        opcode = v.opcode;
        a = v.a;
        b = v.b;
        #1;

        check_ct++;
        if (result !== v.expected_result || flags !== v.expected_flags) begin
            error_ct++;
            $display("[%0t] op=%s a=%h b=%h | got result=%h flags=%b | exp result=%h flags=%b"
            , $time, opcode.name(), a, b, result, flags, v.expected_result, v.expected_flags);
        end
    endtask

    initial begin
        $dumpfile("alu_tb_sim.fst");
        $dumpvars(0, alu_tb);
        $readmemh("vectors/alu_directed.hex", vectors);

        rst = 1;
        @(posedge clk);
        #1 rst = 0;

        test_done = 0;

        for (int i = 0; i < VECTOR_NUM; i++) begin
            check_alu_vector(vectors[i]);
        end

        /*
        // Exhaustive test for W=4

        for (int op_i = 0; op_i < 10; op_i++) begin
            for (int i = 0; i < 2 ** W; i++) begin
                for (int j = 0; j < 2 ** W; j++) begin
                    check_alu(opcode_t'(op_i), i[W-1:0], j[W-1:0]);
                end
            end
        end
        */

        test_done = 1;
    end

    initial begin
        wait(test_done);
        $display("===========================");
        if (error_ct == 0 && sva_errors == 0) $display("ALL TESTS PASSED! (%0d total)", check_ct);
        else $display("%0d test(s) failed, %0d assertion(s) failed. (%0d total)", error_ct, sva_errors, check_ct);
        $display("===========================");
        $finish;
    end

endmodule
