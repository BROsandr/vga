module vga_top(
  input clk_i, arstn_i,
  
  output VGA_HS_o, VGA_VS_o,
  input [1:0]  color_i,
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
  enum bit [1:0] {
    BLACK,
    WHITE,
    BLUE,
    GREEN
  } color_type;

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
  );

endmodule