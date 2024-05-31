`timescale 1 ns / 1 ns

module box #(
    parameter IMG_WIDTH = 768,
    parameter IMG_HEIGHT = 576
)(
    input clk,
    input reset,
    input [10:0] x,
    input [10:0] y,
	 input [10:0] vga_x,
	 input [10:0] vga_y,
    input [10:0] width,
    input [10:0] height,
    input rd_en,
    input wr_en,
    input [23:0] din,
    output reg [23:0] dout
);

wire [10:0] bottom, top, right, left;

reg [23:0] dout_c;

assign bottom = y - (height/2);
assign top = y + (height/2);
assign left = x - (width/2);
assign right = x + (width/2);


always @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin
        dout <= 24'b0;
    end else begin
        dout <= dout_c;
    end
end

always @(*) begin
    dout_c = din;
    if ((vga_y == top) || (vga_y == bottom) || (vga_y == top-1) || (vga_y == bottom+1)) begin
        if ((left <= vga_x) && (vga_x <= right)) begin
            dout_c = 24'HFF0000;
        end
    end else if ((vga_x == left) || (vga_x == right) || (vga_x == left+1) || (vga_x == right-1)) begin
        if ((bottom <= vga_y) && (vga_y <= top)) begin
            dout_c = 24'HFF0000;
        end
    end
end
endmodule