module vga_res_mem
  import vga_pkg::*
(
  input  logic clk_i,
  input  logic arstn_i,

  input  resolution_t resolution_i,
  input  logic        req_i,

  output logic [VGA_MAX_H_WIDTH-1:0] hd_o,
  output logic [VGA_MAX_H_WIDTH-1:0] hf_o,
  output logic [VGA_MAX_H_WIDTH-1:0] hr_o,
  output logic [VGA_MAX_H_WIDTH-1:0] hb_o,
         
  output logic [VGA_MAX_V_WIDTH-1:0] vd_o,
  output logic [VGA_MAX_V_WIDTH-1:0] vf_o,
  output logic [VGA_MAX_V_WIDTH-1:0] vr_o,
  output logic [VGA_MAX_V_WIDTH-1:0] vb_o,

  output logic [7:0]                 freq_int_o,
  output logic [7:0]                 freq_frac_o,

  output logic                       valid_o
);

  logic [VGA_MAX_H_WIDTH-1:0] hd_ff;
  logic [VGA_MAX_H_WIDTH-1:0] hd_next;
  logic [VGA_MAX_H_WIDTH-1:0] hf_ff;
  logic [VGA_MAX_H_WIDTH-1:0] hf_next;
  logic [VGA_MAX_H_WIDTH-1:0] hr_ff;
  logic [VGA_MAX_H_WIDTH-1:0] hr_next;
  logic [VGA_MAX_H_WIDTH-1:0] hb_ff;
  logic [VGA_MAX_H_WIDTH-1:0] hb_next;
         
  logic [VGA_MAX_V_WIDTH-1:0] vd_ff;
  logic [VGA_MAX_V_WIDTH-1:0] vd_next;
  logic [VGA_MAX_V_WIDTH-1:0] vf_ff;
  logic [VGA_MAX_V_WIDTH-1:0] vf_next;
  logic [VGA_MAX_V_WIDTH-1:0] vr_ff;
  logic [VGA_MAX_V_WIDTH-1:0] vr_next;
  logic [VGA_MAX_V_WIDTH-1:0] vb_ff;
  logic [VGA_MAX_V_WIDTH-1:0] vb_next;

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
  } resulution_s
  resolution_s resolution_ff[VGA_RES_NUM];

  initial begin
    resolution_s resolution_local_ff;

    resolution_local_ff.hd <= VGA_MAX_H_WIDTH'd800;
    resolution_local_ff.hf <= VGA_MAX_H_WIDTH'd40;
    resolution_local_ff.hr <= VGA_MAX_H_WIDTH'd128;
    resolution_local_ff.hb <= VGA_MAX_H_WIDTH'd88;

    resolution_local_ff.vd <= VGA_MAX_V_WIDTH'd600;
    resolution_local_ff.vf <= VGA_MAX_V_WIDTH'd1;
    resolution_local_ff.vr <= VGA_MAX_V_WIDTH'd4;
    resolution_local_ff.vb <= VGA_MAX_V_WIDTH'd23;

    resolution_local_ff.freq_int <= 8'd40;
    resolution_local_ff.freq_frac <= 8'd0;

    resulution_ff[VGA_RES_800_600] <= resolution_local_ff;
  end

  assign hd_next = resolution_ff.hd[resolution_i];
  assign hf_next = resolution_ff.hf[resolution_i];
  assign hr_next = resolution_ff.hr[resolution_i];
  assign hb_next = resolution_ff.hb[resolution_i]; 

  assign vd_next = resolution_ff.vd[resolution_i];
  assign vf_next = resolution_ff.vf[resolution_i];
  assign vr_next = resolution_ff.vr[resolution_i];
  assign vb_next = resolution_ff.vb[resolution_i]; 

  assign freq_int_next = resolution_ff.freq_int[resolution_i];
  assign freq_frac_next = resolution_ff.freq_frac[resolution_i]; 

  always_ff @( posedge clk_i )
    if( req_i ) begin
      hd_ff <= hd_next;
      hf_ff <= hf_next;
      hr_ff <= hr_next;
      hb_ff <= hb_next;

      vd_ff <= vd_next;
      vf_ff <= vf_next;
      vr_ff <= vr_next;
      vb_ff <= vb_next;

      freq_int_ff <= freq_int_next;
      freq_frac_ff <= freq_frac_next;
    end

  assign valid_next = req_i ^ valid_ff;
  always_ff @( posedge clk_i or negedge arstn_i )
    if     ( ~arstn_i ) valid_ff <= '0;
    else if( req_i   ) valid_ff <= valid_next;

  assign hd_o = hd_ff;
  assign hf_o = hf_ff;
  assign hr_o = hr_ff;
  assign hb_o = hb_ff;

  assign vd_o = vd_ff;
  assign vf_o = vf_ff;
  assign vr_o = vr_ff;
  assign vb_o = vb_ff;

  assign freq_int_o = freq_int_ff;
  assign freq_frac_o = freq_frac_ff;
endmodule