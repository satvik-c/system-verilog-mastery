package project_pkg;

    typedef enum logic [1:0] {
        IDLE,
        SETUP,
        SHIFT,
        HOLD
    } spi_state_t;

    typedef enum logic {
        REST,
        RUN
    } wrapper_state_t;

endpackage
