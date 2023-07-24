module vga_top
  import vga_pkg::*;
(
  input clk_100m_i,
  input clk_vga_i, 
  input arstn_i,
  
  output VGA_HS_o, VGA_VS_o,
  input [1:0]  color_i,
  input [10:0] addr_x_i,
  input [10:0] addr_y_i,
  input        we_i,
  output       wr_gnt_o,
  output [11:0] RGB_o,
  
  input  logic  sw_i,

  // ddr
  // Inouts

  inout [15:0]                       ddr2_dq,

  inout [1:0]                        ddr2_dqs_n,

  inout [1:0]                        ddr2_dqs_p,

  // Outputs

  output [12:0]                      ddr2_addr,

  output [2:0]                       ddr2_ba,

  output                             ddr2_ras_n,

  output                             ddr2_cas_n,

  output                             ddr2_we_n,

  output [0:0]                       ddr2_ck_p,

  output [0:0]                       ddr2_ck_n,

  output [0:0]                       ddr2_cke,

  output [1:0]                       ddr2_dm,

  output [0:0]                       ddr2_odt
);
  enum bit [1:0] {
    BLACK,
    WHITE,
    BLUE,
    GREEN
  } color_type;

  vga_resolution_e resolution; 
  assign resolution = ( sw_i ) ? ( VGA_RES_800_600 ) : ( VGA_RES_1280_1024 );

  logic [11:0] color_ff;
  logic [VGA_MAX_H_WIDTH-1:0] hcount;
  logic [VGA_MAX_V_WIDTH-1:0] vcount;
  
  logic                  pixel_enable;

  vga_timing_io timing_if();

  assign RGB_o = color_ff;

  vga vga(
    .clk_i  ( clk_vga_i   ), 
    .arstn_i( arstn_i ),
    
    .vga_hs_o( VGA_HS_o ), 
    .vga_vs_o( VGA_VS_o ),
    
    .hd_i( timing_if.hd ),
    .hf_i( timing_if.hf ),
    .hr_i( timing_if.hr ),
    .hb_i( timing_if.hb ),
         
    .vd_i( timing_if.vd ),
    .vf_i( timing_if.vf ),
    .vr_i( timing_if.vr ),
    .vb_i( timing_if.vb ),
    
    .we_i( 1'b1 ),
    
    .hcount_o( hcount ),
    .vcount_o( vcount ),
    .pixel_enable_o( pixel_enable )
  );

  vga_res_mem vga_res_mem(
    .clk_i( clk_vga_i ),
    .arstn_i( arstn_i ),

    .resolution_i( resolution ),
    .req_i( 1'b1 ),

    .timing_if( timing_if ),

    .freq_int_o( ),
    .freq_frac_o( ),

    .valid_o( )
  );

  logic color;

  import vga_ddr_wrapper_pkg::ADDR_WIDTH;
  vga_ddr_wrapper #(
    .DATA_BIT_WIDTH(8                    ),
    .SIZE_BYTE     (VGA_MAX_V * VGA_MAX_H)
  ) vga_ddr_wrapper (

    .clk_100m_i,
    .clk_rd_i(clk_vga_i),
    .clk_wr_i(clk_vga_i),

    .arst_ni(arstn_i),

    .rd_req_i(pixel_enable),
    .wr_req_i(we_i),
    .wr_addr_i(addr_x_i * VGA_MAX_H + addr_y_i),
    .wr_data_i(color_i),

    .rd_data_o(color),
    .wr_gnt_o,
    .rd_gnt_o(),

    // ddr
    .ddr2_dq,

    .ddr2_dqs_n,

    .ddr2_dqs_p,

    // Outputs

    .ddr2_addr,

    .ddr2_ba,

    .ddr2_ras_n,

    .ddr2_cas_n,

    .ddr2_we_n,

    .ddr2_ck_p,

    .ddr2_ck_n,

    .ddr2_cke,

    .ddr2_dm,

    .ddr2_odt
  );
  logic [1:0] video_buffer_ff[VGA_MAX_V * VGA_MAX_H];
  
  always_ff @( posedge clk_vga_i )
    case( color )
      BLACK: color_ff <= { 12{1'b0} };
      WHITE: color_ff <= { 12{1'b1} };
      BLUE : color_ff <= { { 4{1'b1} }, { 8{1'b0} } };
      GREEN: color_ff <= { { 4{1'b0} }, { 4{1'b1} }, { 4{1'b0} } };

      default: color_ff <= { 12{1'b0} };
    endcase


endmodule