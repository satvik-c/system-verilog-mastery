module adxl362_model
    // Imports;
#(
    // Parameters
)(
    input logic cs,
    input logic sclk,
    input logic mosi,
    output logic miso
);

    logic [7:0] mem [128];
    logic [7:0] in_shift, out_shift;
    logic [7:0] bit_count;
    int byte_count;
    logic [7:0] addr;
    logic is_read, is_write;

    assign miso = (cs) ? 1'bz : out_shift[7];

    always @(negedge cs) begin
        bit_count = '0;
        byte_count = 0;
        is_read = 0;
        is_write = 0;
    end

    always @(posedge sclk) begin
        in_shift = {in_shift[6:0], mosi};
        bit_count = bit_count + 1;
        if (bit_count == 8) begin
            bit_count = 0;
            if (byte_count == 0) begin
                if (in_shift == 8'h0B) is_read = 1;
                else if (in_shift == 8'h0A) is_write = 1;
            end
            else if (byte_count == 1) addr = in_shift;
            else if (is_write) begin
                mem[addr] = in_shift;
                addr = addr + 1;
            end
            byte_count = byte_count + 1;
        end
    end

    always @(negedge sclk) begin
        out_shift = {out_shift[6:0], 1'b0};
        if (is_read && bit_count == 0 && byte_count >= 2) begin
            out_shift = mem[addr];
            addr = addr + 1;
        end
    end

    initial begin
        mem[8'h00] = 8'hAD;
        mem[8'h01] = 8'h1D;
        mem[8'h02] = 8'hF2;
        mem[8'h03] = 8'h01;
    end

endmodule
