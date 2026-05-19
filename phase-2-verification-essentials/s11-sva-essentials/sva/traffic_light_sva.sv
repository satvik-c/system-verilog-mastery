`default_nettype none

module traffic_light_sva
    import project_pkg::*;
#(
    parameter COUNT_MAX = 200_000_000, // 2 seconds default
    localparam COUNT_WIDTH = $clog2(COUNT_MAX)
)(
    input logic clk, rst, input mode_t mode,
    input fsm_state_t CS, input counter_done,
    input light_t ns_light, ew_light
);

    assert property (@(posedge clk) disable iff(rst)
       CS.name() !== ""
    )
    else begin
       $warning("[SVA] Invalid FSM state");
    end

    assert property (@(posedge clk) disable iff(rst)
       !(ew_light == GREEN && ns_light == GREEN)
    )
    else begin
       $warning("[SVA] Both lights green at same time");
    end

    assert property (@(posedge clk) disable iff(rst)
       (CS == GO_NS && counter_done) |=> (CS == SLOW_NS)
    )
    else begin
       $warning("[SVA] Next state after GO_NS isn't SLOW_NS");
    end
    
    assert property (@(posedge clk) disable iff(rst)
       (!counter_done) |=> (CS == $past(CS))
    )
    else begin
       $warning("[SVA] Unstable state in FSM");
    end

endmodule
