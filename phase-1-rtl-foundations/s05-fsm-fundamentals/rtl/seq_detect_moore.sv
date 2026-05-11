`default_nettype none

module seq_detect_moore
    import project_pkg::*;
#(
    // Parameters
)(
    input logic clk, rst, in,
    output logic detected
);

    moore_state_t CS, NS;

    always_ff @(posedge clk) begin
        if (rst) CS <= MO_NONE;
        else CS <= NS;
    end

    always_comb begin
        NS = CS;
        case (CS)
            MO_NONE: begin
                if (in) NS = MO_ONE_1;
                else NS = MO_NONE;
            end
            MO_ONE_1: begin
                if (in) NS = MO_ONE_2;
                else NS = MO_NONE;
            end
            MO_ONE_2: begin
                if (!in) NS = MO_ZERO_1;
                else NS = MO_ONE_2;
            end
            MO_ZERO_1: begin
                if (in) NS = MO_DONE;
                else NS = MO_NONE;
            end
            MO_DONE: begin
                if (in) NS = MO_ONE_2;
                else NS = MO_NONE;
            end
            default: ;
        endcase
    end

    always_comb begin
        detected = 0;
        case (CS)
            MO_NONE: ;
            MO_ONE_1: ;
            MO_ONE_2: ;
            MO_ZERO_1: ;
            MO_DONE: detected = 1;
            default: ;
        endcase
    end
    
endmodule
