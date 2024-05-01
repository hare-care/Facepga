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

fifo in_fifo (

);

box box_unit (
    .clk(clock),
    .reset(reset),
    .x(x),
    .y(y),
    .width(width),
    .height(height),
    .din(),
    .dout()
);

fifo out_fifo (

);



endmodule