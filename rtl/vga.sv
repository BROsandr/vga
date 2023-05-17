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
    logic Reset;
    assign Reset = ~arstn;
    
    // Sync signal registers, vertical counter enable register, and pixel enable register
    reg hsync = 0, vsync = 0;
    
    // Switch state buffer registers
    reg [11:0] switches;
    
    // Horizontal counter
    always @ (posedge clk or posedge Reset) begin
        if (Reset == 1'b1) begin
            hcount <= 0;
        end
        else if (hcount < HMAX) begin
            hcount <= hcount + 1;
        end
        else begin
            hcount <= 0;
        end
    end
    
    // Vertical counter
    always @ (posedge clk or posedge Reset) begin
        if (Reset == 1'b1) vcount <= 0;
        else begin
            if (hcount == HMAX) begin
                if (vcount < VMAX) vcount <= vcount + 1;
                else vcount <= 0;
            end
        end
    end
    
    // Horizontal and Vertical sync signal generator
    always @ (posedge clk or posedge Reset) begin
        if (Reset) begin
            hsync <= 1'b0;
            vsync <= 1'b0;
        end
        else begin
            hsync <= (hcount < HR) ? 1'b1 : 1'b0;
            vsync <= (vcount < VR) ? 1'b1 : 1'b0;
        end
    end
    
    // Assigning register values to outputs
    assign VGA_HS = hsync;
    assign VGA_VS = vsync;
    
    always @ (posedge clk or posedge Reset) begin
        if (Reset) pixel_enable <= 1'b0;
        else
            if (hcount >= (HR+HB) && hcount < (HR+HB+HD) && vcount >= (VR+VB) && vcount < (VR+VB+VD)) pixel_enable <= 1'b1;
            else pixel_enable <= 1'b0;
    end
    
    
    // Buffering switch inputs
    always @ (posedge clk) 
        switches <= SW;
    
    // Assigning the current switch state to both view which switches are on and output to VGA RGB DAC
    assign LED = switches;
    assign RGB = (pixel_enable) ? switches : 12'b0;
endmodule