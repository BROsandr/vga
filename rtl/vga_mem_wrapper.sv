module vga_mem_wrapper(
  input clk_i, arstn_i,
  
  output VGA_HS_o, VGA_VS_o,
  input  color_i,
  input [10:0] addr_x_i,
  input [10:0] addr_y_i,
  input        we_i,
  output [11:0] RGB_o,
  output [11:0] LED_o
);
  localparam HSYNC_BITS = 11,
             VSYNC_BITS = 11,
             HD         = 1280,
             VD         = 1024;

  localparam logic [11:0] WHITE = '1; 
  localparam logic [11:0] BLACK = '0; 

  logic [11:0] color_ff;
  logic [HSYNC_BITS-1:0] hcount;
  logic [VSYNC_BITS-1:0] vcount;
  
  logic                  pixel_enable;
  
    parameter HF = 48;                      // Front porch
    parameter HR = 112;                     // Retrace/Sync
    parameter HB = 248;                     // Back Porch
    parameter HMAX = HD + HF + HR + HB - 1; // MAX counter value
    
    parameter VF = 1;
    parameter VR = 3;
    parameter VB = 38;
    parameter VMAX = VD + VF + VR + VB - 1;

  vga #(
    .HSYNC_BITS( HSYNC_BITS ),
    .VSYNC_BITS( VSYNC_BITS ),
    .HD( HD ),
    .VD( VD )
  ) vga(
    .clk( clk_i ), .arstn( arstn_i ),
    
    .SW( color_ff ),
    
    .VGA_HS( VGA_HS_o ), .VGA_VS( VGA_VS_o ),
    .RGB( RGB_o ),
    .LED( LED_o ),
    
    .hcount( hcount ),
    .vcount( vcount ),
    .pixel_enable( pixel_enable )
  );

  logic video_buffer_ff[VD * HD];
  
  logic video_buffer_pixel_ff;
  
  always_ff @( posedge clk_i ) 
    if( we_i )  video_buffer_ff[addr_x_i * HD + addr_y_i] <= color_i;
  
  logic [VSYNC_BITS-1:0] vcount_buff;
  logic [HSYNC_BITS-1:0] hcount_buff ;
    
  always_ff @( posedge clk_i ) begin
    vcount_buff <= vcount - (VR+VB);
    hcount_buff <= hcount - (HR+HB);
  end
    
  always_ff @( posedge clk_i )
    video_buffer_pixel_ff <= video_buffer_ff[( vcount_buff ) * HD + ( hcount_buff )];
//    video_buffer_pixel_ff <= video_buffer_ff[( vcount ) * HD + ( hcount )];
  
  always_ff @( posedge clk_i )
    color_ff <= { 12{video_buffer_pixel_ff} };

endmodule