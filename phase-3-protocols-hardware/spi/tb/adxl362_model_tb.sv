`timescale 1ns / 1ps

module adxl362_model_tb();

    logic cs, sclk, mosi, miso;

    adxl362_model dut (
        .*
    );

    task automatic read_mem(logic [7:0] addr);
        logic [7:0] read_cmd = 8'h0B;
        cs = 0;
        for (int i = 7; i >= 0; i--) begin
            mosi = read_cmd[i];
            #5 sclk = 1;
            #5 sclk = 0;
        end
        for (int i = 7; i >= 0; i--) begin
            mosi = addr[i];
            #5 sclk = 1;
            #5 sclk = 0;
        end
        for (int i = 7; i >= 0; i--) begin
            #5 sclk = 1;
            #5 sclk = 0;
        end
        cs = 1;
    endtask

    initial begin

        cs = 1;
        mosi = 0;
        sclk = 0;
        #10;

        read_mem(8'h00);

        #100 $finish;
    end

endmodule
