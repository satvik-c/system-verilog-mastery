module uart_rx
    import project_pkg::*;
#(
    parameter CLK_HZ = 100_000_000,
    parameter BAUD_RATE = 115_200,
    parameter DATA_BITS = 8,
    parameter PARITY_BITS = 1,
    parameter PARITY_MODE = EVEN,
    parameter STOP_BITS = 1,
    localparam BIT_COUNTER_W = $clog2(DATA_BITS)
)(
    input logic clk, rst, rx_in,
    output logic [DATA_BITS-1:0] rx_data,
    output logic rx_valid,
    output logic rx_error
);

    uart_state_t CS, NS;
    logic enable, os_tick;
    logic [3:0] os_counter; // 16x oversampling always
    logic [BIT_COUNTER_W-1:0] bit_counter;

    logic clear_counters, inc_bit_counter, load_shift_rx_data, update_framing, update_parity;

    logic data_done, stop_done; // no need for parity_done - only 0 or 1 bits
    assign data_done = (bit_counter == DATA_BITS - 1);
    assign stop_done = (bit_counter == STOP_BITS - 1);

    logic rx_parity_error;

    baud_gen #(.BAUD_RATE(BAUD_RATE*16)) gen (.*, .baud_tick(os_tick));

    always_ff @(posedge clk) begin
        if (rst) CS <= IDLE;
        else CS <= NS;
    end

    always_comb begin
        NS = CS;
        case (CS)
            IDLE: if (os_tick && !rx_in) NS = START;
            START: if (os_tick && os_counter == 7) begin
                if (rx_in == 0) NS = DATA;
                else NS = IDLE;
            end
            DATA: if (os_tick && os_counter == 15 && data_done) begin
                if (PARITY_BITS != 0) NS = PARITY;
                else NS = STOP;
            end
            PARITY: if (os_tick && os_counter == 15) NS = STOP;
            STOP: if (os_tick && os_counter == 15 && stop_done) NS = IDLE;
            default: NS = CS;
        endcase
    end

    always_comb begin
        enable = 1;
        clear_counters = 0;
        inc_bit_counter = 0;
        load_shift_rx_data = 0;
        update_framing = 0;
        update_parity = 0;

        case (CS)
            IDLE: ;
            START: ;
            DATA: if (os_tick && os_counter == 15) begin
                load_shift_rx_data = 1;
                inc_bit_counter = 1;
            end
            PARITY: if (os_tick && os_counter == 15) begin
                update_parity = 1;
            end
            STOP: if (os_tick && os_counter == 15) begin
                update_framing = 1;
                inc_bit_counter = 1;
            end
            default: ;
        endcase

        if (CS != NS) clear_counters = 1; // clear both os_counter and bit_counter
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            os_counter <= '0;
            bit_counter <= '0;
            rx_data <= '0;
            rx_valid <= 0;
            rx_error <= 0;
            rx_parity_error <= 0;
        end
        else begin
            rx_valid <= 0;
            rx_error <= 0;
            // ========= COUNTERS ============= //

            if (clear_counters) begin
                os_counter <= '0;
                bit_counter <= '0;
            end
            else begin
                if (os_tick) os_counter <= os_counter + 1;
                if (inc_bit_counter) bit_counter <= bit_counter + 1;
            end

            // ========= SHIFT REGISTER ============= //

            if (load_shift_rx_data) begin
                rx_data <= {rx_in, rx_data[DATA_BITS-1:1]};
            end

            // ========= UPDATE FLAGS ============= //

            if (update_parity) begin
                if (PARITY_MODE == EVEN) rx_parity_error <= ^rx_data ^ rx_in;
                else rx_parity_error <= ~(^rx_data ^ rx_in);
            end

            if (update_framing) begin
                if (rx_in == 1 && rx_parity_error == 0) rx_valid <= 1;
                else rx_error <= 1;
                rx_parity_error <= 0;
            end
        end
    end

endmodule
