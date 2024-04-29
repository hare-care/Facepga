`timescale 1ns/1ns

module resizer_tb();

logic clock, reset, newPixelValid, startNewImage, endOfImage, outPixelValid;
logic [23:0] newPixelData;
logic [7:0] r, g, b;

resizer resizer_inst(
    .clock(clock),
    .reset(reset),
    .newPixelData(newPixelData),
    .newPixelValid(newPixelValid),
    .startNewImage(startNewImage),
    .endOfImage(endOfImage),
    .outRed(r),
    .outBlue(g),
    .outGreen(b),
    .outPixelValid(outPixelValid)
);

always #10 clock = ~clock;

initial begin
    clock = 1;
    reset = 1;
    newPixelData = 0;
    newPixelValid = 0;
    startNewImage = 0;
    #10;
    reset = 0;
    #10;
    startNewImage = 1;
    #20;
    for (int i = 0; i < 480; i ++) begin
        for (int j = 0; j < 640; j ++) begin
            newPixelData[7:0] = j;
            newPixelData[15:8] = j + 5;
            newPixelData[23:16] = j + 10;
            newPixelValid = 1;
            #20;
        end
    end
    $finish;
end


endmodule