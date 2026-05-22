`default_nettype none

module alu_coverage
    import project_pkg::*;
#(
    parameter W = 32
)(  
    input logic clk, rst,
    input opcode_t opcode,
    input logic [W-1:0] a, b, result,
    input flags_t flags
);

    logic [9:0] cp_op;
    logic [5:0] cp_a_class, cp_b_class;
    logic [9:0][5:0] cr_op_a, cr_op_b;

    function automatic int classify(logic [W-1:0] v);
        if (v == 32'h0000_0000) return 0;
        else if (v == 32'hFFFF_FFFF) return 1;
        else if (v == 32'h8000_0000) return 2;
        else if (v == 32'h0000_0001) return 3;
        else if (!v[W-1]) return 4;
        else return 5;
    endfunction

    always_ff @(posedge clk) begin
        if (rst) cp_op <= '0;
        else cp_op[opcode] <= 1;
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            cp_a_class <= '0;
            cp_b_class <= '0;
        end
        else begin
            cp_a_class[classify(a)] <= 1;
            cp_b_class[classify(b)] <= 1;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            cr_op_a <= '0;
            cr_op_b <= '0;
        end
        else if (!(opcode inside {ALU_AND, ALU_OR, ALU_XOR})) begin
            cr_op_a[opcode][classify(a)] <= 1;
            cr_op_b[opcode][classify(b)] <= 1;
        end
    end

    final begin
        $display("===========================");
        $display("FUNCTIONAL COVERAGE REPORT");
        $display("cp_op: %0d/%0d", $countones(cp_op), $bits(cp_op));
        $display("cp_a_class: %0d/%0d", $countones(cp_a_class), $bits(cp_a_class));
        $display("cp_b_class: %0d/%0d", $countones(cp_b_class), $bits(cp_b_class));
        $display("cr_op_a: %0d/%0d", $countones(cr_op_a), $bits(cr_op_a)-3*6);
        $display("cr_op_b: %0d/%0d", $countones(cr_op_b), $bits(cr_op_b)-3*6);
    end

endmodule
