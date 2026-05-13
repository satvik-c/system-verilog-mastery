interface channel_if;
    
    logic enable;
    logic [15:0] period;
    logic pulse;

    modport producer (
    input enable, period,
    output pulse
    );

    modport consumer (
    input pulse,
    output enable, period
    );

endinterface
