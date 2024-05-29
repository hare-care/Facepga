`timescale 1ns/1ns

module network_components #(
    DATA_WIDTH = 8,
    CNN_UNROLL_FACTOR = 9,
    CNN_COUNT = 4
)(
    //GLOBALS
    input logic                                             clock,
    input logic                                             reset,
    input logic [31:0]                                      DDR3_Input,
    input logic                                             Network_Output_Enable,
    input logic                                             DDR3_operands,
    input logic                                             DDR3_weights,
    input logic                                             DDR3_biases,
    input logic [1:0]                                       Layer, //0 = Conv, 1 = FC, 2 = MaxPool
    input logic                                             Start,

    output logic [31:0]                                     Result,
    output logic                                            Computing,
    output logic                                            ResultValid,
    output logic                                            Done,
    output logic                                            InputEnable,
    //CNN
    input logic                                             CNN_Stride,
    input logic [1:0]                                       CNN_Window_Dim,
    input logic [7:0]                                       CNN_Input_Dim

);



logic CNN_Result_Valid, CNN_Idle, CNN_done;
logic [31:0] CNN_Result;

convolutional_layer #(
    .CNN_UNROLL_FACTOR(CNN_COUNT),
    .CNN_DATA_WIDTH(DATA_WIDTH),
    .CNN_OP_PER_CYCLE(CNN_UNROLL_FACTOR)
) conv_layer (
    .clock(clock),
    .reset(reset),
    .stride(CNN_Stride),
    .newDataPacket(DDR3_Input),
    .inputDim(CNN_Input_Dim),
    .windowDim(CNN_Window_Dim),
    .output_enable(Network_Output_Enable),
    .input_valid(DDR3_operands),
    .weights_valid(DDR3_weights),
    .bias_valid(DDR3_biases),
    .result(CNN_Result),
    .outputs_valid(CNN_Result_Valid),
    .idle(CNN_Idle),
    .imagesDone(CNN_done)
);

logic AVP_Done, AVP_InputEnable;
logic [31:0]AVP_Result;

avg_pool #(
    .DATA_WIDTH(32)
) average_pool_layer (
    .clock(clock),
    .reset(reset),
    .newPointData(DDR3_Input),
    .newPointValid(DDR3_operands),
    .done(AVP_Done),
    .average(AVP_Result),
    .inputEnable(AVP_InputEnable)
);

logic fc_Computing;
logic                                               fc_done;
logic [31:0]                                        fc_result;

fc #(
    .DATA_WIDTH(8),
    .FC_TOTAL_COUNT(1024)
) fully_connected_layer (
    .clock(clock),
    .reset(reset),
    .new_data(DDR3_Input),
    .start(Start),
    .ops_valid(DDR3_operands),
    .weights_valid(DDR3_weights),
    .biases_valid(DDR3_biases),
    .result(fc_result),
    .in_rd_en(fc_Computing),
    .done_out(fc_done)
);

always_comb begin
    Computing = 0;
    Result = AVP_Result;
    Done = AVP_Done;
    InputEnable = 0;
    ResultValid = 0;
    if (Layer == 0) begin
        Result = CNN_Result;
        Done = CNN_done;
        ResultValid = CNN_Result_Valid;
        InputEnable = CNN_Idle;
    end else if (Layer == 1) begin
        Result = fc_result;
        Done = fc_done;
        Computing = 1;
        ResultValid = fc_done;
        InputEnable = !fc_Computing;
    end else if (Layer == 2) begin
        InputEnable = AVP_InputEnable;
        ResultValid = AVP_Done;
        Done = AVP_Done;
    end
end


endmodule