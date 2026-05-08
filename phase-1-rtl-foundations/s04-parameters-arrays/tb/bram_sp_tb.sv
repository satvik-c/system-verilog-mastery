`timescale 1ns / 1ps

module bram_sp_tb();

    logic clk, we; logic [7:0] addr;
    logic [7:0] wr_data, rd_data;

    bram_sp #(.DEPTH(256), .WIDTH(8)) dut (
        .*
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("bram_sp_tb_sim.fst");
        $dumpvars(0, bram_sp_tb);

        we = 0;
        addr = 0;
        wr_data = 0;
        #20;

        we = 1;
        for (int i = 0; i < 16; i = i + 1) begin
            @(posedge clk) begin
                #1;
                addr = i;
                wr_data = 8'hA0 + i;
            end
        end
        #20;

        we = 0;
        for (int i = 0; i < 16; i = i + 1) begin
            @(posedge clk) begin
                #1;
                addr = i;
            end

            @(posedge clk) begin
                #1;
                $display("Read: %h, Expected: %h", rd_data, 8'hA0 + i);
            end
        end

        #100 $finish;
    end

endmodule
