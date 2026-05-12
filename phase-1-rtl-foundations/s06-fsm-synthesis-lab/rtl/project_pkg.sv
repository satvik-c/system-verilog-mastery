package project_pkg;

    typedef enum logic [2:0] {
        GO_NS,
        SLOW_NS,
        STOP_NS,
        GO_EW,
        SLOW_EW,
        STOP_EW,
        FLASH_ON,
        FLASH_OFF
    } fsm_state_t;

    typedef enum logic [1:0] {
        OFF,
        RED,
        YELLOW,
        GREEN
    } light_t;

    typedef enum logic [1:0] {
        NORMAL,
        FLASH,
        PED
    } mode_t;

endpackage
