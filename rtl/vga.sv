module vga #(
    parameter HSYNC_BITS = 11,
    parameter VSYNC_BITS = 11,

    parameter HD   = 1280,                  // Display area
    parameter HF   = 48,                    // Front porch
    parameter HR   = 112,                   // Retrace/Sync
    parameter HB   = 248,                   // Back Porch
    parameter HMAX = HD + HF + HR + HB - 1, // MAX counter value

    parameter VD   = 1024,
    parameter VF   = 1,
    parameter VR   = 3,
    parameter VB   = 38,
    parameter VMAX = VD + VF + VR + VB - 1
) (
    input           clk, arstn,

    input   [11:0]  SW,

    output          VGA_HS, VGA_VS,
    output  [11:0]  RGB,
    output  [11:0]  LED
);

  enum bit [1:0] {
    BLACK,
    WHITE,
    BLUE,
    GREEN
  } color_type;

  // Switch state buffer registers
  logic [          11:0] switches;

  logic [          11:0] rgb_ff;
  logic [          11:0] rgb_next;
  logic                  rgb_en;

  logic [          11:0] led_ff;
  logic [          11:0] led_next;
  logic                  led_en;

  logic                  hsync_ff;
  logic                  hsync_next;
  logic                  hsync_en;

  logic                  vsync_ff;
  logic                  vsync_next;
  logic                  vsync_en;

  logic [VSYNC_BITS-1:0] vcount_buff;
  logic [HSYNC_BITS-1:0] hcount_buff;
  logic [           1:0] video_buffer_ff       [VD * HD];
  logic [           1:0] video_buffer_pixel_ff;

  logic                  pixel_en_ff;
  logic                  pixel_en;
  logic                  pixel_en_next;

  logic [           1:0] video_buffer_ff       [VD * HD];
  logic [           1:0] video_buffer_next     [VD * HD];
  logic                  video_buffer_en;

  logic [           1:0] video_buffer_pixel_ff;

  logic [          11:0] color_ff;
  logic [HSYNC_BITS-1:0] hcount;
  logic                  hcount_en;
  logic [VSYNC_BITS-1:0] vcount;
  logic                  vcount_en;

  logic [VSYNC_BITS-1:0] vcount_buff;
  logic [HSYNC_BITS-1:0] hcount_buff;

  ////////////////////////////////
  //    HORIZONTAL COUNTER      //
  ////////////////////////////////

  assign hcount_en = (hcount < HMAX);

  always @(posedge clk or negedge arstn) begin
    if (!arstn == 1'b1) hcount <= 0;
    else if (hcount_en) hcount <= hcount + 1;
    else hcount <= 0;
  end

  ////////////////////////////////
  //     VERTICAL COUNTER       //
  ////////////////////////////////

  assign vcount_en = (hcount == HMAX && vcount < VMAX);

  always @(posedge clk or negedge arstn) begin
    if (!arstn == 1'b1) vcount <= 0;
    else if (vcount_en) vcount <= vcount + 1;
    else vcount <= 0;
  end

  ////////////////////////////////
  //        PIXEL ENABLE        //
  ////////////////////////////////

  assign pixel_en = hcount >= (HR+HB) && hcount < (HR+HB+HD) && vcount >= (VR+VB) && vcount < (VR+VB+VD);
  assign pixel_en_next = pixel_en ? 1'b1 : 1'b0;

  always @(posedge clk or negedge arstn) begin
    if (!arstn) pixel_en_ff <= 1'b0;
    else pixel_en_ff <= pixel_en_next;
  end

  ////////////////////////////////
  // HORIZONTAL & VERTICAL SYNC //
  ////////////////////////////////

  assign hsync_next = (hcount < HR) ? 1'b1 : 1'b0;
  assign vsync_next = (vcount < VR) ? 1'b1 : 1'b0;

  // Horizontal and Vertical sync signal generator
  always @(posedge clk or negedge arstn) begin
    if (!arstn) begin
      hsync_ff <= 1'b0;
      vsync_ff <= 1'b0;
    end else begin
      hsync_ff <= hsync_next;
      vsync_ff <= vsync_next;
    end
  end

  assign VGA_HS = hsync_ff;
  assign VGA_VS = vsync_ff;

  // Assigning the current switch state to both view which switches are on and output to VGA RGB DAC
  assign LED = switches;
  assign RGB = (pixel_en_ff) ? switches : 12'b0;

  ////////////////////////////////
  //        VIDEO BUFFER        //
  ////////////////////////////////

  assign video_buffer_en = we_i;
  assign video_buffer_next = color_i;

  always_ff @(posedge clk_i or negedge arstn)
    if (!arstn) video_buffer_ff <= '0;  // TODO: Check zero reset assining is right
    else if (video_buffer_en) video_buffer_ff[addr_x_i*HD+addr_y_i] <= video_buffer_next;

  always_ff @(posedge clk_i) begin
    vcount_buff <= vcount - (VR + VB);
    hcount_buff <= hcount - (HR + HB);
  end

  always_ff @(posedge clk_i)
    video_buffer_pixel_ff <= video_buffer_ff[(vcount_buff)*HD+(hcount_buff)];

  always_ff @(posedge clk_i)
    case (video_buffer_pixel_ff)
      BLACK: color_ff <= {12{1'b0}};
      WHITE: color_ff <= {12{1'b1}};
      BLUE:  color_ff <= {{4{1'b1}}, {8{1'b0}}};
      GREEN: color_ff <= {{4{1'b0}}, {4{1'b1}}, {4{1'b0}}};
    endcase

endmodule
