module spi_master
    import project_pkg::*;
#(
    parameter SYS_CLK_HZ = 100_000_000,
    parameter SPI_CLK_HZ = 1_000_000,
    parameter DATA_WIDTH = 8,
    parameter CPOL = 0,
    parameter CPHA = 0,
    parameter CS_SETUP_CYCLES = 0,
    parameter CS_HOLD_CYCLES = 0,
    localparam MAX_WAIT_CYCLES = (CS_SETUP_CYCLES > CS_HOLD_CYCLES) ? CS_SETUP_CYCLES : CS_HOLD_CYCLES,
    localparam WAIT_W = (MAX_WAIT_CYCLES > 1) ? $clog2(MAX_WAIT_CYCLES) : 1,
    localparam SCLK_DIV = (SYS_CLK_HZ / (2 * SPI_CLK_HZ)),
    localparam SCLK_COUNTER_W = $clog2(SCLK_DIV)
)(
    input logic clk, rst,
    input logic miso, start,
    input logic [7:0] num_bytes,
    input logic [DATA_WIDTH-1:0] tx_data,
    output logic sclk, mosi, cs,
    output logic [DATA_WIDTH-1:0] rx_data,
    output logic rx_valid, busy, tx_ready
);

    spi_state_t CS, NS;

    // SCLK
    logic [SCLK_COUNTER_W-1:0] sclk_counter;
    logic sclk_int, sclk_en;
    logic leading_strobe, trailing_strobe;
    logic drive_strobe, sample_strobe;

    always_ff @(posedge clk) begin
        if (rst || !sclk_en) begin
            sclk_counter <= '0;
            sclk_int <= 0;
        end
        else if (sclk_counter == SCLK_DIV - 1) begin
            sclk_counter <= '0;
            sclk_int <= ~sclk_int;
        end
        else sclk_counter <= sclk_counter + 1;
    end

    assign leading_strobe = (sclk_en && sclk_counter == SCLK_DIV - 1 && sclk_int == 0);
    assign trailing_strobe = (sclk_en && sclk_counter == SCLK_DIV - 1 && sclk_int == 1);
    assign drive_strobe = (CPHA) ? leading_strobe : trailing_strobe;
    assign sample_strobe = (CPHA) ? trailing_strobe : leading_strobe;

    // Counters (Setup/Hold)
    logic [WAIT_W-1:0] wait_counter;
    logic setup_done, hold_done;
    assign setup_done = (CS_SETUP_CYCLES == 0) ? 1 : (wait_counter == CS_SETUP_CYCLES - 1);
    assign hold_done = (CS_HOLD_CYCLES == 0) ? 1 : (wait_counter == CS_HOLD_CYCLES - 1);

    always_ff @(posedge clk) begin
        if (rst) wait_counter <= '0;
        else if (CS == SETUP || CS == HOLD) wait_counter <= wait_counter + 1;
        else wait_counter <= '0;
    end

    // FSM
    logic load_tx_shift, drive_bit, sample_bit;
    logic [DATA_WIDTH-1:0] tx_shift, rx_shift;
    logic byte_done, all_bytes_done;

    always_ff @(posedge clk) begin
        if (rst) CS <= IDLE;
        else CS <= NS;
    end

    always_comb begin
        NS = CS;
        case (CS)
            IDLE: if (start) NS = SETUP;
            SETUP: if (setup_done) NS = SHIFT;
            SHIFT: if (all_bytes_done) NS = HOLD;
            HOLD: if (hold_done) NS = IDLE;
            default: NS = IDLE;
        endcase
    end

    always_comb begin
        sclk = sclk_int ^ CPOL;
        mosi = tx_shift[DATA_WIDTH-1];
        cs = 0;
        busy = 1;
        sclk_en = 0;
        load_tx_shift = 0;
        drive_bit = 0;
        sample_bit = 0;

        case (CS)
            IDLE: begin
                cs = 1;
                busy = 0;
            end
            SETUP: begin
                if (setup_done) load_tx_shift = 1;
            end
            SHIFT: begin
                sclk_en = 1;
                if (drive_strobe) drive_bit = 1;
                else if (sample_strobe) sample_bit = 1;
                if (byte_done && !all_bytes_done) load_tx_shift = 1;
            end
            HOLD: ;
        endcase
    end

    // Datapath
    logic [$clog2(DATA_WIDTH)-1:0] bit_counter;
    logic [7:0] byte_counter;
    assign byte_done = (trailing_strobe && bit_counter == DATA_WIDTH - 1);
    assign all_bytes_done = (trailing_strobe && bit_counter == DATA_WIDTH - 1 && byte_counter == num_bytes - 1);
    assign rx_valid = byte_done;
    assign rx_data = rx_shift;
    logic hold_msb;
    assign hold_msb = (CPHA == 1 && bit_counter == '0);

    always_ff @(posedge clk) begin
        if (rst) begin
            bit_counter <= '0;
            byte_counter <= '0;
            tx_shift <= '0;
            rx_shift <= '0;
            tx_ready <= 0;
        end
        else begin
            tx_ready <= 0;

            if (load_tx_shift) begin
                tx_shift <= tx_data;
                tx_ready <= 1;
            end
            else if (drive_bit && !hold_msb) begin
                tx_shift <= {tx_shift[DATA_WIDTH-2:0], 1'b0};
            end
            if (sample_bit) begin
                rx_shift <= {rx_shift[DATA_WIDTH-2:0], miso};
            end

            if (CS == IDLE) begin
                bit_counter <= '0;
                byte_counter <= '0;
            end
            if (trailing_strobe) begin
                if (bit_counter == DATA_WIDTH - 1) begin
                    bit_counter <= '0;
                    byte_counter <= byte_counter + 1;
                end
                else bit_counter <= bit_counter + 1;
            end
        end
    end

endmodule
