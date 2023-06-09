module vga
  import vga_pkg::*;
(
  input  logic                       clk_i, 
  input  logic                       arstn_i,
  
  input  logic [11:0]                sw_i,
  
  output logic                       vga_hs_o, 
  output logic                       vga_vs_o,
  output logic [11:0]                rgb_o,
  output logic [11:0]                led_o,

  input  logic [VGA_MAX_H_WIDTH-1:0] hd_i, // Display area
  input  logic [VGA_MAX_H_WIDTH-1:0] hf_i, // Front porch
  input  logic [VGA_MAX_H_WIDTH-1:0] hr_i, // Retrace/Sync
  input  logic [VGA_MAX_H_WIDTH-1:0] hb_i, // Back Porch    
  
  input  logic [VGA_MAX_V_WIDTH-1:0] vd_i,
  input  logic [VGA_MAX_V_WIDTH-1:0] vf_i,
  input  logic [VGA_MAX_V_WIDTH-1:0] vr_i,
  input  logic [VGA_MAX_V_WIDTH-1:0] vb_i,
  
  input  logic                       we_i,

  // Display timing counters
  output logic [VGA_MAX_H_WIDTH-1:0] hcount_o,
  output logic [VGA_MAX_V_WIDTH-1:0] vcount_o,
  output logic                       pixel_enable_o

);
  logic  [VGA_MAX_H_WIDTH-1:0] hmax_ff;
  logic  [VGA_MAX_H_WIDTH-1:0] hmax_next;

  logic  [VGA_MAX_V_WIDTH-1:0] vmax_ff;
  logic  [VGA_MAX_V_WIDTH-1:0] vmax_next;

  assign hmax_next = hd_i + hf_i + hr_i + hb_i - 1; // MAX counter value
  assign vmax_next = vd_i + vf_i + vr_i + vb_i - 1;
  
  // Sync signal registers, vertical counter enable register, and pixel enable register
  logic hsync_ff;
  logic hsync_en;
  logic hsync_next;

  logic vsync_ff;
  logic vsync_en;
  logic vsync_next;

  logic [VGA_MAX_H_WIDTH-1:0] hcount_ff;
  logic hcount_en;
  logic [VGA_MAX_H_WIDTH-1:0] hcount_next;

  logic [VGA_MAX_V_WIDTH-1:0] vcount_ff;
  logic vcount_en;
  logic [VGA_MAX_V_WIDTH-1:0] vcount_next;

  logic pixel_enable_ff;
  logic pixel_enable_en;
  logic pixel_enable_next;

  logic [VGA_MAX_H_WIDTH-1:0] hd_ff; // Display area
  logic [VGA_MAX_H_WIDTH-1:0] hf_ff; // Front porch
  logic [VGA_MAX_H_WIDTH-1:0] hr_ff; // Retrace/Sync
  logic [VGA_MAX_H_WIDTH-1:0] hb_ff; // Back Porch    
  
  logic [VGA_MAX_V_WIDTH-1:0] vd_ff;
  logic [VGA_MAX_V_WIDTH-1:0] vf_ff;
  logic [VGA_MAX_V_WIDTH-1:0] vr_ff;
  logic [VGA_MAX_V_WIDTH-1:0] vb_ff;
  
  // Switch state buffer registers
  logic [11:0] switches_ff;

  always_ff @ ( posedge clk_i or negedge arstn_i )
    if          ( ~arstn_i ) begin
      hd_ff <= '0;
      hf_ff <= '0;
      hr_ff <= '0;
      hb_ff <= '0;

      vd_ff <= '0;
      vf_ff <= '0;
      vr_ff <= '0;
      vb_ff <= '0;

      hmax_ff <= '0;
      vmax_ff <= '0;
    end else if ( we_i     ) begin
      hd_ff <= hd_i;
      hf_ff <= hf_i;
      hr_ff <= hr_i;
      hb_ff <= hb_i;

      vd_ff <= vd_i;
      vf_ff <= vf_i;
      vr_ff <= vr_i;
      vb_ff <= vb_i;

      hmax_ff <= hmax_next;
      vmax_ff <= vmax_next;
    end
  
  // Horizontal counter
  assign hcount_en   = hcount_ff < hmax_ff;
  assign hcount_next = hcount_ff + 1;
  always_ff @ ( posedge clk_i or negedge arstn_i )
    if      ( ~arstn_i  ) hcount_ff <= '0;
    else if ( hcount_en ) hcount_ff <= hcount_next;
    else                  hcount_ff <= '0;
  
  // Vertical counter
  assign vcount_en   = ( hcount_ff == hmax_ff );
  assign vcount_next = ( vcount_ff < vmax_ff ) ? ( vcount_ff + 1 ) : ( '0 );
  always_ff @( posedge clk_i or negedge arstn_i ) 
    if      ( ~arstn_i    ) vcount_ff <= '0;
    else if ( vcount_en   ) vcount_ff <= vcount_next;
  
  // Horizontal and Vertical sync signal generator
  assign hsync_next = (hcount_ff < hr_ff) ? 1'b1 : 1'b0;
  assign vsync_next = (vcount_ff < vr_ff) ? 1'b1 : 1'b0;
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
  
  assign pixel_enable_en = hcount_ff >= (hr_ff+hb_ff) && hcount_ff < (hr_ff+hb_ff+hd_ff) && vcount_ff >= (vr_ff+vb_ff) && vcount_ff < (vr_ff+vb_ff+vd_ff);
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