`include "./common/vga_scoreboard_error.svh"

module tb_axil_fsm ();

  vga_clk_if         clk_if();
  vga_arst_n_if      arst_n_if(clk_if.clk);
  vga_axil_if        axil_if(clk_if.clk, arst_n_if.arst_n);

  import vga_axil_pkg::*;
  axil_data_t   expected_data;
  axil_addr_t   expected_axil_addr;
  native_addr_t expected_native_addr;
  assign        expected_native_addr = axil2native_addr(expected_axil_addr);

  axil_data_t   data2axil;
  assign        data2axil = expected_data;

  native_addr_t addr_write;
  native_addr_t addr_read;
  axil_data_t   data2native;
  logic         read_en;
  logic         write_en;

  vga_axil_slave_fsm axil_slave_fsm(
    .axil_if,
    .data_i       (data2axil),
    .addr_write_o (addr_write),
    .addr_read_o  (addr_read),
    .data_o       (data2native),
    .read_en_o    (read_en),
    .write_en_o   (write_en)
  );

  task automatic handle_write2slave();
    @(posedge clk_if.clk);

    if (write_en) begin
      if (addr_write != expected_native_addr) begin
        vga_scoreboard_error scoreboard_error = new(vga_scoreboard_error::ScbErrorAddrMismatch);
        $fatal(1, scoreboard_error.print_log(.expected($sformatf("0x%x", expected_native_addr)),
                                              .actual  ($sformatf("0x%x", addr_write))));
      end

      if (data2native != expected_data) begin
        vga_scoreboard_error scoreboard_error = new(vga_scoreboard_error::ScbErrorAddrMismatch);
        $fatal(1, scoreboard_error.print_log(.expected($sformatf("0x%x", expected_data)),
                                             .actual  ($sformatf("0x%x", data2native))));
      end

      $display($sformatf("OK. Time == %f. Slave. Write", $time));
    end
  endtask

  task automatic handle_read2slave();
    @(posedge clk_if.clk);

    if (read_en) begin
      if (addr_read != expected_native_addr) begin
        vga_scoreboard_error scoreboard_error = new(vga_scoreboard_error::ScbErrorAddrMismatch);
        $fatal(1, scoreboard_error.print_log(.expected($sformatf("0x%x", expected_native_addr)),
                                             .actual  ($sformatf("0x%x", addr_read))));
      end

      $display($sformatf("OK. Time == %f. Slave. Read", $time));
    end
  endtask

  initial begin : slave
    axil_if.reset_slave();
    fork begin
      forever begin
        wait(axil_if.arst_n);
        fork
          forever begin
            handle_write2slave();
          end

          forever begin
            handle_read2slave();
          end

          begin
            wait(!axil_if.arst_n);
            axil_if.reset_slave();
          end
        join_any
        disable fork;
      end
    end join
  end

  function automatic void check_resp(axil_resp_e expected, axil_resp_e actual);
    if (expected != actual) begin
      vga_scoreboard_error scoreboard_error = new(vga_scoreboard_error::ScbErrorRespMismatch);
      $fatal(1, scoreboard_error.print_log(.expected($sformatf("0x%x", expected)),
                                           .actual  ($sformatf("0x%x", actual  ))));
    end
  endfunction

  task automatic reset();
    arst_n_if.arst_n <= 1'b0;
    axil_if.reset_master();
    #100ns;
    arst_n_if.arst_n <= 1'b1;
  endtask

  initial begin : master
    axil_data_t response_data;
    axil_resp_e response;

    // Set up environment
    clk_if.start_clk();
    reset();


    // randomize expected_packet
    expected_axil_addr = $random;
    expected_data      = $random;

    // read-write to dut
    axil_if.write(.addr(expected_axil_addr), .data(expected_data), .resp(response));
    check_resp(.expected(OKAY), .actual(response));

    axil_if.read(.addr(expected_axil_addr), .resp(response), .data(response_data));
    check_resp(.expected(OKAY), .actual(response));

    // scoreboarding(check result)
    if (expected_data == response_data) begin
      $display($sformatf("OK. Time == %f", $time));
    end else begin
      vga_scoreboard_error scoreboard_error = new(vga_scoreboard_error::ScbErrorDataMismatch);
      $fatal(1, scoreboard_error.print_log(.expected($sformatf("0x%x", expected_data)),
                                           .actual  ($sformatf("0x%x", response_data       ))));
    end
  end
endmodule
