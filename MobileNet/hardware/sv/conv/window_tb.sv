`timescale 1ns/1ns

module window_tb();

    logic [7:0] newData, input_dim;
    logic [1:0] window_dim;
    logic clock, reset, new_data_valid, out_wr_en, stride, window_valid, in_rd_en;
    logic [8:0][7:0] window;

    window #(
        .DATA_WIDTH(8),
        .MAXIMUM_SIZE(9),
        .MAXIMUM_INPUT_SIZE(224*2 + 3)
    )top_inst(
        .new_data(newData),
        .clock(clock),
        .reset(reset),
        .new_data_valid(new_data_valid),
        .out_wr_en(out_wr_en),
        .stride(stride),
        .window_dim(window_dim),
        .input_dim(input_dim),
        .window_valid(window_valid),
        .in_rd_en(in_rd_en),
        .output_window(window)
    );

    always #10 clock = ~clock;

    initial begin

        clock = 1;
        newData = 1;
        reset = 1;
        new_data_valid = 1;
        out_wr_en = 1;
        stride = 0;
        window_dim = 3;
        input_dim = 224;
        #20;
        reset = 0;
        for (int i = 0; i < 1024; i = i + 1) begin
            newData = i + 2;
            #20;
        end
        #100;
        //Test stride
        reset = 1;
        #20;
        reset = 0;
        stride = 1;
        for (int i = 0; i < 1024; i = i + 1) begin
            newData = i + 2;
            #20;
        end
        #20;
        reset = 1;
        stride = 0;
        new_data_valid = 0;
        newData = 0;
        #20;
        //Test Thrashing of output
        reset = 0;
        for (int i = 0; i < 1024; i = i + 1) begin
            out_wr_en = 1;
            new_data_valid = 1;
            newData = i +  1;
            #20;
            out_wr_en = 0;
            new_data_valid = 0;
            #20;
        end
        $finish;

    end

endmodule