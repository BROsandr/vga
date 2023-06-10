module vga_res_mem
  import vga_pkg::*;
(
  input  logic clk_i,
  input  logic arstn_i,

  input  vga_resolution_e resolution_i,
  input  logic        req_i,

  vga_timing_io timing_if,

  output logic [7:0]                 freq_int_o,
  output logic [7:0]                 freq_frac_o,

  output logic                       valid_o
);

  vga_timing_io timing_if_ff();
  vga_timing_io timing_if_next();
  
  logic [7:0] freq_int_ff;
  logic [7:0] freq_int_next;
  
  logic [7:0] freq_frac_ff;
  logic [7:0] freq_frac_next;

  logic                       valid_ff;
  logic                       valid_next;

  typedef struct {
    logic [VGA_MAX_H_WIDTH-1:0] hd;
    logic [VGA_MAX_H_WIDTH-1:0] hf;
    logic [VGA_MAX_H_WIDTH-1:0] hr;
    logic [VGA_MAX_H_WIDTH-1:0] hb;

    logic [VGA_MAX_V_WIDTH-1:0] vd;
    logic [VGA_MAX_V_WIDTH-1:0] vf;
    logic [VGA_MAX_V_WIDTH-1:0] vr;
    logic [VGA_MAX_V_WIDTH-1:0] vb;

    logic [7:0]                 freq_int;
    logic [7:0]                 freq_frac;
  } resolution_s;
  resolution_s resolution_ff[VGA_RES_NUM];

  initial begin
    resolution_s resolution_local_ff;

    resolution_local_ff.hd = VGA_MAX_H_WIDTH'('d800);
    resolution_local_ff.hf = VGA_MAX_H_WIDTH'('d40);
    resolution_local_ff.hr = VGA_MAX_H_WIDTH'('d128);
    resolution_local_ff.hb = VGA_MAX_H_WIDTH'('d88);

    resolution_local_ff.vd = VGA_MAX_V_WIDTH'('d600);
    resolution_local_ff.vf = VGA_MAX_V_WIDTH'('d1);
    resolution_local_ff.vr = VGA_MAX_V_WIDTH'('d4);
    resolution_local_ff.vb = VGA_MAX_V_WIDTH'('d23);

    resolution_local_ff.freq_int = 8'd40;
    resolution_local_ff.freq_frac = 8'd0;

    resolution_ff[VGA_RES_800_600] = resolution_local_ff;
  end

  assign timing_if_next.hd = resolution_ff[resolution_i].hd;
  assign timing_if_next.hf = resolution_ff[resolution_i].hf;
  assign timing_if_next.hr = resolution_ff[resolution_i].hr;
  assign timing_if_next.hb = resolution_ff[resolution_i].hb; 

  assign timing_if_next.vd = resolution_ff[resolution_i].vd;
  assign timing_if_next.vf = resolution_ff[resolution_i].vf;
  assign timing_if_next.vr = resolution_ff[resolution_i].vr;
  assign timing_if_next.vb = resolution_ff[resolution_i].vb; 

  assign freq_int_next = resolution_ff[resolution_i] .freq_int;
  assign freq_frac_next = resolution_ff[resolution_i].freq_frac; 

  always_ff @( posedge clk_i )
    if( req_i ) begin
      timing_if_ff.hd <= timing_if_next.hd;
      timing_if_ff.hf <= timing_if_next.hf;
      timing_if_ff.hr <= timing_if_next.hr;
      timing_if_ff.hb <= timing_if_next.hb;

      timing_if_ff.vd <= timing_if_next.vd;
      timing_if_ff.vf <= timing_if_next.vf;
      timing_if_ff.vr <= timing_if_next.vr;
      timing_if_ff.vb <= timing_if_next.vb;

      freq_int_ff <= freq_int_next;
      freq_frac_ff <= freq_frac_next;
    end

  assign valid_next = req_i ^ valid_ff;
  always_ff @( posedge clk_i or negedge arstn_i )
    if     ( ~arstn_i ) valid_ff <= '0;
    else if( req_i   ) valid_ff <= valid_next;

  assign timing_if.hd = timing_if_ff.hd;
  assign timing_if.hf = timing_if_ff.hf;
  assign timing_if.hr = timing_if_ff.hr;
  assign timing_if.hb = timing_if_ff.hb;

  assign timing_if.vd = timing_if_ff.vd;
  assign timing_if.vf = timing_if_ff.vf;
  assign timing_if.vr = timing_if_ff.vr;
  assign timing_if.vb = timing_if_ff.vb;

  assign freq_int_o = freq_int_ff;
  assign freq_frac_o = freq_frac_ff;

  assign valid_o = valid_ff;
endmodule