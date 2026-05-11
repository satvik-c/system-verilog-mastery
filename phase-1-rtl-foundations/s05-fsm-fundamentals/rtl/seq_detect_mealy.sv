`default_nettype none

module seq_detect_mealy
    import project_pkg::*;
#(
    // Parameters
)(
    input logic clk, rst, in,
    output logic detected
);

    mealy_state_t CS, NS;

    always_ff @(posedge clk) begin
        if (rst) CS <= ME_NONE;
        else CS <= NS;
    end

    always_comb begin
        NS = CS;
        case (CS)
            ME_NONE: begin
                if (in) NS = ME_ONE_1;
                else NS = ME_NONE;
            end
            ME_ONE_1: begin
                if (in) NS = ME_ONE_2;
                else NS = ME_NONE;
            end
            ME_ONE_2: begin
                if (!in) NS = ME_ZERO_1;
                else NS = ME_ONE_2;
            end
            ME_ZERO_1: begin
                if (in) NS = ME_ONE_1;
                else NS = ME_NONE;
            end
        endcase
    end

    always_comb begin
        case (CS)
            ME_NONE: detected = 0;
            ME_ONE_1: detected = 0;
            ME_ONE_2: detected = 0;
            ME_ZERO_1: begin
                if (in) detected = 1;
                else detected = 0;
            end
        endcase
    end
    
endmodule
