module vga_top
  import vga_pkg::*;
(
  input clk_i, arstn_i,
  
  output VGA_HS_o, VGA_VS_o,
  input [1:0]  color_i,
  input [10:0] addr_x_i,
  input [10:0] addr_y_i,
  input        we_i,
  output [11:0] RGB_o,
  output [11:0] LED_o,
  
  input  [3:0]  sw
);
  enum bit [1:0] {
    BLACK,
    WHITE,
    BLUE,
    GREEN
  } color_type;

  logic [11:0] color_ff;
  logic [VGA_MAX_H_WIDTH-1:0] hcount;
  logic [VGA_MAX_V_WIDTH-1:0] vcount;
  
  logic                  pixel_enable;

  vga_timing_io timing_if();

  vga vga(
    .clk_i  ( clk_i   ), 
    .arstn_i( arstn_i ),
    
    .sw_i( color_ff ),
    
    .vga_hs_o( VGA_HS_o ), 
    .vga_vs_o( VGA_VS_o ),
    .rgb_o( RGB_o ),
    .led_o( LED_o ),
    
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
    .clk_i( clk_i ),
    .arstn_i( arstn_i ),

    .resolution_i( sw[2] ),
    .req_i( 1'b1 ),

    .timing_if( timing_if ),

    .freq_int_o( ),
    .freq_frac_o( ),

    .valid_o( )
  );

  logic [1:0] video_buffer_ff[VGA_MAX_V * VGA_MAX_H];
  
  logic [1:0] video_buffer_pixel_ff;
  
  always_ff @( posedge clk_i ) 
    if( we_i )  video_buffer_ff[addr_x_i * VGA_MAX_H + addr_y_i] <= color_i;
  
  logic [VGA_MAX_V_WIDTH-1:0] vcount_buff;
  logic [VGA_MAX_H_WIDTH-1:0] hcount_buff ;
    
  always_ff @( posedge clk_i ) begin
    vcount_buff <= vcount - (timing_if.vr+timing_if.vb);
    hcount_buff <= hcount - (timing_if.hr+timing_if.hb);
  end
    
  always_ff @( posedge clk_i )
    video_buffer_pixel_ff <= video_buffer_ff[( vcount_buff ) * VGA_MAX_H + ( hcount_buff )];
//    video_buffer_pixel_ff <= video_buffer_ff[( vcount ) * HD + ( hcount )];
  
  always_ff @( posedge clk_i )
    case( video_buffer_pixel_ff )
      BLACK: color_ff <= { 12{1'b0} };
      WHITE: color_ff <= { 12{1'b1} };
      BLUE : color_ff <= { { 4{1'b1} }, { 8{1'b0} } };
      GREEN: color_ff <= { { 4{1'b0} }, { 4{1'b1} }, { 4{1'b0} } };
    endcase


endmodule