module box (
    input clk,
    input reset,
    input x,
    input y,
    input width,
    input height,
    input rd_en,
    input wr_en,
    input [23:0] din,
    output [23:0] dout
);

always @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin
        dout <= 24'b0;
    end else begin
        dout <= dout_c;
    end


end


always @(*) begin
    // if the x coord of din or y coord of din matches bounding box
    // make output pixel red.
    // if x coord = center + width/2 or - width/2
    // if y coord = center + height/2 or - height/2

end

endmodule;