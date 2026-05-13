package bus_pkg;

    typedef enum logic [1:0] {
        IDLE,
        WRITE,
        READ,
        DONE
    } state_t;

endpackage
