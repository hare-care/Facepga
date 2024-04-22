`timescale 1ns/1ns

module MobileNet #(
    parameter cnn_count = 3,
    parameter fc_op_count = 10,
    parameter DATA_WIDTH = 8
)(
    input logic                 clock,
    input logic                 reset
);

logic [cnn_count-1:0][0:8][DATA_WIDTH-1:0] CnnWeights, CnnBiases;
logic CnnStride, CnnOutputEnable, CnnNewData, CnnDataValid, CnnIsIdle;
logic [cnn_count-1:0][DATA_WIDTH-1:0] CnnDataIn;
logic [7:0] CnnInputDim;
logic [1:0] CnnWindowDim;
logic [cnn_count-1:0][31:0] CnnDataOut;

genvar i;

generate
    for(i = 0; i < cnn_count; i += 1) begin
        conv #(
            .DATA_WIDTH(8),
            .MULT_PER_CYCLE(1)
        ) cnn_inst (
            .clock(clock),
            .reset(reset),
            .weights(CnnWeights[i]),
            .biases(CnnBiases[i]),
            .stride(CnnStride),
            .newPixelData(CnnDataIn[i]),
            .input_dim(CnnInputDim),
            .window_dim(CnnWindowDim),
            .out_accepting_values(CnnOutputEnable),
            .new_data_valid(CnnNewData),
            .result(CnnDataOut[i]),
            .resultValid(CnnDataValid),
            .idle_out(CnnIsIdle)
        );
    end
endgenerate

logic [fc_op_count-1:0][DATA_WIDTH-1:0] FcWeights, FcBiases, FcInputs;
logic FcStart, FcDone, FcDataValid;
logic [31:0]FcResult;
fc #(
    .DATA_WIDTH(DATA_WIDTH),
    .OPS_PER_CYCLE(fc_op_count)
) fc_inst (
    .clock(clock),
    .reset(reset),
    .operands(FcInputs),
    .weights(FcWeights),
    .biases(FcBiases),
    .start(FcStart),
    .data_valid(FcDataValid),
    .result(FcResult),
    .done_out(FcDone)
);



endmodule