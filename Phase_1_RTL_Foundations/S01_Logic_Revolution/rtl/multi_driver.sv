`default_nettype none

module multi_driver (
    input logic a,
    input logic b,
    output wire y_wire,
    output logic y_logic
);

    // Multidriven wire types silently fail and become X in simulation
    assign y_wire = a & b;
    assign y_wire = a | b;

    // Multidriven logic types fail at compile-time
    /*
    always_comb begin
        y_logic = a & b;
    end
    always_comb begin
        y_logic = a | b;
    end
    */

endmodule
