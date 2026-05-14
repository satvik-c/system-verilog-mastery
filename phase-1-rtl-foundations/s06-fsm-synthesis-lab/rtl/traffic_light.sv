//`default_nettype none

module traffic_light
    import project_pkg::*;
#(
    parameter COUNT_MAX = 200_000_000, // 2 seconds default
    localparam COUNT_WIDTH = $clog2(COUNT_MAX)
)(
    input logic clk, rst, input mode_t mode,
    output light_t ns_light, ew_light
);

    (* fsm_encoding = "one_hot" *) fsm_state_t CS, NS;

    logic [COUNT_WIDTH-1:0] counter;
    logic short_delay, long_delay, counter_done;

    assign short_delay = (counter == COUNT_WIDTH'( (COUNT_MAX-1) / 4));
    assign long_delay = (counter == COUNT_WIDTH'(COUNT_MAX-1));

    always_ff @(posedge clk) begin
        if (rst) CS <= GO_NS;
        else CS <= NS;
    end

    always_ff @(posedge clk) begin
        if (rst || counter_done) counter <= '0;
        else counter <= counter + 1;
    end

    always_comb begin
        NS = CS;
        case (CS)
            GO_NS: if (counter_done) begin
                NS = SLOW_NS;
            end
            SLOW_NS: if (counter_done) begin
                NS = STOP_NS;
            end
            STOP_NS: if (counter_done) begin
                if (mode == PED) NS = STOP_NS;
                else if (mode == FLASH) NS = FLASH_ON;
                else NS = GO_EW;
            end
            GO_EW: if (counter_done) begin
                NS = SLOW_EW;
            end
            SLOW_EW: if (counter_done) begin
                NS = STOP_EW;
            end
            STOP_EW: if (counter_done) begin
                if (mode == PED) NS = STOP_EW;
                else if (mode == FLASH) NS = FLASH_ON;
                else NS = GO_NS;
            end
            FLASH_ON: if (counter_done) begin
                if (mode != FLASH) NS = STOP_NS;
                else NS = FLASH_OFF;
            end
            FLASH_OFF: if (counter_done) begin
                if (mode != FLASH) NS = STOP_NS;
                else NS = FLASH_ON;
            end
            default: ;
        endcase
    end

    always_comb begin
        counter_done = (CS == GO_NS || CS == GO_EW) ? long_delay : short_delay;
        ns_light = RED;
        ew_light = RED;
        case (CS)
            GO_NS: begin
                ns_light = GREEN;
                ew_light = RED;
            end
            SLOW_NS: begin
                ns_light = YELLOW;
                ew_light = RED;
            end
            STOP_NS: begin
                ns_light = RED;
                ew_light = RED;
            end
            GO_EW: begin
                ns_light = RED;
                ew_light = GREEN;
            end
            SLOW_EW: begin
                ns_light = RED;
                ew_light = YELLOW;
            end
            STOP_EW: begin
                ns_light = RED;
                ew_light = RED;
            end
            FLASH_ON: begin
                ns_light = YELLOW;
                ew_light = YELLOW;
            end
            FLASH_OFF: begin
                ns_light = OFF;
                ew_light = OFF;
            end
        endcase
    end

endmodule
