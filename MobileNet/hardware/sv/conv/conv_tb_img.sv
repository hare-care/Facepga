`timescale 1ns/1ns

module conv_tb_img();

    localparam string IMG_IN_NAME = "gray.bmp";
    localparam string IMG_OUT_NAME = "conv_compelete.bmp";
    localparam string IMG_CMP_NAME = "cppOut.bmp";
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

    localparam IM_WIDTH = 224;
    localparam IM_HEIGHT = 224;
    localparam BMP_HEADER_SIZE = 54;
    localparam BYTES_PER_PIXEL = 3;
    localparam BMP_DATA_SIZE = IM_WIDTH*IM_HEIGHT*BYTES_PER_PIXEL;

    logic stride, idle, resultValid,out_accepting_values,new_data_valid;
    logic [8:0][7:0] weights, biases;
    logic [31:0] result;
    logic [7:0] newPixelData;
    logic [1:0] window_dim;
    logic [7:0] input_dim;
    logic weights_valid, bias_valid;
    logic imageDone;
    assign stride = 0;
    assign input_dim = 224;
    assign window_dim = 3;
    assign out_accepting_values = 1;
    conv #(
        .DATA_WIDTH(8),
        .MULT_PER_CYCLE(9)
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
        .new_data_valid(new_data_valid),
        .imageDone(imageDone)
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
        start = 1'b1;
        @(posedge clock);
        start = 1'b0;

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
        new_data_valid = 1'b0;

        // Skip BMP header
        r = $fread(bmp_header, in_file, 0, BMP_HEADER_SIZE);
        @(negedge clock);
        weights_valid = 1;
        newPixelData = 1;
        @(negedge clock);
        weights_valid = 1;
        newPixelData = 2;
        @(negedge clock);
        weights_valid = 1;
        newPixelData = 1;
        @(negedge clock);
        weights_valid = 1;
        newPixelData = 0;
         @(negedge clock);
        weights_valid = 1;
        newPixelData = 0;
         @(negedge clock);
        weights_valid = 1;
        newPixelData = 0;
         @(negedge clock);
        weights_valid = 1;
        newPixelData = -1;
         @(negedge clock);
        weights_valid = 1;
        newPixelData = -2;
         @(negedge clock);
        weights_valid = 1;
        newPixelData = -1;
         @(negedge clock);
         weights_valid = 0;
        bias_valid = 1;
        newPixelData = 0;
         @(negedge clock);
        bias_valid = 1;
        newPixelData = 0;
         @(negedge clock);
        bias_valid = 1;
        newPixelData = 0;
         @(negedge clock);
        bias_valid = 1;
        newPixelData = 0;
         @(negedge clock);
        bias_valid = 1;
        newPixelData = 0;
         @(negedge clock);
        bias_valid = 1;
        newPixelData = 0;
         @(negedge clock);
        bias_valid = 1;
        newPixelData = 0;
         @(negedge clock);
        bias_valid = 1;
        newPixelData = 0;
         @(negedge clock);
        bias_valid = 1;
        newPixelData = 0;

        // Read data from image file
        i = 0;
        cnt = 0;
        while ( i < BMP_DATA_SIZE ) begin
            @(negedge clock);
            bias_valid = 0;
            new_data_valid = 1'b0;
            if (idle == 1'b1) begin
                cnt ++;
                r = $fread(newPixelData, in_file, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
                if (cnt % 3 == 1) begin
                    new_data_valid = 1'b1;
                end
                i += 1;
            end
        end

        @(negedge clock);
        new_data_valid = 1'b0;
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
            $fwrite(out_file, "%c", bmp_header[i]);
        end

        
        j = IM_WIDTH + 1;
        i = 0; 
        ct = 0;
        while (imageDone == 0) begin
            @(negedge clock);
            out_rd_en = 1'b0;
           
            if (resultValid == 1) begin
                ct += 1;
                r = $fread(cmp_dout, cmp_file, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
                absval = ($signed(result) > 0) ? result : -1 * result;
                wrchar = absval;
                $fwrite(out_file, "%c%c%c", wrchar, wrchar, wrchar);
                if (cmp_dout != {3{wrchar}}) begin
                out_errors += 1;
                $write("@ %0t: %s(%0d): ERROR: %x != %x at address 0x%x.\n", $time, IMG_OUT_NAME, i+1, {3{wrchar}}, cmp_dout, i);
               // $write("Pixel Written to x: %0d, y: %0d\n", (i/3)%IM_WIDTH, (i/3)/IM_WIDTH);
                end
                out_rd_en = 1'b1;
                i += BYTES_PER_PIXEL;
                j ++;
            end
        end
        $write("%d elements written\n",j);
        @(negedge clock);
        out_rd_en = 1'b0;
        $fclose(out_file);
        $fclose(cmp_file);
        out_read_done = 1'b1;
    end

endmodule