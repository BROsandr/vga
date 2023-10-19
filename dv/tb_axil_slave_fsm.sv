// For explanations see verification plan.
timeunit      1ns;
timeprecision 1ps;

`include "errors/vga_scoreboard_error.svh"

module tb_axil_slave_fsm ();

  vga_clk_if         clk_if    ();
  vga_arst_n_if      arst_n_if (
    .clk (clk_if.clk)
  );
  vga_axil_if        axil_if   (
    .clk    (clk_if.clk),
    .arst_n (arst_n_if.arst_n)
  );
  vga_native_if      native_if (.axil_if);

  import vga_axil_pkg::*;
  axil_data_t expected_data[native_addr_t];
  axil_data_t actual_data  [native_addr_t];

  vga_axil_slave_fsm axil_slave_fsm (
    .axil_if,
    .native_if
  );

  task automatic handle_write2slave();
    @(posedge clk_if.clk);

    if (native_if.write_en) begin
      actual_data[native_if.addr_write] = native_if.data2native;

      $display($sformatf("OK. Time == %f. Slave. Write. Addr == 0x%x, Data == 0x%x",
          $time, native_if.addr_write, native_if.data2native));
    end
  endtask

  task automatic handle_read2slave();
    @(posedge clk_if.clk);

    if (native_if.read_en_sync) begin
      native_if.data2axil <= actual_data[native_if.addr_read];

      $display($sformatf("OK. Time == %f. Slave. Read. Addr == 0x%x, Data == 0x%x",
          $time, native_if.addr_read, actual_data[native_if.addr_read]));
    end
  endtask

  initial begin : slave
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

  task automatic reset(time duration = 100ns);
    $display($sformatf("reseted. Time == %f", $time));
    clear();
    arst_n_if.arst_n <= 1'b0;
    axil_if.reset_master();
    #duration;
    arst_n_if.arst_n <= 1'b1;
  endtask

  function automatic void check_addr_data(axil_addr_t addr, axil_data_t actual_data);
    if (!expected_data.exists(addr)) begin
      vga_scoreboard_error scoreboard_error = new(vga_scoreboard_error::ScbErrorUnexpectedAddr);
      $fatal(1, scoreboard_error.print_log(.expected($sformatf("0x%x", addr))));
    end
    if (expected_data[addr] == actual_data) begin
      $display($sformatf("OK. Time == %f", $time));
    end else begin
      vga_scoreboard_error scoreboard_error = new(vga_scoreboard_error::ScbErrorDataMismatch);
      $fatal(1, scoreboard_error.print_log(.expected($sformatf("0x%x", expected_data[addr])),
                                           .actual  ($sformatf("0x%x", actual_data       ))));
    end
  endfunction

  function automatic void clear();
    expected_data.delete();
    actual_data  .delete();
  endfunction

  task automatic continuous_test(int unsigned iteration = 10);
    int unsigned word_counter = 0;

    $display("continuous_test started");

    $display("write started");
    repeat (iteration) begin
      axil_data_t data;
      axil_addr_t addr;
      axil_resp_e response;

      addr          = axil_addr_t'(word_counter);
      data          = axil_data_t'(word_counter);
      word_counter += AXIL_ADDR_WIDTH / $size(byte);

      axil_if.write(.addr(addr), .data(data), .resp(response));
      check_resp(.expected(OKAY), .actual(response));

      // store packet into the expected map
      expected_data[addr] = data;
    end

    word_counter = 0;

    $display("read started");
    repeat (iteration) begin
      axil_data_t data;
      axil_addr_t addr;
      axil_resp_e response;

      addr          = axil_addr_t'(word_counter);
      word_counter += AXIL_ADDR_WIDTH / $size(byte);

      axil_if.read(.addr(addr), .resp(response), .data(data));
      check_resp(.expected(OKAY), .actual(response));

      // scoreboarding(check result)
      check_addr_data(.addr(addr), .actual_data(data));
    end

    $display("continuous_test ended");
  endtask

  import vga_axil_pkg::AXIL_WIDTH_OFFSET;

  task automatic parallel_test();
    $display("parallel_test started");

    fork
      begin : write
        axil_data_t data;
        axil_addr_t addr;
        axil_resp_e response;

        if (!std::randomize(addr) with {addr[AXIL_WIDTH_OFFSET-1:0] == '0;}) begin
          $error("randomization failed");
        end
        if (!std::randomize(data)) $error("randomization failed");

        axil_if.write(.addr(addr), .data(data), .resp(response));
        check_resp(.expected(OKAY), .actual(response));
      end

      begin : read
        axil_data_t data;
        axil_addr_t addr;
        axil_resp_e response;

        if (!std::randomize(addr) with {addr[AXIL_WIDTH_OFFSET-1:0] == '0;}) begin
          $error("randomization failed");
        end
        if (!std::randomize(data)) $error("randomization failed");

        expected_data[addr]                   = data;
        actual_data  [axil2native_addr(addr)] = data;

        axil_if.read(.addr(addr), .resp(response), .data(data));
        check_resp(.expected(OKAY), .actual(response));

        // scoreboarding(check result)
        check_addr_data(.addr(addr), .actual_data(data));
      end
    join

    $display("parallel_test ended");
  endtask

  task automatic random_test(int unsigned iteration = 10);
    axil_addr_t address_pool[$];

    $display("random_test started");

    fork
      begin : write
        repeat (iteration) begin
          axil_data_t data;
          axil_addr_t addr;
          axil_resp_e response;

          int unsigned delay;
          if (!std::randomize(delay) with {delay inside {[0:10]};}) $error("randomization failed");
          repeat (delay) @(posedge axil_if.clk);

          if (!std::randomize(addr) with {addr[AXIL_WIDTH_OFFSET-1:0] == '0;}) begin
            $error("randomization failed");
          end
          if (!std::randomize(data)) $error("randomization failed");

          axil_if.write(.addr(addr), .data(data), .resp(response));
          check_resp(.expected(OKAY), .actual(response));

          // store packet into the expected map
          expected_data[addr] = data;
          address_pool.push_back(addr);
        end
      end

      begin : read
        repeat (iteration) begin
          axil_data_t data;
          axil_addr_t addr;
          axil_resp_e response;

          int unsigned delay;
          if (!std::randomize(delay) with {delay inside {[0:10]};}) begin
            $error("randomization failed");
          end
          repeat (delay) @(posedge axil_if.clk);

          wait(address_pool.size() != 0);
          address_pool.shuffle();

          addr = address_pool[0];

          axil_if.read(.addr(addr), .resp(response), .data(data));
          check_resp(.expected(OKAY), .actual(response));

          // scoreboarding(check result)
          check_addr_data(.addr(addr), .actual_data(data));
        end
      end
    join

    $display("random_test ended");
  endtask

  task automatic reset_test(int unsigned iteration = 10);
    time               duration;
    const int unsigned min_duration = 50ns;
    const int unsigned max_duration = 100ns;
    if (!std::randomize(duration) with {duration inside {[min_duration:max_duration]};}) begin
      $error("randomization failed");
    end

    $display("reset_test started");

    fork begin
      fork
        begin : process
          random_test();
          $warning("Normal flow.");
        end

        begin : reset_block
          time               delay;
          const int unsigned min_delay = 500ns;
          const int unsigned max_delay = 1000ns;
          if (!std::randomize(delay) with {delay inside {[min_delay:max_delay]};}) begin
            $error("randomization failed");
          end

          #delay;
        end
      join_any
      disable fork;
    end join

    reset(duration);

    random_test();

    $display("reset_test ended");
  endtask

  initial begin : master
    // Set up environment
    clk_if.start_clk();
    reset(100ns);
    continuous_test();
    clear();
    parallel_test();
    clear();
    random_test();
    clear();
    reset_test();

    $finish();
  end
endmodule
