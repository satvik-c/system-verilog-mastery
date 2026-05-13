interface bus_if;
    
    logic [15:0] addr;
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic write_en;
    logic read_en;
    logic ready;

    modport master (
        input rdata, ready,
        output addr, wdata, write_en, read_en
    );

    modport slave (
        input addr, wdata, write_en, read_en,
        output rdata, ready
    );

endinterface
