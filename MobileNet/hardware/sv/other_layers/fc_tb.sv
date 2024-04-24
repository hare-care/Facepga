`timescale 1ns/1ns

module fc_tb();

logic clock, reset, start, data_valid, done_out;
logic [9:0][7:0] weights, operands, biases;
logic [31:0] result;

fc #(
    .DATA_WIDTH(8),
    .OPS_PER_CYCLE(10),
    .FC_TOTAL_COUNT(1024)
) fc_inst (
    .clock(clock),
    .reset(reset),
    .operands(operands),
    .weights(weights),
    .biases(biases),
    .start(start),
    .data_valid(data_valid),
    .result(result),
    .done_out(done_out)
);

always #10 clock = ~clock;
int i;
initial begin

    clock = 1;
    reset = 1;
    operands = '{0,0,0,0,0,0,0,0,0,0};
    biases = 0;
    weights = '{0,0,0,0,0,0,0,0,0,0};
    start = 0;
    data_valid = 0;
    #20;
    reset = 0;
    start = 1;
    data_valid = 1;
    i = 0;
    while (i < 1024) begin //Data streaming in
        operands[i % 10] = i;
        weights[i%10] = (i + 3)%4;
        if (i % 10 == 9) begin
            data_valid = 1;
        end else begin
            data_valid = 0;
        end
        #20;
        i += 1;
    end
    for (i = 4; i < 10; i += 1) begin
        operands[i] = 0;
    end
    data_valid = 1;

    #100;
    $finish;

end


endmodule