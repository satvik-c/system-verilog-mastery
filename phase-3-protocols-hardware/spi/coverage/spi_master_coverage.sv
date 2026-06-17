class SpiCoverageTracker;
    
    covergroup cg_spi_transactions with function sample(logic [7:0] cmd, logic [7:0] addr, int bytes, logic [7:0] data);

        cp_cmd : coverpoint cmd {
            bins read = {8'h0B};
            bins write = {8'h0A};
        }

        cp_addr : coverpoint addr {
            bins accel_data[] = {[8'h00 : 8'h1F]};
        }

        cp_bytes : coverpoint bytes {
            bins single_hit = {1};
            bins stream = {[2 : 6]};
        }

        cp_data : coverpoint data iff (cmd == 8'h0A) {
            bins zeroes = {8'h00};
            bins ones = {8'hFF};
            bins alt[] = {8'h55, 8'hAA};
        }

        cross_read : cross cp_addr, cp_bytes iff (cmd == 8'h0B);
        cross_write : cross cp_addr, cp_bytes, cp_data iff (cmd == 8'h0A);

    endgroup

    function new();
        cg_spi_transactions = new();
    endfunction
    
    function void sample(logic [7:0] cmd, logic [7:0] addr, int bytes, logic [7:0] data);
        cg_spi_transactions.sample(cmd, addr, bytes, data);
    endfunction

    function void print_report();
        real total_score = cg_spi_transactions.get_inst_coverage();
        
        real cmd_score   = cg_spi_transactions.cp_cmd.get_inst_coverage();
        real addr_score  = cg_spi_transactions.cp_addr.get_inst_coverage();
        real bytes_score = cg_spi_transactions.cp_bytes.get_inst_coverage();
        real data_score  = cg_spi_transactions.cp_data.get_inst_coverage();

        real cross_read = cg_spi_transactions.cross_read.get_inst_coverage();
        real cross_write = cg_spi_transactions.cross_write.get_inst_coverage();
        
        $display("\n=========== COVERAGE REPORT ==========");
        $display("COVERPOINT SCORES:");
        $display("  cmd:   %0.2f%%", cmd_score);
        $display("  addr:  %0.2f%%", addr_score);
        $display("  bytes: %0.2f%%", bytes_score);
        $display("  data:  %0.2f%%", data_score);
        $display("CROSS COVERAGE SCORES:");
        $display("  Reads:  %0.2f%%", cross_read);
        $display("  Writes: %0.2f%%", cross_write);
        $display("OVERALL COVERAGE SCORE: %0.2f%%", total_score);
        $display("====================================================\n");

        // Read and write cross coverage is capped at 98.44% due to
        // intentional boundary clamps of streams starting at address 0x1F.
    endfunction

endclass