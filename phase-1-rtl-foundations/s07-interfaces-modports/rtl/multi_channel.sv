`default_nettype none

module multi_channel
    // Imports;
#(
    parameter NUM_CHANNELS = 4
)(
    input logic clk, rst,
    input logic [NUM_CHANNELS-1:0] enable,
    input logic [NUM_CHANNELS-1:0][15:0] period,
    output logic [NUM_CHANNELS-1:0] pulse
);

    for (genvar i = 0; i < NUM_CHANNELS; i = i + 1) begin : gen_chan
        channel_if channel();
        assign channel.enable = enable[i];
        assign channel.period = period[i];
        assign pulse[i] = channel.pulse;
        pulse_channel u_channel (
            .clk(clk),
            .rst(rst),
            .channel(channel.producer)
        );
    end

endmodule
