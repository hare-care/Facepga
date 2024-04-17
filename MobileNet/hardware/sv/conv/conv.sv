`timescale 1ns/1ns

module conv #(
    parameter DATA_WIDTH = 8,
    parameter MULT_PER_CYCLE = 1
)(
    input logic                         clock,
    input logic                         reset,

    input logic [0:8][7:0]              weights,
    input logic [0:8][7:0]              biases,
    input logic                         stride,
    input logic [7:0]                   newPixelData,

    input logic [7:0]                   input_dim,
    input logic [1:0]                   window_dim,
    input logic                         out_accepting_values,
    input logic                         new_data_valid,

    output logic [31:0]                 result,
    output logic                        resultValid,
    output logic                        idle_out
);

typedef enum logic[3:0] {idle, multiply, done} conv_state;

conv_state state_s, state_c;
logic [8:0][DATA_WIDTH-1:0] window_c, window_s, window_out;
logic window_valid, window_taking_values;
logic [3:0] multiply_count_c, multiply_count_s;
logic [31:0] result_c;
logic [3:0] loopVar, multTotal;
logic [MULT_PER_CYCLE-1:0][31:0] Mac_SubOps;
logic allow_write_data;

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
    multiply_count_c = multiply_count_s;
    state_c = state_s;
    window_c = window_s;
    result_c = result;
    multTotal = (window_dim == 3) ? 9 : 1;
    resultValid = 0;
    allow_write_data = 0;
    idle_out = 0;
    loopVar = 0;
    Mac_SubOps = 0;
    case (state_s)
    idle: begin
        if (window_valid == 1'b1) begin
            window_c = window_out;
            state_c = multiply;
        end
        allow_write_data = 1;
        idle_out = 1;
    end

    multiply: begin
        for (loopVar = 0; loopVar < MULT_PER_CYCLE; loopVar += 1) begin
           if (multiply_count_s + loopVar < multTotal) begin
              Mac_SubOps[loopVar] = (window_s[loopVar + multiply_count_s] * weights[loopVar + multiply_count_s]) + biases[loopVar + multiply_count_s];
           end else begin
              Mac_SubOps[loopVar] = 0;
           end
           multiply_count_c = multiply_count_s + MULT_PER_CYCLE;
           for (loopVar = 0; loopVar < MULT_PER_CYCLE; loopVar += 1) begin
              result_c += Mac_SubOps[loopVar];
           end
           if (multiply_count_c > multTotal) begin
             state_c = done;
           end
        end
    end

    done: begin
        if (out_accepting_values == 1) begin 
            state_c = idle;
            resultValid = 1;
        end
        multiply_count_c = 0;
    end

    default: begin
        state_c = idle;
    end

    endcase
end

always_ff @( posedge clock, posedge reset ) begin

    if (reset == 1'b1) begin
        state_s <= idle;
        window_s <= 0;
        multiply_count_s <= 0;
        result <= 0;
    end else begin
        state_s <= state_c;
        window_s <= window_c;
        multiply_count_s <= multiply_count_c;
        result <= result_c;
    end
    
end

endmodule

