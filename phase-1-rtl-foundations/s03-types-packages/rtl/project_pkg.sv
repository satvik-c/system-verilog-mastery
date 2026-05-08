package project_pkg;
    
    localparam int SYS_CLK_HZ = 100_000_000;

    typedef enum logic [1:0] {
        RED,
        GREEN,
        YELLOW
    } light_state_t;

    typedef struct packed {
        logic red_on;
        logic green_on;
        logic yellow_on;
    } light_outputs_t;

    typedef struct packed {
        logic [7:0] addr;
        logic rw;
        logic [6:0] reserved;
    } spi_cmd_t;

endpackage
