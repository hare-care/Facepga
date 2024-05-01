`timescale 1ns/1ns

module resizer_tb_img();

    localparam string IMG_IN_NAME = "tracksCameraCrop.bmp";
    localparam string IMG_OUT_NAME = "resizerOut.bmp";
    localparam string IMG_CMP_NAME = "tracksResizerCrop.bmp";
    localparam CLOCK_PERIOD = 10;

    logic clock = 1'b1;
    logic reset = 0;
    logic start = 0;
    logic done = 0;

    logic in_full;
    logic in_wr_en = 0;
    logic [23:0] in_din;
    
    logic out_rd_en;
    logic out_empty;
    logic [7:0]out_dout;

    logic   hold_clock    = '0;
    logic   in_write_done = '0;
    logic   out_read_done = '0;
    integer out_errors    = '0;

    localparam IM_WIDTH = 480;
    localparam IM_HEIGHT = 640;
    localparam BMP_HEADER_SIZE = 54;
    localparam BYTES_PER_PIXEL = 3;
    localparam BMP_DATA_SIZE = IM_WIDTH*IM_HEIGHT*BYTES_PER_PIXEL;

    logic [23:0] newPixelData;
    logic newPixelValid, startNewImage, endOfImage, outPixelValid;
    logic [7:0] red, green, blue;
    resizer resizer_inst (
        .clock(clock),
        .reset(reset),
        .newPixelData(newPixelData),
        .newPixelValid(newPixelValid),
        .startNewImage(startNewImage),
        .endOfImage(endOfImage),
        .outRed(red),
        .outGreen(green),
        .outBlue(blue),
        .outPixelValid(outPixelValid)
    );

    always begin
        clock = 1'b1;
        #(CLOCK_PERIOD/2);
        clock = 1'b0;
        #(CLOCK_PERIOD/2);
    end

    initial begin
        @(posedge clock);
        reset = 1'b1;
        @(posedge clock);
        reset = 1'b0;
    end

    initial begin : tb_process

        longint unsigned start_time, end_time;
        @(negedge reset);
        @(posedge clock);
        start_time = $time;
        // start
        $display("@ %0t: Beginning simulation...", start_time);
        startNewImage = 1'b1;
        @(posedge clock);
        startNewImage = 1'b0;

        wait(out_read_done);
        end_time = $time;
        // report metrics
        $display("@ %0t: Simulation completed.", end_time);
        $display("Total simulation cycle count: %0d", (end_time-start_time)/CLOCK_PERIOD);
        $display("Total error count: %0d", out_errors);
        // end the simulation
        $finish;
    end

    initial begin : read_process

        int i, r, cnt;
        int in_file;
        logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];

        @(negedge reset);
        $display("@ %0t: Loading file %s...", $time, IMG_IN_NAME);

        in_file = $fopen(IMG_IN_NAME, "rb");
        newPixelValid = 1'b0;

        // Skip BMP header
        r = $fread(bmp_header, in_file, 0, BMP_HEADER_SIZE);

        // Read data from image file
        i = 0;
        cnt = 0;
        while ( i < BMP_DATA_SIZE ) begin
            @(negedge clock);
            newPixelValid = 1'b0;
            r = $fread(newPixelData, in_file, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
            newPixelValid = 1'b1;
            i += 1;
        end

        @(negedge clock);
        newPixelValid = 1'b0;
        $fclose(in_file);
        in_write_done = 1'b1;
    end

    initial begin : img_write_process
        int i, r, j, ct;
        int out_file;
        int cmp_file;
        logic [23:0] cmp_dout;
        logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];
        logic [31:0] absval;
        logic [7:0] wrchar;

        @(negedge reset);
        @(negedge clock);

        $display("@ %0t: Comparing file %s...", $time, IMG_OUT_NAME);
        
        out_file = $fopen(IMG_OUT_NAME, "wb");
        cmp_file = $fopen(IMG_CMP_NAME, "rb");
        out_rd_en = 1'b0;
        
        // Copy the BMP header
        r = $fread(bmp_header, cmp_file, 0, BMP_HEADER_SIZE);
        for (i = 0; i < BMP_HEADER_SIZE; i++) begin
            if (i == 18 || i == 22) begin
                $fwrite(out_file, "%c", 8'he0);
            end else begin
                $fwrite(out_file, "%c", bmp_header[i]);
            end
        end
        i = 0; 
        ct = 0;
        while (endOfImage == 0) begin
            @(negedge clock);
            if (outPixelValid == 1) begin
                ct ++;
                r = $fread(cmp_dout, cmp_file, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
                $fwrite(out_file, "%c%c%c",blue, green, red);
                if (cmp_dout != {blue,green,red}) begin
                    out_errors += 1;
                    $write("@ %0t: %s(%0d): ERROR: %x != %x at address 0x%x.\n", $time, IMG_OUT_NAME, i+1, {blue,green,red}, cmp_dout, i);
                end
                //$write("Pixel Written to x: %0d, y: %0d ct: %0d\n", (i/3)%224, (i/3)/224, ct);
                out_rd_en = 1'b1;
                i += BYTES_PER_PIXEL;
                j ++;
            end
        end
        @(negedge clock);

        $fclose(out_file);
        $fclose(cmp_file);
        out_read_done = 1'b1;
    end

endmodule