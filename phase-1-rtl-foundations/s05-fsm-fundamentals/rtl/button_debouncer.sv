`default_nettype none

module button_debouncer
    import project_pkg::*;
#(
    parameter int CLK_HZ = 100_000_000,
    parameter int DEBOUNCE_MS = 10,
    localparam COUNTER_MAX = (CLK_HZ / 1000 * DEBOUNCE_MS),
    localparam COUNTER_WIDTH = $clog2(COUNTER_MAX)
)(
    input logic clk, rst, btn_raw,
    output logic btn_clean
);

    btn_state_t CS, NS;
    logic [COUNTER_WIDTH-1:0] counter;
    logic clear_counter, counter_done;

    assign counter_done = (counter == COUNTER_WIDTH'(COUNTER_MAX-1));

    always_ff @(posedge clk) begin
        if (rst) CS <= RELEASED;
        else CS <= NS;
    end

    always_ff @(posedge clk) begin
        if (rst) counter <= '0;
        else if (clear_counter || counter_done) counter <= '0;
        else counter <= counter + 1;
    end

    always_comb begin
        NS = CS;
        case (CS)
            RELEASED: begin
                if (btn_raw) NS = PRESS_WAIT;
            end
            PRESS_WAIT: begin
                if (!btn_raw) NS = RELEASED;
                else if (counter_done) NS = PRESSED;
            end
            PRESSED: begin
                if (!btn_raw) NS = RELEASE_WAIT;
            end
            RELEASE_WAIT: begin
                if (btn_raw) NS = PRESSED;
                else if (counter_done) NS = RELEASED;
            end
        endcase
    end

    always_comb begin
        btn_clean = 0;
        clear_counter = 0;

        case (CS)
            RELEASED: clear_counter = 1;
            PRESS_WAIT: ;
            PRESSED: begin
                btn_clean = 1;
                clear_counter = 1;
            end
            RELEASE_WAIT: btn_clean = 1;
        endcase
    end

endmodule
