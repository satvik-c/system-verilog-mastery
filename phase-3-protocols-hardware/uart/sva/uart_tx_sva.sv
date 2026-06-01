module uart_tx_sva
   import project_pkg::*;
#(
   parameter DATA_BITS = 8,
   parameter PARITY_BITS = 1,
   parameter PARITY_MODE = EVEN,
   parameter STOP_BITS = 1
)(
   input logic clk,
   input logic rst,
   input logic tx_start,
   input logic [DATA_BITS-1:0] tx_data,
   input logic tx_busy,
   input logic tx_out,
   input uart_state_t CS
);

   assert property (@(posedge clk) disable iff(rst)
      ($fell(tx_out) && CS === START) |-> (tx_busy === 1)
   )
   else begin
      $error("tx_busy not high when transmission started");
   end

   assert property (@(posedge clk) disable iff(rst || uart_tb.dirty_send_flag)
      (tx_busy === 0) |-> (tx_out === 1)
   )
   else begin
      $error("tx_out not high in idle state");
   end

   assert property (@(posedge clk) disable iff(rst)
      (CS === STOP) |-> (tx_out === 1)
   )
   else begin
      $error("tx_out not high in stop state");
   end

endmodule
