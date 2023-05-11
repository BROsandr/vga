module vga_top(
  input clk, arstn,
  
  output VGA_HS, VGA_VS,
  output [11:0] RGB,
  output [11:0] LED
);
  localparam HSYNC_BITS = 11,
             VSYNC_BITS = 11,
             HD         = 1280,
             VD         = 1024;

  localparam logic [11:0] WHITE = '1; 
  localparam logic [11:0] BLACK = '0; 

  logic [11:0] SW;
  logic [HSYNC_BITS-1:0] hcount;
  logic [VSYNC_BITS-1:0] vcount;

  vga #(
    .HSYNC_BITS( HSYNC_BITS ),
    .VSYNC_BITS( VSYNC_BITS ),
    .HD( HD ),
    .VD( VD )
  ) vga(
    .clk( clk ), .arstn( arstn ),
    
    .SW( SW ),
    
    .VGA_HS( VGA_HS ), .VGA_VS( VGA_VS ),
    .RGB( RGB ),
    .LED( LED ),
    
    .hcount( hcount ),
    .vcount( vcount )
  );

  logic video_buffer[VD][HD];

  always_ff @( posedge clk )
    if( vcount == 1000 ) SW <= WHITE;
    else                 SW <= BLACK;


endmodule