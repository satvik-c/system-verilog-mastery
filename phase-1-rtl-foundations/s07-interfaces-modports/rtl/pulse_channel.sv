`default_nettype none

module pulse_channel
    // Imports;
#(

)(
    input logic clk, rst,
    channel_if.producer channel
);

    logic [15:0] counter;

    always_ff @(posedge clk) begin
        channel.pulse <= 0;
        if (rst | !channel.enable) counter <= '0;
        else if (counter == channel.period-1) begin
            counter <= '0;
            channel.pulse <= 1;
        end
        else counter <= counter + 1;
    end

endmodule
