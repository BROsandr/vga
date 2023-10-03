class vga_scoreboard_error;
  parameter int unsigned SCB_NUM_OF_ERRORS = 3;
  parameter type scoreboard_error_e = enum bit [$clog2(SCB_NUM_OF_ERRORS)-1:0] {
    ScbErrorAddrMismatch,
    ScbErrorDataMismatch,
    ScbErrorRespMismatch
  };
  scoreboard_error_e error;

  function new(scoreboard_error_e error);
    this.error = error;
  endfunction

  function string print_log(string expected, string actual);
    unique case (error)
      ScbErrorAddrMismatch: begin
        return $sformatf(
            "ERROR. TIME == %f. Address mismatch. Expected address == %s, actual address == %s",
            $time, expected, actual);
      end
      ScbErrorDataMismatch: begin
        return $sformatf("ERROR. TIME == %f. Data mismatch. Expected data == %s, actual data == %s",
            $time, expected, actual);
      end
      ScbErrorRespMismatch: begin
        return $sformatf("ERROR. TIME == %f. Resp mismatch. Expected Resp == %s, actual Resp == %s",
            $time, expected, actual);
      end
    endcase
  endfunction
endclass
