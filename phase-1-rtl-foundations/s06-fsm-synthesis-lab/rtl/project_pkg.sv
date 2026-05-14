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

    typedef enum logic [2:0] {
        OFF = 3'b000,
        RED = 3'b001,       // RGB: 1,0,0
        YELLOW = 3'b011,    // RGB: 1,1,0
        GREEN = 3'b010      // RGB: 0,1,0
    } light_t;

    typedef enum logic [1:0] {
        NORMAL,
        FLASH,
        PED
    } mode_t;

endpackage
