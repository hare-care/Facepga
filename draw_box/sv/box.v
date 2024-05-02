`timescale 1 ns / 1 ns

module box #(
    parameter IMG_WIDTH = 768,
    parameter IMG_HEIGHT = 576
)(
    input clk,
    input reset,
    input [9:0] x,
    input [9:0] y,
    input [9:0] width,
    input [9:0] height,
    input rd_en,
    input wr_en,
    input [23:0] din,
    output reg [23:0] dout
);

reg [9:0] x_cnt, x_cnt_c, y_cnt, y_cnt_c;
wire [9:0] bottom, top, right, left;

reg [23:0] dout_c;

assign bottom = y - (height/2);
assign top = y + (height/2);
assign left = x - (height/2);
assign right = x + (height/2);


always @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin
        dout <= 24'b0;
        x_cnt <= 10'b0;
        y_cnt <= 10'b0; // make these the correct bit sizes
    end else begin
        dout <= dout_c;
        x_cnt <= x_cnt_c;
        y_cnt <= y_cnt_c;
    end
end

always @(*) begin
    y_cnt_c = y_cnt;
    x_cnt_c = x_cnt + 1;
    if (x_cnt_c >= IMG_WIDTH) begin
        x_cnt_c = 10'b0;
        y_cnt_c = y_cnt + 1;
        if (y_cnt_c >= IMG_HEIGHT) begin
            y_cnt_c = 10'b0;
        end
    end
    dout_c = din;
    if ((y_cnt == top) || (y_cnt == bottom)) begin
        if ((left <= x_cnt) && (x_cnt <= right)) begin
            dout_c = 24'H0000FF;
        end
    end else if ((x_cnt == left) || (x_cnt == right)) begin
        if ((bottom <= y_cnt) && (y_cnt <= top)) begin
            dout_c = 24'H0000FF;
        end
    end
end
endmodule