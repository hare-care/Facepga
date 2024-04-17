`timescale 1ns/1ns

module conv_tb();

    logic clock, reset, stride, idle,resultValid,out_accepting_values,new_data_valid;
    logic [8:0][7:0] weights, biases;
    logic [31:0] result;
    logic [8:0] newPixelData;
    logic [1:0] window_dim;
    logic [7:0] input_dim;

    conv #(
        .DATA_WIDTH(8),
        .MULT_PER_CYCLE(1)
    )top_inst(
        .clock(clock),
        .reset(reset),
        .weights(weights),
        .biases(biases),
        .stride(stride),
        .newPixelData(newPixelData),
        .out_accepting_values(out_accepting_values),
        .input_dim(input_dim),
        .window_dim(window_dim),
        .result(result),
        .resultValid(resultValid),
        .idle_out(idle),
        .new_data_valid(new_data_valid)
    );

    always #10 clock = ~clock;

    initial begin
        clock = 0;
        reset = 1;
        weights = '{1,2,3,1,2,3,1,2,3};
        biases = '{0,0,0,0,0,0,0,0,0};
        stride = 0;
        newPixelData = 0;
        window_dim = 3;
        input_dim = 14;
        out_accepting_values = 1;
        new_data_valid = 1;
        #10;
        reset = 0;
        for (int i = 0 ; i < 1000; i += 1) begin
            newPixelData = i;
            #20;
        end
        #40;
        $finish;
    end

endmodule