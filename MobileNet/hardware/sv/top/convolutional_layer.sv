`timescale 1ns/1ns

module convolutional_layer #(
    parameter CNN_UNROLL_FACTOR = 4,
    parameter CNN_DATA_WIDTH = 8,
    parameter CNN_OP_PER_CYCLE = 9
)(
    input logic                                             clock,
    input logic                                             reset,
    input logic                                             stride,
    input logic [31:0]                                      newDataPacket, //Assuming CNN Unroll < 4!!!
    input logic [7:0]                                       inputDim,
    input logic [1:0]                                       windowDim,
    input logic                                             output_enable,
    input logic                                             input_valid,
    input logic                                             weights_valid,
    input logic                                             bias_valid,

    output logic [CNN_UNROLL_FACTOR-1:0][CNN_DATA_WIDTH-1:0]result,
    output logic                                            outputs_valid,
    output logic                                            idle
);

    genvar cnn_count;

    logic [CNN_UNROLL_FACTOR-1:0] outValidArray;
    logic [CNN_UNROLL_FACTOR-1:0] idleArray;
    logic [CNN_UNROLL_FACTOR-1:0][31:0] resArray;

    generate
    for(cnn_count = 0; cnn_count < CNN_UNROLL_FACTOR; cnn_count ++)begin
        conv #(
            .DATA_WIDTH(CNN_DATA_WIDTH),
            .MULT_PER_CYCLE(CNN_OP_PER_CYCLE)
        ) convolutional_layer(
            .clock(clock),
            .reset(reset),
            .weights_valid(weights_valid),
            .bias_valid(bias_valid),
            .stride(stride),
            .newPixelData(newDataPacket[((cnn_count+1)*8)-1:(cnn_count*8)]),
            .input_dim(inputDim),
            .window_dim(windowDim),
            .out_accepting_values(output_enable),
            .new_data_valid(input_valid),
            .result(resArray[cnn_count]),
            .resultValid(outValidArray[cnn_count]),
            .idle_out(idleArray[cnn_count])
        );
        assign result[cnn_count] = resArray[cnn_count][7:0];
        end
    endgenerate

    assign outputs_valid = &outValidArray;
    assign idle = &idleArray;


endmodule