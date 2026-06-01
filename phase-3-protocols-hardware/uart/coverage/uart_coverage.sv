class UartCoverageTracker;

    covergroup dirty_cg with function sample(logic [7:0] d, int b, logic p, logic s);

        cp_data: coverpoint d {
            bins data[] = {[0:255]};
        }

        cp_baud: coverpoint b {
            bins offsets[] = {-4, 0, 4};
        }

        cp_parity: coverpoint p;
        cp_stop: coverpoint s;

        cross_all: cross cp_data, cp_baud, cp_parity, cp_stop;

    endgroup

    function new();
        dirty_cg = new();
    endfunction

    function void sample(logic [7:0] d, int b, logic p, logic s);
        dirty_cg.sample(d, b, p, s);
    endfunction

    function void print_report();
        real cov_score = dirty_cg.get_inst_coverage(); 

        $display("\n=========== CROSS COVERAGE REPORT ==========");
        $display("CROSS COVERAGE SCORE: %0.2f%%", cov_score);

        if (cov_score < 100.0) begin
            $display("WARNING: There are cross coverage holes.");
        end else begin
            $display("SUCCESS: 100%% cross coverage Achieved.");
        end
        $display("====================================================\n");
    endfunction

endclass
