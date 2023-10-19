// Contains all scoreboard errors which can be reported by a testbench.

class vga_scoreboard_error;

  // List of all scoreboard errors.
  localparam int unsigned SCB_NUM_OF_ERRORS = 3;
  typedef enum bit [$clog2(SCB_NUM_OF_ERRORS)-1:0] {
    ScbErrorAddrMismatch,
    ScbErrorDataMismatch,
    ScbErrorRespMismatch,
    ScbErrorUnexpectedAddr
  } scoreboard_error_e;
  scoreboard_error_e error;

  function new(scoreboard_error_e error);
    this.error = error;
  endfunction

  function string print_log(string expected = "", string actual = "");
    unique case (error)
      ScbErrorAddrMismatch: begin
        return $sformatf(
            "Address mismatch. Expected address == %s, actual address == %s",
            expected, actual);
      end
      ScbErrorDataMismatch: begin
        return $sformatf("Data mismatch. Expected data == %s, actual data == %s",
            expected, actual);
      end
      ScbErrorRespMismatch: begin
        return $sformatf("Resp mismatch. Expected Resp == %s, actual Resp == %s",
            expected, actual);
      end
      ScbErrorUnexpectedAddr: begin
        return $sformatf("Unexpected address. Expected address == %s",
            expected);
      end
    endcase
  endfunction
endclass
