`timescale 1ns/1ns

module fc_tb();

logic clock, reset, start, ops_valid, weights_valid, biases_valid, done_out, calculating;
logic [31:0] data_in;
logic [31:0] result;

fc #(
    .DATA_WIDTH(8),
    .FC_TOTAL_COUNT(1024)
) fc_inst (
    .clock(clock),
    .reset(reset),
    .new_data(data_in),
    .ops_valid(ops_valid),
    .weights_valid(weights_valid),
    .biases_valid(biases_valid),
    .start(start),
    .result(result),
    .in_rd_en(calculating),
    .done_out(done_out)
);

always #10 clock = ~clock;
int i;
logic [7:0] val1,val2,val3,val4;

initial begin

    clock = 1;
    reset = 1;
    start = 0;
    #20;
    reset = 0;
    start = 1;
    i = 0;
    while (i < 1024 * 3) begin //Data streaming in
        val1 = 1;
        val2 = 2;
        val3 = 3;
        val4 = 4;
        weights_valid = 0;
        biases_valid = 0;
        ops_valid = 0;
        data_in = {val4,val3,val2,val1};
        if (calculating == 0) begin
            if (i%3 == 0) begin
                weights_valid = 1;
            end else if (i % 3 == 1) begin
                biases_valid = 1;
            end else begin
                ops_valid = 1;
            end
        i++;
        end
        #20;
    end
    #100;
    $finish;

end


endmodule