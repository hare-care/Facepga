`timescale 1ns/1ns

module conv_tb();

    logic clock, reset, stride, idle,resultValid,out_accepting_values,new_data_valid,weights_valid, bias_valid;
    logic [7:0] weight, bias;
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
        .weights_valid(weights_valid),
        .bias_valid(bias_valid),
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
        weight = 1;
        bias = 1;
        stride = 0;
        newPixelData = 0;
        window_dim = 3;
        input_dim = 14;
        out_accepting_values = 1;
        weights_valid = 0;
        new_data_valid = 1;
        #20;
        reset = 0;
        for (int i = 0 ; i < 1000; i += 1) begin
            weights_valid = 0;
            bias_valid = 0;
            new_data_valid = 0;
            if (i < 9) begin
                weight = i;
                weights_valid = 1;
            end else if (i < 18) begin
                bias = i;
                bias_valid = 1;
            end
            new_data_valid = 1;
            newPixelData = i;
            #20;
        end
        #40;
        $finish;
    end

endmodule