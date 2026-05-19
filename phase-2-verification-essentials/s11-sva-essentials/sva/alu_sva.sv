`default_nettype none

module alu_sva
    import project_pkg::*;
#(
    parameter W = 32,
    localparam SHAMT_W = $clog2(W)
)(
    input logic clk, rst,
    input opcode_t opcode,
    input logic [W-1:0] a, b,
    input flags_t flags,
    input logic [W-1:0] result
);

    assert property (@(posedge clk) disable iff(rst)
       flags.Z == (result === 0)
    )
    else begin
       $warning("[SVA] Z flag high but result is %h", result);
       alu_tb.sva_errors++;
    end

    assert property (@(posedge clk) disable iff(rst)
       flags.N === result[W-1]
    )
    else begin
       $warning("[SVA] N flag is not MSB of result");
       alu_tb.sva_errors++;
    end

    assert property (@(posedge clk) disable iff(rst)
       (opcode !== ALU_ADD && opcode !== ALU_SUB) |-> (flags.V === 0 && flags.C === 0)
    )
    else begin
       $warning("[SVA] C and V flags are non-zero in non-add/sub operation");
       alu_tb.sva_errors++;
    end

    assert property (@(posedge clk) disable iff(rst)
       (opcode.name() !== "") |-> (!$isunknown(result) && !$isunknown(flags))
    )
    else begin
       $warning("[SVA] Result/flags are corrupted in legal opcode");
       alu_tb.sva_errors++;
    end

    assert property (@(posedge clk) disable iff(rst)
       (opcode == ALU_SLL) |-> (result == (a << b[SHAMT_W-1:0]))
    )
    else begin
       $warning("[SVA] Wrong SLL logic");
       alu_tb.sva_errors++;
    end

endmodule
