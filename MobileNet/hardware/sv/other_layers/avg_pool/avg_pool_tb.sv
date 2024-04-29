`timescale 1ns/1ns

module avg_pool_tb();

logic clock, reset, done, newPointValid;
logic [31:0] newPointData, average;

avg_pool avg_pool_inst(
    .clock(clock),
    .reset(reset),
    .newPointData(newPointData),
    .newPointValid(newPointValid),
    .done(done),
    .average(average)
);

always #10 clock = ~clock;

initial begin
    clock = 1;
    reset = 1;
    newPointData = 0;
    newPointValid = 0;
    #10 reset = 0;
    #10;
    for (int i = 1; i < 300; i ++) begin
        newPointValid = 1;
        newPointData = i;
        #20;
    end
    $finish;
end

endmodule