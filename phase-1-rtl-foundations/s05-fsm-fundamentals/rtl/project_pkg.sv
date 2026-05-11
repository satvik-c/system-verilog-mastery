package project_pkg;
    
    typedef enum logic [1:0] {
        ME_NONE,
        ME_ONE_1,
        ME_ONE_2,
        ME_ZERO_1
    } mealy_state_t;

    typedef enum logic [2:0] {
        MO_NONE,
        MO_ONE_1,
        MO_ONE_2,
        MO_ZERO_1,
        MO_DONE
    } moore_state_t;

    typedef enum logic[1:0] {
        RELEASED,
        PRESS_WAIT,
        PRESSED,
        RELEASE_WAIT
    } btn_state_t;

endpackage
