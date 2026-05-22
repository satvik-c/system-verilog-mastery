// COPY OF PREVIOUS CODE

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

    typedef enum logic [3:0] {
        ALU_ADD = 4'h0,
        ALU_SUB = 4'h1,
        ALU_AND = 4'h2,
        ALU_OR = 4'h3,
        ALU_XOR = 4'h4,
        ALU_SLL = 4'h5,
        ALU_SRL = 4'h6,
        ALU_SRA = 4'h7,
        ALU_SLT = 4'h8,
        ALU_SLTU = 4'h9
    } opcode_t;

    typedef struct packed {
        logic N;
        logic V;
        logic C;
        logic Z;
    } flags_t;

endpackage
