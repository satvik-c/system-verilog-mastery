`default_nettype none

module traffic_light_coverage
    import project_pkg::*;
#(
    parameter COUNT_MAX = 8
)(
    input logic clk, rst,
    input mode_t mode,
    input light_t ns_light, ew_light,
    input fsm_state_t CS
);

    const logic [7:0][7:0] legal_trans = '{
            0: 8'b0000_0010, // [0] GO_NS
            1: 8'b0000_0100, // [1] SLOW_NS
            2: 8'b0100_1000, // [2] STOP_NS
            3: 8'b0001_0000, // [3] GO_EW
            4: 8'b0010_0000, // [4] SLOW_EW
            5: 8'b0100_0001, // [5] STOP_EW
            6: 8'b1000_0100, // [6] FLASH_ON
            7: 8'b0100_0100  // [7] FLASH_OFF
        };

    fsm_state_t prev_state;
    logic [7:0][7:0] trans_hit;
    logic [7:0] state_hit;

    always_ff @(posedge clk) begin
        if (rst) prev_state <= GO_NS;
        else prev_state <= CS;
    end

    always_ff @(posedge clk) begin
        if (rst) trans_hit <= '0;
        else if (CS !== prev_state) begin
            if (legal_trans[prev_state][CS] == 0) $error("Illegal state transition");
            else trans_hit[prev_state][CS] <= 1;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) state_hit <= '0;
        else state_hit[CS] <= 1;
    end

    final begin
        $display("===== FUNCTIONAL COVERAGE REPORT =====");
        $display("%0d/%0d states reached", $countones(state_hit), $bits(state_hit));
        $display("%0d/%0d transitions exercised", $countones(trans_hit), $countones(legal_trans));
    end

endmodule
