`default_nettype none

module uart_tx
    import project_pkg::*;
#(
    parameter CLK_HZ = 100_000_000,
    parameter BAUD_RATE = 115_200,
    parameter DATA_BITS = 8,
    parameter PARITY_BITS = 0,
    parameter STOP_BITS = 1,
    localparam CNT_W = $clog2(DATA_BITS)
)(
    input logic clk, rst,
    input logic tx_start,
    input logic [DATA_BITS-1:0] tx_data,
    output logic tx_busy, tx_out
);

// ====================== COUNTER/FLAGS =========================================== //

    logic [CNT_W-1:0] counter;

    logic data_done;
    assign data_done = (counter == CNT_W'(DATA_BITS - 1));

    logic parity_done;
    assign parity_done = (PARITY_BITS == 0) ? 1 : (counter == CNT_W'(PARITY_BITS - 1));

    logic stop_done;
    assign stop_done = (counter == CNT_W'(STOP_BITS - 1));

// ================================================================================ //
    logic baud_tick, enable;
    logic [DATA_BITS-1:0] shift_register;
    logic parity_bit;

    logic load_data, shift_data;
    logic clear_counter, inc_counter;
    logic calculate_parity;

    baud_gen #(.CLK_HZ(CLK_HZ), .BAUD_RATE(BAUD_RATE)) gen (.*);

// ========================= FSM =================================== //

    uart_state_t CS, NS;

    always_ff @(posedge clk) begin
        if (rst) CS <= IDLE;
        else CS <= NS;
    end

    always_comb begin
        NS = CS;
        case (CS)
            IDLE: if (tx_start && !tx_busy) NS = START;
            START: if (baud_tick) NS = DATA;
            DATA: if (baud_tick && data_done) begin
                if (PARITY_BITS != 0) NS = PARITY;
                else NS = STOP;
            end
            PARITY: if (baud_tick && parity_done) NS = STOP;
            STOP: if (baud_tick && stop_done) NS = IDLE;
            default: NS = CS;
        endcase
    end

    always_comb begin
        tx_busy = 1;
        enable = 1;
        tx_out = 1;

        load_data = 0;
        shift_data = 0;
        clear_counter = 0;
        inc_counter = 0;
        calculate_parity = 0;

        case (CS)
            IDLE: begin
                tx_busy = 0;
                enable = 0;
                tx_out = 1;
                if (tx_start && !tx_busy) begin
                    load_data = 1; // DATAPATH
                    calculate_parity = 1; // DATAPATH
                end
            end
            START: begin
                tx_out = 0;
            end
            DATA: begin
                tx_out = shift_register[0];
                if (baud_tick) begin
                    inc_counter = 1; // DATAPATH
                    shift_data = 1; // DATAPATH
                end
            end
            PARITY: begin
                tx_out = parity_bit;
                if (baud_tick) inc_counter = 1; // DATAPATH
            end
            STOP: begin
                tx_out = 1;
                if (baud_tick) inc_counter = 1; // DATAPATH
            end
            default: tx_out = 1;
        endcase

        if (CS != NS) clear_counter = 1; // DATAPATH
    end

// ======================= DATAPATH ============================== //

    always_ff @(posedge clk) begin
        if (rst || clear_counter) counter <= '0;
        else if (inc_counter) counter <= counter + 1;
        if (load_data) shift_register <= tx_data;
        else if (shift_data) shift_register <= shift_register >> 1;
        if (calculate_parity) parity_bit <= ^tx_data; // EVEN PARITY
    end

endmodule
