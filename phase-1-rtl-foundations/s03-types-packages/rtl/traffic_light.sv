`default_nettype none

module traffic_light 
    import project_pkg::*;
(
    input logic clk, rst, tick,
    output light_outputs_t lights,
    output light_state_t state
);


    always_ff @(posedge clk) begin
        if (rst) state <= RED;
        else if (tick) begin
            case (state)
                RED: state <= GREEN;
                GREEN: state <= YELLOW;
                YELLOW: state <= RED;
                default: state <= RED;
            endcase
        end
    end

    always_comb begin
        lights = '0;
        case (state)
            RED: lights.red_on = 1;
            GREEN: lights.green_on = 1;
            YELLOW: lights.yellow_on = 1;
            default: lights = '0;
        endcase
    end

endmodule
