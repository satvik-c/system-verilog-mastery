package project_pkg;

    typedef enum logic [2:0] {
        IDLE,
        START,
        DATA,
        PARITY,
        STOP
    } uart_state_t;

    typedef enum logic {
        EVEN,
        ODD
    } parity_mode_t;

endpackage
