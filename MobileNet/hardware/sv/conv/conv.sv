`timescale 1ns/1ns

module conv #(
    parameter DATA_WIDTH = 8,
    parameter MULT_PER_CYCLE = 9
)(
    input logic                         clock,
    input logic                         reset,
    input logic                         new_data_valid,

    input logic                         weights_valid,
    input logic                         bias_valid,

    input logic                         stride,
    input logic [7:0]                   newPixelData,

    input logic [7:0]                   input_dim,
    input logic [1:0]                   window_dim,
    input logic                         out_accepting_values,


    output logic [31:0]                 result,
    output logic                        resultValid,
    output logic                        imageDone,
    output logic                        idle_out
);

typedef enum logic[3:0] {load_data, multiply, done} conv_state;
localparam PAD_VAL = 32'hFFFFFFFF; //BLACK
conv_state state_s, state_c;
logic result_valid_c;
logic [8:0][DATA_WIDTH-1:0] window_c, window_s, window_out;
logic window_valid, window_taking_values;
logic [3:0] multiply_count_c, multiply_count_s;
logic [31:0] result_c;
logic [3:0] loopVar, multTotal;
logic [MULT_PER_CYCLE-1:0][31:0] Mac_SubOps;
logic allow_write_data;
logic [8:0][DATA_WIDTH-1:0] weights_c, weights_s, biases_c, biases_s;
logic [3:0] loadCounter_s, loadCounter_c;
logic [8:0] pixel_x_c, pixel_x_s, pixel_y_c, pixel_y_s;
logic [31:0] opCounter_c, opCounter_s;

window #(
    .DATA_WIDTH(8),
    .MAXIMUM_SIZE(9)
)window_inst(
    .new_data(newPixelData),
    .clock(clock),
    .reset(reset),
    .new_data_valid(new_data_valid && allow_write_data),
    .out_wr_en(out_accepting_values),
    .stride(stride),
    .window_dim(window_dim),
    .input_dim(input_dim),
    .window_valid(window_valid),
    .output_window(window_out),
    .in_rd_en(window_taking_values)
);

always_comb begin
    pixel_x_c = pixel_x_s;
    pixel_y_c = pixel_y_s;
    multiply_count_c = multiply_count_s;
    state_c = state_s;
    window_c = window_s;
    result_c = result;
    multTotal = (window_dim == 3) ? 9 : 1;
    result_valid_c = 0;
    allow_write_data = 0;
    idle_out = 0;
    loopVar = 0;
    Mac_SubOps = 0;
    weights_c = weights_s;
    biases_c = biases_s;
    loadCounter_c = loadCounter_s;
    imageDone = 0;
    opCounter_c = opCounter_s;

    case (state_s)
    load_data: begin
        //If loading weights, store and inc counter, reset if saturated
        if (weights_valid == 1) begin
            weights_c[loadCounter_s] = newPixelData;
            if (window_dim == 3) begin
                if (loadCounter_s < 8) begin
                    loadCounter_c = loadCounter_s + 1;
                end else begin
                    loadCounter_c = 0;
                end
            end
        end else if (bias_valid == 1) begin
            biases_c[loadCounter_s] = newPixelData;
            if (window_dim == 3) begin
                if (loadCounter_s < 8) begin
                    loadCounter_c =loadCounter_s + 1;
                end else begin
                    loadCounter_c = 0;
                end
            end
        end else if (window_valid == 1) begin
            window_c = window_out;
            state_c = multiply;
        end
        result_c = 0;
        allow_write_data = 1;
        idle_out = 1;
    end

    multiply: begin
        for (loopVar = 0; loopVar < MULT_PER_CYCLE; loopVar += 1) begin
           if (multiply_count_s + loopVar < multTotal) begin
              Mac_SubOps[loopVar] = (window_s[loopVar + multiply_count_s] * 32'(signed'(weights_s[loopVar + multiply_count_s]))) + 32'(signed'(biases_s[loopVar + multiply_count_s]));
           end else begin
              Mac_SubOps[loopVar] = 0;
           end
        end
        multiply_count_c = multiply_count_s + MULT_PER_CYCLE;
        for (loopVar = 0; loopVar < MULT_PER_CYCLE; loopVar += 1) begin
           result_c += Mac_SubOps[loopVar];
           if ($unsigned(multiply_count_c) >= multTotal) begin
             state_c = done;
             result_valid_c = 1;
             opCounter_c = opCounter_s + 1;
           end
        end
    end
    done: begin
        if (out_accepting_values == 1) begin 
            state_c = load_data;
        end
        multiply_count_c = 0;
    end
    default: begin
        state_c = load_data;
    end
    endcase
    if (new_data_valid == 1 && state_s == load_data) begin
        
        if (stride == 1) begin
            if ((pixel_x_s == (input_dim - 1) & pixel_y_s[0] == 1)  || pixel_y_s == -1) begin
                result_c  = PAD_VAL;
                result_valid_c = 1;
                opCounter_c = opCounter_s + 1;
            end
            if(pixel_x_s == (input_dim - 1)) begin
                pixel_x_c = 0;
                pixel_y_c = pixel_y_s + 1;
            end else begin
                pixel_x_c = pixel_x_s + 1;
                pixel_y_c = pixel_y_s;
            end
        end else begin
            if(pixel_x_s == (input_dim - 1)) begin
                pixel_x_c = 0;
                pixel_y_c = pixel_y_s + 1;
            end else begin
                pixel_x_c = pixel_x_s + 1;
                pixel_y_c = pixel_y_s;
            end
            if ((pixel_x_s == 0 || (pixel_x_s == (input_dim - 1)) || pixel_y_s == 0 || pixel_y_s == (input_dim - 1)) /*&& pixel_x_s[8] != 1 && pixel_y_s[8] != 1*/) begin
                result_c  = PAD_VAL;
                result_valid_c = 1;
                opCounter_c = opCounter_s + 1;
            end
        end
    end
    if (pixel_x_s == (input_dim - 2) && pixel_y_s == (input_dim - 2)) begin
        
            result_c  = PAD_VAL;
            result_valid_c = 1;
            opCounter_c = opCounter_s + 1;
        
    end
     if (opCounter_s == (input_dim * input_dim) && opCounter_s != 0) begin
            imageDone = 1;
        end
    //Window Override logic for padding
    
end

always_ff @( posedge clock, posedge reset ) begin
    if (reset == 1'b1) begin
        state_s <= load_data;
        window_s <= 0;
        multiply_count_s <= 0;
        result <= 0;
        weights_s <= 0;
        biases_s <= 0;
        loadCounter_s <= 0;
        pixel_y_s <= -1;
        pixel_x_s <= -2;
        opCounter_s <= 0;
        resultValid <= 0;
    end else begin
        opCounter_s <= opCounter_c;
        state_s <= state_c;
        window_s <= window_c;
        multiply_count_s <= multiply_count_c;
        result <= result_c;
        weights_s <= weights_c;
        biases_s <= biases_c;
        loadCounter_s <= loadCounter_c;
        pixel_x_s <= pixel_x_c;
        pixel_y_s <= pixel_y_c;
        resultValid <= result_valid_c;
    end
end

endmodule

