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
)(
    input clk, arstn,
    
    input [11:0] SW,
    
    output VGA_HS, VGA_VS,
    output [11:0] RGB,
    output [11:0] LED,

    // Display timing counters
    output reg [HSYNC_BITS-1:0] hcount,
    output reg [VSYNC_BITS-1:0] vcount,
    output reg pixel_enable

);
  
  // Switch state buffer registers
  logic [11:0]    switches;
  
  logic [11:0]    rgb_ff;
  logic [11:0]    rgb_next;
  logic           rgb_en;

  logic [11:0]    led_ff;
  logic [11:0]    led_next;
  logic           led_en;

  logic           hsync_ff;
  logic           hsync_next;
  logic           hsync_en;
  
  logic           vsync_ff;
  logic           vsync_next;
  logic           vsync_en;
  
  ////////////////////////////////
  //    HORIZONTAL COUNTER      //
  ////////////////////////////////
  always @ (posedge clk or posedge arstn) begin
      if (!arstn == 1'b1) begin
          hcount <= 0;
      end
      else if (hcount < HMAX) begin
          hcount <= hcount + 1;
      end
      else begin
          hcount <= 0;
      end
  end
  
  ////////////////////////////////
  //     VERTICAL COUNTER       //
  ////////////////////////////////
  always @ (posedge clk or posedge arstn) begin
      if (!arstn == 1'b1) vcount <= 0;
      else begin
          if (hcount == HMAX) begin
              if (vcount < VMAX) vcount <= vcount + 1;
              else vcount <= 0;
          end
      end
  end

  ////////////////////////////////
  // HORIZONTAL & VERTICAL SYNC //
  ////////////////////////////////

  assign hsync_next = (hcount < HR) ? 1'b1 : 1'b0;
  assign vsync_next = (vcount < VR) ? 1'b1 : 1'b0;
  
  // Horizontal and Vertical sync signal generator
  always @ (posedge clk or posedge arstn) begin
      if (!arstn) begin
          hsync_ff <= 1'b0;
          vsync_ff <= 1'b0;
      end
      else begin
          hsync_ff <= hsync_next;
          vsync_ff <= vsync_next;
      end
  end
  
  // Assigning register values to outputs
  assign VGA_HS = hsync_ff;
  assign VGA_VS = vsync;
  
  always @ (posedge clk or posedge arstn) begin
    if (!arstn) pixel_enable <= 1'b0;
    else
      if (hcount >= (HR+HB) && hcount < (HR+HB+HD) && vcount >= (VR+VB) && vcount < (VR+VB+VD))
        pixel_enable <= 1'b1;
      else
        pixel_enable <= 1'b0;
  end
  
  ////////////////////////////////
  //         RGB Signals        //
  ////////////////////////////////

  always @ (posedge clk or posedge arstn) begin
    if (!arstn)
      rgb_ff <= 1'b0;
    else if(rgb_en)
      rgb_ff <= rgb_next;
  end

  assign rgb_next = (pixel_enable) ? switches : 12'b0;
  assign RGB = rgb_ff;

  ////////////////////////////////
  //         LED Signals        //
  ////////////////////////////////

  always @ (posedge clk or neg arstn) begin
    if (!arstn)
      rgb_ff <= 1'b0;
    else if(rgb_en)
      rgb_ff <= rgb_next;
  end
  
  // Assigning the current switch state to both view which switches are on and output to VGA RGB DAC
  assign LED = switches;

  // Buffering switch inputs
  always @ (posedge clk) 
    switches <= SW;
  
endmodule