`timescale 1ns/1ns

module resizer #(
    parameter DATA_WIDTH = 24,
    parameter INPUT_WIDTH = 640,
    parameter INPUT_HEIGHT = 480,
    parameter VERT_CROP_COUNT = 16,
    parameter HORIZ_CROP_COUNT = 96,
    parameter OUT_DIM = 224
)(
    input logic                         clock,
    input logic                         reset,
    input logic [DATA_WIDTH - 1:0]      newPixelData,
    input logic                         newPixelValid,
    input logic                         startNewImage,
    output logic                        endOfImage,
    output logic [7:0]                  outRed,
    output logic [7:0]                  outGreen,
    output logic [7:0]                  outBlue,
    output logic                        outPixelValid
);

localparam BOTTOM_CROP = INPUT_HEIGHT - VERT_CROP_COUNT ;
localparam LEFT_CROP = HORIZ_CROP_COUNT - 2; // Comparing next value which is curr ++
localparam RIGHT_CROP = INPUT_WIDTH - HORIZ_CROP_COUNT - 2;
localparam TOP_CROP = VERT_CROP_COUNT - 1;

typedef enum logic[1:0] {idle, crop, resize, done} resizerState;
resizerState state_c, state_s;

logic cropCounter_c, cropCounter_s; //Get 2x2 before outputting data
logic [10:0] rowCounter_c, rowCounter_s;
logic [10:0] colCounter_c, colCounter_s;
logic [OUT_DIM-1:0][9:0] rTotal_c, rTotal_s , bTotal_c, bTotal_s , gTotal_c, gTotal_s; //8 + 3 bits

always_comb begin
    state_c = state_s;
    rowCounter_c = rowCounter_s;
    colCounter_c = colCounter_s;
    rTotal_c = rTotal_s;
    gTotal_c = gTotal_s;
    bTotal_c = bTotal_s;
    cropCounter_c = cropCounter_s;
    outBlue = 0;
    outGreen = 0;
    outRed = 0;
    endOfImage = 0;
    outPixelValid = 0;
    case (state_s)
    idle: begin
        if (startNewImage == 1) begin
            state_c = crop;
        end
    end
    crop: begin
        //Only transition to resize when next pixel is in the boundary
        if (rowCounter_s > TOP_CROP && rowCounter_s < BOTTOM_CROP) begin
        //Within resizable rows
            if (colCounter_s > LEFT_CROP && colCounter_s < RIGHT_CROP) begin
                state_c = resize;
                cropCounter_c = 0;
            end
        end
        outPixelValid = 0;
    end
    resize: begin
        if (newPixelValid == 1) begin
            cropCounter_c = ~cropCounter_s;
            if (rowCounter_s[0] == 1) begin //Second half
                if (cropCounter_s == 1) begin //Last of four
                    outRed = (rTotal_s[(colCounter_s - HORIZ_CROP_COUNT)/2] + newPixelData[7:0]) >> 2;
                    outGreen = (gTotal_s[(colCounter_s - HORIZ_CROP_COUNT)/2] + newPixelData[15:8]) >> 2;
                    outBlue = (bTotal_s[(colCounter_s - HORIZ_CROP_COUNT)/2] + newPixelData[23:16]) >> 2;
                    rTotal_c[(colCounter_s - HORIZ_CROP_COUNT)/2] = 0;
                    gTotal_c[(colCounter_s - HORIZ_CROP_COUNT)/2] = 0;
                    bTotal_c[(colCounter_s - HORIZ_CROP_COUNT)/2] = 0;
                    outPixelValid = 1;
                end else begin //Third
                    rTotal_c[(colCounter_s - HORIZ_CROP_COUNT)/2] = rTotal_s[(colCounter_s - HORIZ_CROP_COUNT)/2] + newPixelData[7:0];
                    gTotal_c[(colCounter_s - HORIZ_CROP_COUNT)/2] = gTotal_s[(colCounter_s - HORIZ_CROP_COUNT)/2] + newPixelData[15:8];
                    bTotal_c[(colCounter_s - HORIZ_CROP_COUNT)/2] = bTotal_s[(colCounter_s - HORIZ_CROP_COUNT)/2] + newPixelData[23:16];
                end
            end else begin //first half
                rTotal_c[(colCounter_s - HORIZ_CROP_COUNT)/2] = rTotal_s[(colCounter_s - HORIZ_CROP_COUNT)/2] + newPixelData[7:0];
                gTotal_c[(colCounter_s - HORIZ_CROP_COUNT)/2] = gTotal_s[(colCounter_s - HORIZ_CROP_COUNT)/2] + newPixelData[15:8];
                bTotal_c[(colCounter_s - HORIZ_CROP_COUNT)/2] = bTotal_s[(colCounter_s - HORIZ_CROP_COUNT)/2] + newPixelData[23:16];
            end
        end
        //Check for exit conditions
        if (colCounter_s > RIGHT_CROP) begin
            if (rowCounter_s >= BOTTOM_CROP - 1) begin
                state_c = done;
            end else begin
                state_c = crop;
            end
        end
    end
    done: begin
        endOfImage = 1;
        state_c = idle;
    end
    default: begin
        state_c = idle;
    end
    endcase
    //Coordinate tracking logic
    if (newPixelValid == 1) begin
        if (colCounter_s == INPUT_WIDTH - 1) begin
            colCounter_c = 0;
            rowCounter_c = rowCounter_s + 1;
        end else begin
            colCounter_c = colCounter_s + 1;
        end
    end

end

always_ff @(posedge clock, posedge reset) begin
    if (reset == 1) begin
        state_s <= idle;
        cropCounter_s <= 0;
        rowCounter_s <= 0;
        colCounter_s <= 0;
        rTotal_s <= 0;
        gTotal_s <= 0;
        bTotal_s <= 0;
    end else begin
        state_s <= state_c;
        rowCounter_s <= rowCounter_c;
        colCounter_s <= colCounter_c;
        cropCounter_s <= cropCounter_c;
        rTotal_s <= rTotal_c;
        gTotal_s <= gTotal_c;
        bTotal_s <= bTotal_c;
    end
end


endmodule