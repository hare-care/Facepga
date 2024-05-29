`timescale 1ns/1ns

module processing_state_controller(
    input logic clock,
    input logic reset,
    input logic [31:0]                  DDR3_Input,
    input logic                         DDR3_Input_Valid,
    input logic                         Begin_Calc,

    output logic [31:0]                 DDR3_Address,
    output logic [31:0]                 Processor_Result,
    output logic                        Network_Output_Valid,
    output logic                        Proc_Done,
    output logic                        DDR3_WE,
    output logic                        Input_Enable
);


localparam WEIGHT_BASE_ADDR = 32'h00000000;
localparam BIAS_BASE_ADDR = 32'h00000000;
localparam DATA_BASE_ADDR = 32'h00000000;

//Globals
localparam WEIGHTS_PER_CONV = 9;

//Resizer Offsets
localparam RESIZER_OFFSET = 0;
localparam RESIZER_WRITE_ADDR = DATA_BASE_ADDR + RESIZER_OFFSET;
localparam RESIZER_WRITE_SIZE = 224 * 224 * 4;
//Conv Offsets
localparam C1_DREAD_ADDR_START = RESIZER_WRITE_ADDR;
localparam C1_ITERATION_COUNT = 32/4;
localparam C1_WREAD_ADDR_START = WEIGHT_BASE_ADDR;
localparam C1_BREAD_ADDR_START = BIAS_BASE_ADDR;
localparam C1_DWRITE_START = WEIGHT_BASE_ADDR + RESIZER_WRITE_SIZE;
localparam C1_DWRITE_SIZE = 112 * 112 * 32;

localparam C2_DREAD_ADDR_START = C1_DWRITE_START;
localparam C2_ITERATION_COUNT = 32/4;
localparam C2_WREAD_ADDR_START = C1_WREAD_ADDR_START + (32 * WEIGHTS_PER_CONV);
localparam C2_BREAD_ADDR_START = C1_BREAD_ADDR_START + (32 * WEIGHTS_PER_CONV);
localparam C2_DWRITE_START = C1_DWRITE_START + C1_DWRITE_SIZE;
localparam C2_DWRITE_SIZE = 112 * 112 * 32;

localparam C3_DREAD_ADDR_START = C2_DWRITE_START;
localparam C3_ITERATION_COUNT = (32/4) * (64);
localparam C3_WREAD_ADDR_START = C2_WREAD_ADDR_START + (32 * WEIGHTS_PER_CONV);
localparam C3_BREAD_ADDR_START = C2_BREAD_ADDR_START + (32 * WEIGHTS_PER_CONV);
localparam C3_DWRITE_START = C2_DWRITE_START + C2_DWRITE_SIZE;
localparam C3_DWRITE_SIZE = 112 * 112 * 64;

localparam AVP_DREAD_ADDR_START = 0;

logic [31:0] cycle_counter_c, cycle_counter_s;

logic network_reset;
logic network_output_enable;
logic DDR3_loaded_operands, DDR3_loaded_weights, DDR3_loaded_biases;
logic [1:0] Layer;
logic network_computing;
logic network_done;
logic CNN_Stride;
logic [1:0]CNN_Window_Dim;
logic [7:0]CNN_Input_Dim;
logic Start, Network_Input_Enable, networkResultValid;
logic [31:0]Network_Result;

network_components #(
    .DATA_WIDTH(8),
    .CNN_UNROLL_FACTOR(9),
    .CNN_COUNT(4)
) mobilenet (
    .clock(clock),
    .reset(network_reset || reset),
    .DDR3_Input(DDR3_Input),
    .Network_Output_Enable(network_output_enable),
    .DDR3_operands(DDR3_loaded_operands),
    .DDR3_weights(DDR3_loaded_weights),
    .DDR3_biases(DDR3_loaded_biases),
    .Layer(Layer),
    .Result(Network_Result),
    .Computing(network_computing),
    .Done(network_done),
    .CNN_Stride(CNN_Stride),
    .CNN_Window_Dim(CNN_Window_Dim),
    .CNN_Input_Dim(CNN_Input_Dim),
    .Start(Start),
    .InputEnable(Network_Input_Enable),
    .ResultValid(networkResultValid)
);

logic [23:0] resizer_pixel_data;
logic resizer_start_of_image, resizer_pixel_valid;
logic [7:0] resizer_Red, resizer_Blue, resizer_Green;

resizer #(
    .DATA_WIDTH(24),
    .INPUT_WIDTH(640),
    .INPUT_HEIGHT(480),
    .VERT_CROP_COUNT(16),
    .HORIZ_CROP_COUNT(96),
    .OUT_DIM(224)
) resizer_inst (
    .clock(clock),
    .reset(reset),
    .newPixelData(resizer_pixel_data),
    .newPixelValid(resizer_pixel_valid),
    .startNewImage(resizer_start_of_image),
    .endOfImage(resizer_end_of_image),
    .outRed(resizer_Red),
    .outGreen(resizer_Green),
    .outBlue(resizer_Blue),
    .outPixelValid(resizer_output_valid)
);

typedef enum logic [4:0] {
    idle,
    resize,
    conv1,
    conv2,
    conv3,
    conv4,
    conv5,
    conv6,
    conv7,
    conv8,
    conv9,
    conv10,
    conv11,
    conv12,
    conv13,
    conv14,
    conv15,
    conv16,
    conv17,
    conv18,
    conv19,
    conv20,
    conv21,
    conv22,
    avgPool,
    fullyConnected,
    outputResizer,
    done
} network_state;

network_state state_c, state_s;

always_comb begin
    Proc_Done = 0;
    resizer_pixel_data = 0;
    resizer_pixel_valid = 0;
    resizer_start_of_image = 0;
    DDR3_Address = 0;  
    network_reset = 0;
    cycle_counter_c = cycle_counter_s;
    if (DDR3_Input_Valid == 1) begin
        cycle_counter_c = cycle_counter_s  + 1;
    end
    DDR3_loaded_biases = 0;
    DDR3_loaded_operands = 0;
    DDR3_loaded_weights = 0;
    CNN_Stride = 0;
    CNN_Input_Dim = 0;
    CNN_Window_Dim = 0;
    Start = 0;
    Layer = 0;
    Processor_Result = Network_Result;
    state_c = state_s;
    Input_Enable = Network_Input_Enable;
    Network_Output_Valid = networkResultValid;
    network_output_enable = 1;
    case(state_s)//Bigass switch case™
    idle: begin
        if (Begin_Calc == 1) begin
            state_c = conv1;
            cycle_counter_c = 0;
        end
    end
    resize: begin
        Input_Enable = 1; //Resizer has 0 cycle compute time -- never will bottleneck
        resizer_pixel_data = DDR3_Input[23:0];
        resizer_pixel_valid = 1;
        if (resizer_output_valid == 1)begin
            Processor_Result = {8'b0,resizer_Red,resizer_Blue,resizer_Green};
            Network_Output_Valid = 1;
        end
        if (cycle_counter_s == 0) begin
            resizer_start_of_image = 1;
        end
        if (resizer_end_of_image == 1) begin 
            state_c = conv1;
            network_reset = 1;
            cycle_counter_c = 0;
        end
    end
    conv1: begin
        DDR3_Address = C1_DREAD_ADDR_START + ((cycle_counter_s - 18) * 4);
        DDR3_loaded_operands = 1;
        CNN_Stride = 0;
        CNN_Input_Dim = 224;
        CNN_Window_Dim = 3;
        if (network_done == 1) begin
            state_c = conv2;
            cycle_counter_c = 0;
        end
        if (cycle_counter_s < 9 ) begin
            DDR3_loaded_operands = 0;
            DDR3_Address = C1_WREAD_ADDR_START + (cycle_counter_s * 4);
            DDR3_loaded_weights = 1;
        end else if (cycle_counter_s < 18) begin
            DDR3_loaded_operands = 0;
            DDR3_Address = C1_BREAD_ADDR_START + ((cycle_counter_s - 9) * 4);
            DDR3_loaded_biases = 1;
        end
    end
    conv2: begin
        if (cycle_counter_s == 0) begin
            network_reset = 1;
            cycle_counter_c = 1;
        end
        DDR3_Address = C2_DREAD_ADDR_START + ((cycle_counter_s - 19) * 4);
        DDR3_loaded_operands = 1;
        CNN_Stride = 0;
        CNN_Input_Dim = 224;
        CNN_Window_Dim = 3;
        if (network_done == 1) begin
            state_c = conv3;
            DDR3_loaded_operands = 0;
            cycle_counter_c = 0;
        end
        if (cycle_counter_s < 10) begin
            DDR3_Address = C2_WREAD_ADDR_START + (cycle_counter_s * 4);
            DDR3_loaded_weights = 1;
            DDR3_loaded_operands = 0;
        end else if (cycle_counter_s < 19) begin
            DDR3_Address = C2_BREAD_ADDR_START + ((cycle_counter_s - 10) * 4);
            DDR3_loaded_biases = 1;
            DDR3_loaded_operands = 0;
        end
    end
    conv3: begin
        if (cycle_counter_s == 0) begin
            network_reset = 1;
            cycle_counter_c = 1;
        end
        DDR3_Address = C2_DREAD_ADDR_START + ((cycle_counter_s - 19) * 4);
        DDR3_loaded_operands = 1;
        CNN_Stride = 1;
        CNN_Input_Dim = 224;
        CNN_Window_Dim = 3;
        if (network_done == 1) begin
            state_c = conv4;
            DDR3_loaded_operands = 0;
            cycle_counter_c = 0;
        end
        if (cycle_counter_s < 10) begin
            DDR3_Address = C2_WREAD_ADDR_START + (cycle_counter_s * 4);
            DDR3_loaded_weights = 1;
            DDR3_loaded_operands = 0;
        end else if (cycle_counter_s < 19) begin
            DDR3_Address = C2_BREAD_ADDR_START + ((cycle_counter_s - 10) * 4);
            DDR3_loaded_biases = 1;
            DDR3_loaded_operands = 0;
        end
    end
    conv4: begin
        if (cycle_counter_s == 0) begin
            network_reset = 1;
            cycle_counter_c = 1;
        end
        DDR3_Address = C2_DREAD_ADDR_START + ((cycle_counter_s - 19) * 4);
        DDR3_loaded_operands = 1;
        CNN_Stride = 1;
        CNN_Input_Dim = 112;
        CNN_Window_Dim = 3;
        if (network_done == 1) begin
            state_c = conv5;
            DDR3_loaded_operands = 0;
            cycle_counter_c = 0;
        end
        if (cycle_counter_s < 10) begin
            DDR3_Address = C2_WREAD_ADDR_START + (cycle_counter_s * 4);
            DDR3_loaded_weights = 1;
            DDR3_loaded_operands = 0;
        end else if (cycle_counter_s < 19) begin
            DDR3_Address = C2_BREAD_ADDR_START + ((cycle_counter_s - 10) * 4);
            DDR3_loaded_biases = 1;
            DDR3_loaded_operands = 0;
        end
    end
    conv5: begin
        DDR3_Address = C2_DREAD_ADDR_START + ((cycle_counter_s - 18) * 4);
        DDR3_loaded_operands = 1;
        CNN_Stride = 0;
        CNN_Input_Dim = 56;
        CNN_Window_Dim = 1;
        if (network_done == 1) begin
            state_c = conv9;
            network_reset = 1;
            cycle_counter_c = 0;
        end
        if (cycle_counter_s < 9) begin
            DDR3_Address = C2_WREAD_ADDR_START + (cycle_counter_s * 4);
            DDR3_loaded_weights = 1;
        end else if (cycle_counter_s < 18) begin
            DDR3_Address = C2_BREAD_ADDR_START + ((cycle_counter_s - 9) * 4);
            DDR3_loaded_biases = 1;
        end
    end
    conv6: begin
        
    end
    conv7: begin

    end
    conv8: begin

    end
    conv9: begin
        DDR3_Address = C2_DREAD_ADDR_START + ((cycle_counter_s - 18) * 4);
        DDR3_loaded_operands = 1;
        CNN_Stride = 0;
        CNN_Input_Dim = 28;
        CNN_Window_Dim = 1;
        if (network_done == 1) begin
            state_c = conv13;
            network_reset = 1;
            cycle_counter_c = 0;
        end
        if (cycle_counter_s < 9) begin
            DDR3_Address = C2_WREAD_ADDR_START + (cycle_counter_s * 4);
            DDR3_loaded_weights = 1;
        end else if (cycle_counter_s < 18) begin
            DDR3_Address = C2_BREAD_ADDR_START + ((cycle_counter_s - 9) * 4);
            DDR3_loaded_biases = 1;
        end
    end
    conv10: begin

    end
    conv11: begin

    end
    conv12: begin

    end
    conv13: begin
        DDR3_Address = C2_DREAD_ADDR_START + ((cycle_counter_s - 18) * 4);
        DDR3_loaded_operands = 1;
        CNN_Stride = 0;
        CNN_Input_Dim = 14;
        CNN_Window_Dim = 1;
        if (network_done == 1) begin
            state_c = conv17;
            network_reset = 1;
            cycle_counter_c = 0;
        end
        if (cycle_counter_s < 9) begin
            DDR3_Address = C2_WREAD_ADDR_START + (cycle_counter_s * 4);
            DDR3_loaded_weights = 1;
        end else if (cycle_counter_s < 18) begin
            DDR3_Address = C2_BREAD_ADDR_START + ((cycle_counter_s - 9) * 4);
            DDR3_loaded_biases = 1;
        end
    end
    conv14: begin

    end
    conv15: begin

    end
    conv16: begin

    end
    conv17: begin
        DDR3_Address = C2_DREAD_ADDR_START + ((cycle_counter_s - 18) * 4);
        DDR3_loaded_operands = 1;
        CNN_Stride = 0;
        CNN_Input_Dim = 7;
        CNN_Window_Dim = 1;
        if (network_done == 1) begin
            state_c = avgPool;
            network_reset = 1;
            cycle_counter_c = 0;
        end
        if (cycle_counter_s < 9) begin
            DDR3_Address = C2_WREAD_ADDR_START + (cycle_counter_s * 4);
            DDR3_loaded_weights = 1;
        end else if (cycle_counter_s < 18) begin
            DDR3_Address = C2_BREAD_ADDR_START + ((cycle_counter_s - 9) * 4);
            DDR3_loaded_biases = 1;
        end
    end
    conv18: begin

    end
    conv19: begin

    end
    conv20: begin

    end
    conv21: begin

    end
    conv22: begin

    end
    avgPool: begin
        DDR3_Address = AVP_DREAD_ADDR_START;
        Layer = 1;
        if (network_done == 1) begin
            state_c = fullyConnected;
        end
    end
    fullyConnected: begin
        Layer = 2;
        if (cycle_counter_s == 0) begin
            Start = 1;
        end
        if (network_done == 1) begin
            state_c = outputResizer;
        end
    end
    outputResizer:begin
        //TBD  - Future Works - Should've been softmax but TF doesnt use?
        state_c = idle;
        Layer = 3;
    end
    done: begin
        Proc_Done = 1;
    end
    default: begin

    end
    endcase
end

always_ff @(posedge clock, posedge reset) begin
    if (reset == 1) begin
        state_s <= idle;
        cycle_counter_s <= 0;
    end else begin
        state_s <= state_c;
        cycle_counter_s <= cycle_counter_c;
    end
end

endmodule