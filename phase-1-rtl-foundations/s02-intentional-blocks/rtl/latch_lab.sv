`default_nettype none

module latch_lab (
    input logic x, 
    input logic [2:0] op,
    output logic y_a, y_b, y_c1, y_c2
);

    always_comb begin
        // y_a = 0; <------ this will remove the latch
        if (x) y_a = 1;
        // no else for y_a, so it becomes a latch
    end

    always_comb begin
        case (op)
            3'b000: y_b = 0;
            3'b001: y_b = 1;
            // No output for 010-111, X, Z: y_b becomes a latch
            // default: y_b = 0; <------ this will remove the latch
        endcase
    end

    always_comb begin
        // y_c2 = 0; <------- this will remove the latch
        if (x) begin
            y_c1 = 1;
            y_c2 = 1;
        end else begin
            y_c1 = 0;
            // no else for y_c2, so it becomes a latch (EASY TO MISS)
        end
    end

endmodule
