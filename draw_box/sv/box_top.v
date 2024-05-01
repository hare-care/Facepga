module box_top 
(
    input  clock,
    input  reset,
    input [9:0] x,y,width,height,
    output input_full,
    input  input_wr_en,
    input  [23:0] input_din,
    input  dout_rd_en,
    output dout_empty,
    output [23:0] dout
);

// input fifo to box unit
wire input_rd_en, input_dout;
wire [23:0] input_dout;

// box unit to output fifo
wire [23:0] box_dout;
wire out_full, out_wr_en;


fifo #(
    .FIFO_BUFFER_SIZE(32),
    .FIFO_DATA_WIDTH(24)
) input_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(input_wr_en),
    .din(input_din),
    .full(input_full),
    .rd_clk(clock),
    .rd_en(input_rd_en),
    .dout(input_dout),
    .empty(input_empty)
);

assign input_rd_en = !input_empty;

box box_unit (
    .clk(clock),
    .reset(reset),
    .x(x),
    .y(y),
    .width(width),
    .height(height),
    .din(input_dout),
    .dout(box_dout)
);

assign out_wr_en = !out_full;

fifo #(
    .FIFO_BUFFER_SIZE(32),
    .FIFO_DATA_WIDTH(24)
) out_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(out_wr_en),
    .din(box_dout),
    .full(out_full),
    .rd_clk(clock),
    .rd_en(dout_rd_en),
    .dout(dout),
    .empty(dout_empty)
);



endmodule