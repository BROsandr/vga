module vga
#(
    parameter HSYNC_BITS = 11,
    parameter VSYNC_BITS = 11,
    
    parameter HD = 1280,                    // Display area
    parameter HF = 48,                      // Front porch
    parameter HR = 112,                     // Retrace/Sync
    parameter HB = 248,                     // Back Porch
    parameter HMAX = HD + HF + HR + HB - 1, // MAX counter value
    
    parameter VD = 1024,
    parameter VF = 1,
    parameter VR = 3,
    parameter VB = 38,
    parameter VMAX = VD + VF + VR + VB - 1
) (
    input  logic                  clk_i, 
    input  logic                  arstn_i,
    
    input  logic [11:0]           sw_i,
    
    output logic                  vga_hs_o, 
    output logic                  vga_vs_o,
    output logic [11:0]           rgb_o,
    output logic [11:0]           led_o,

    // Display timing counters
    output logic [HSYNC_BITS-1:0] hcount_o,
    output logic [VSYNC_BITS-1:0] vcount_o,
    output logic                  pixel_enable_o

);
  
  // Sync signal registers, vertical counter enable register, and pixel enable register
  logic hsync_ff;
  logic hsync_en;
  logic hsync_next;

  logic vsync_ff;
  logic vsync_en;
  logic vsync_next;

  logic [HSYNC_BITS-1:0] hcount_ff;
  logic hcount_en;
  logic [HSYNC_BITS-1:0] hcount_next;

  logic [VSYNC_BITS-1:0] vcount_ff;
  logic vcount_en;
  logic [VSYNC_BITS-1:0] vcount_next;

  logic pixel_enable_ff;
  logic pixel_enable_en;
  logic pixel_enable_next;
  
  // Switch state buffer registers
  logic [11:0] switches_ff;
  
  // Horizontal counter
  assign hcount_en   = hcount_ff < HMAX;
  assign hcount_next = hcount_ff + 1;
  always_ff @ ( posedge clk_i or negedge arstn_i )
    if      ( ~arstn_i  ) hcount_ff <= '0;
    else if ( hcount_en ) hcount_ff <= hcount_next;
    else                  hcount_ff <= '0;
  
  // Vertical counter
  assign vcount_en   = ( hcount_ff == HMAX );
  assign vcount_next = ( vcount_ff < VMAX ) ? ( vcount_ff + 1 ) : ( '0 );
  always_ff @( posedge clk_i or negedge arstn_i ) 
    if      ( ~arstn_i    ) vcount_ff <= '0;
    else if ( vcount_en   ) vcount_ff <= vcount_next;
  
  // Horizontal and Vertical sync signal generator
  assign hsync_next = (hcount_ff < HR) ? 1'b1 : 1'b0;
  assign vsync_next = (vcount_ff < VR) ? 1'b1 : 1'b0;
  always_ff @ ( posedge clk_i or negedge arstn_i )
    if( ~arstn_i ) begin
      hsync_ff <= '0;
      vsync_ff <= '0;
    end else begin
      hsync_ff <= hsync_next;
      vsync_ff <= vsync_next;
    end
  
  // Assigning register values to outputs
  assign vga_hs_o = hsync_ff;
  assign vga_vs_o = vsync_ff;
  
  assign pixel_enable_en = hcount_ff >= (HR+HB) && hcount_ff < (HR+HB+HD) && vcount_ff >= (VR+VB) && vcount_ff < (VR+VB+VD);
  assign pixel_enable_o  = pixel_enable_ff;
  always_ff @( posedge clk_i or negedge arstn_i ) 
    if      ( ~arstn_i        ) pixel_enable_ff <= '0;
    else if ( pixel_enable_en ) pixel_enable_ff <= 1'b1;
    else                        pixel_enable_ff <= '0;
  
  // Buffering switch inputs
  always_ff @( posedge clk_i ) switches_ff <= sw_i;
  
  // Assigning the current switch state to both view which switches are on and output to VGA RGB DAC
  assign led_o = switches_ff;
  assign rgb_o = ( pixel_enable_o ) ? ( switches_ff ) : ( '0 );

  assign hcount_o = hcount_ff;
  assign vcount_o = vcount_ff;
endmodule