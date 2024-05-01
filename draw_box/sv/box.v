module box #(
    parameter IMG_WIDTH = 720,
    parameter IMG_HEIGHT = 540
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
    output [23:0] dout
);

reg [9:0] x_cnt, x_cnt_c, y_cnt, y_cnt_c;
wire [9:0] bottom, top, right, left;

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

always @(*) begin
    x_cnt_c <= x_cnt + 1;
    if (x_cnt_c >= IMG_WIDTH) begin
        x_cnt_c <= 10'b0;
        y_cnt_c <= y_cnt + 1;
        if (y_cnt_c >= IMG_HEIGHT) begin
            y_cnt_c <= 10'b0;
        end
    end
    dout_c <= din;
    if ((y_cnt == top) || (y_cnt == bottom)) begin
        if ((left <= x_cnt) && (x_cnt <= right)) begin
            dout_c <= 24'HFF0000;
        end
    end else if ((x_cnt == left) || (x_cnt == right)) begin
        if ((bottom <= y_cnt) && (y_cnt <= top)) begin
            dout_c <= 24'HFF0000;
        end
    end
    

    

end


end


always @(*) begin
    // if the x coord of din or y coord of din matches bounding box
    // make output pixel red.
    // if x coord = center + width/2 or - width/2
    // if y coord = center + height/2 or - height/2

end

endmodule;