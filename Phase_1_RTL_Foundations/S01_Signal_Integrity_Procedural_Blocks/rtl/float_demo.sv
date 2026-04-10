`default_nettype none

module float_demo (
    input logic sel,
    output logic out_logic,
    output wire out_wire
);

    // Undriven out_wire to show Z value

    always_comb begin
        if (sel) begin
            out_logic = sel;
        end
        // No else branch to purposefully create latch
    end

endmodule
