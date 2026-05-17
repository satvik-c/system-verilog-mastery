`default_nettype none

module alu
    import project_pkg::*;
#(
    parameter W = 32,
    localparam SHAMT_W = $clog2(W)
)(
    input opcode_t opcode,
    input logic [W-1:0] a, b,
    output flags_t flags,
    output logic [W-1:0] result
);

    logic [W:0] temp;

    always_comb begin
        result = '0;
        temp = '0;
        flags = '0;

        case (opcode)
            ALU_ADD: begin
                temp = {1'b0, a} + {1'b0, b};
                result = temp[W-1:0];
                flags.C = temp[W];
                flags.V = (a[W-1] == b[W-1] && result[W-1] != a[W-1]);
            end
            ALU_SUB: begin
                temp = {1'b0, a} + {1'b0, ~b} + 1'b1;
                result = temp[W-1:0];
                flags.C = temp[W];
                flags.V = (a[W-1] != b[W-1] && result[W-1] != a[W-1]);
            end
            ALU_AND: begin
                result = a & b;
            end
            ALU_OR: begin
                result = a | b;
            end
            ALU_XOR: begin
                result = a ^ b;
            end
            ALU_SLL: begin
                result = a << b[SHAMT_W-1:0];
            end
            ALU_SRL: begin
                result = a >> b[SHAMT_W-1:0];
            end
            ALU_SRA: begin
                result = $signed(a) >>> b[SHAMT_W-1:0];
            end
            ALU_SLT: begin
                result = ($signed(a) < $signed(b)) ? 1 : '0;
            end
            ALU_SLTU: begin
                result = (a < b) ? 1 : '0;
            end
            default: ;
        endcase

        flags.N = result[W-1];
        flags.Z = (result == '0);
    end

endmodule
