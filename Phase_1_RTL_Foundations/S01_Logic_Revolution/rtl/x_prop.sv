`default_nettype none

module x_prop (
    input logic a, b, c,
    output logic y_and, y_or, y_chain
);

    always_comb begin
        y_and = a & b;
        y_or = a | b;
        y_chain = (a & b) | c;
    end

endmodule
