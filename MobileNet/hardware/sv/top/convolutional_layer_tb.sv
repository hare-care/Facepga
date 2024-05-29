`timescale 1ns/1ns

module convolutional_layer_tb();

localparam IMG1_IN = "floor2.bmp";
localparam IMG2_IN = "bucket2.bmp";
localparam IMG3_IN = "smile2.bmp";
localparam IMG4_IN = "sleep2.bmp";
localparam IMG1_OUT = "floor2out.bmp";
localparam IMG2_OUT = "bucket2out.bmp";
localparam IMG3_OUT = "smile2out.bmp";
localparam IMG4_OUT = "sleep2out.bmp";
localparam IMGREF = "conv1bucket.bmp";
localparam CLOCK_PERIOD = 10;
localparam IM_WIDTH = 224;
localparam IM_HEIGHT = 224;
localparam BMP_HEADER_SIZE = 54;
localparam BYTES_PER_PIXEL = 3;
localparam BMP_DATA_SIZE = IM_WIDTH*IM_HEIGHT*BYTES_PER_PIXEL;


logic clock = 1'b1;
logic reset, stride, output_enable, input_valid, weights_valid, bias_valid, outputs_valid, idle, done;
logic [31:0] newDataPacket, result;
logic [7:0] input_dim = 224;
logic [1:0] window_dim = 3;
logic [23:0] pixel1, pixel2, pixel3, pixel4;
logic out_read_done = 0;


convolutional_layer #(
    .CNN_UNROLL_FACTOR(4),
    .CNN_DATA_WIDTH(8),
    .CNN_OP_PER_CYCLE(9)
) top_inst (
    .clock(clock),
    .reset(reset),
    .stride(0),
    .newDataPacket(newDataPacket),
    .inputDim(input_dim),
    .windowDim(window_dim),
    .output_enable(1),
    .input_valid(input_valid),
    .weights_valid(weights_valid),
    .bias_valid(bias_valid),
    .result(result),
    .outputs_valid(outputs_valid),
    .idle(idle),
    .imagesDone(done)
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
        wait(out_read_done);
        end_time = $time;
        $display("@ %0t: Simulation completed.", end_time);
        $display("Total simulation cycle count: %0d", (end_time-start_time)/CLOCK_PERIOD);
        $finish;
    end

initial begin : read_process

        int i, r1, r2, r3, r4;
        int cnt;
        int infile1, infile2, infile3, infile4;
        logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];
        @(negedge reset);
        $display("@ %0t: Loading file %s...", $time, IMG1_IN);
        infile1 = $fopen(IMG1_IN, "rb");
        infile2= $fopen(IMG2_IN, "rb");
        infile3 = $fopen(IMG3_IN, "rb");
        infile4 = $fopen(IMG4_IN, "rb");
        input_valid = 1'b0;
        weights_valid = 0;
        bias_valid = 0;
        // Skip BMP header
        r1 = $fread(bmp_header, infile1, 0, BMP_HEADER_SIZE);
        r2 = $fread(bmp_header, infile2, 0, BMP_HEADER_SIZE);
        r3 = $fread(bmp_header, infile3, 0, BMP_HEADER_SIZE);
        r4 = $fread(bmp_header, infile4, 0, BMP_HEADER_SIZE);
        cnt = 0;
        @(negedge clock);
        weights_valid = 1;
        newDataPacket = 32'h01010101;
        @(negedge clock);
        weights_valid = 1;
        newDataPacket = 32'h02020202;
        @(negedge clock);
        weights_valid = 1;
        newDataPacket = 32'h01010101;
        @(negedge clock);
        weights_valid = 1;
        newDataPacket = 32'h00000000;
        @(negedge clock);
        weights_valid = 1;
        newDataPacket = 32'h00000000;
        @(negedge clock);
        weights_valid = 1;
        newDataPacket = 32'h00000000;
        @(negedge clock);
        weights_valid = 1;
        newDataPacket = 32'hFFFFFFFF;
        @(negedge clock);
        weights_valid = 1;
        newDataPacket = 32'hFEFEFEFE;
        @(negedge clock);
        weights_valid = 1;
        newDataPacket = 32'hFFFFFFFF;
        @(negedge clock);
        bias_valid = 1;
        weights_valid = 0;
        newDataPacket = 32'h00000000;
        @(negedge clock);
        bias_valid = 1;
        newDataPacket = 32'h00000000;
        @(negedge clock);
        bias_valid = 1;
        newDataPacket = 32'h00000000;
        @(negedge clock);
        bias_valid = 1;
        newDataPacket = 32'h00000000;
        @(negedge clock);
        bias_valid = 1;
        newDataPacket = 32'h00000000;
        @(negedge clock);
        bias_valid = 1;
        newDataPacket = 32'h00000000;
        @(negedge clock);
        bias_valid = 1;
        newDataPacket = 32'h00000000;
        @(negedge clock);
        bias_valid = 1;
        newDataPacket = 32'h00000000;
        @(negedge clock);
        bias_valid = 1;
        newDataPacket = 32'h00000000;
        @(negedge clock);
        bias_valid = 0;
        // Read data from image file
        i = 0;

        while ( i < BMP_DATA_SIZE ) begin
            @(negedge clock);
            bias_valid = 0;
            input_valid = 1'b0;
            if (idle == 1'b1) begin
                cnt ++;
                
                    r1 = $fread(pixel1, infile1, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
                    r2 = $fread(pixel2, infile2, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
                    r3 = $fread(pixel3, infile3, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
                    r4 = $fread(pixel4, infile4, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
                    newDataPacket = {pixel1[7:0],pixel2[7:0],pixel3[7:0],pixel4[7:0]};
              
                     input_valid = 1'b1;
         
                   
                    i += 3;
        
            end
        end

        @(negedge clock);
        input_valid = 1'b0;
        $fclose(infile1);
        $fclose(infile2);
        $fclose(infile3);
        $fclose(infile4);
    end

    initial begin : img_write_process
        int i, r, j, ct;
        int outfile1, outfile2, outfile3, outfile4, reffile;
        int cmp_file;
        logic [23:0] cmp_dout;
        logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];
        logic [31:0] absval1, absval2, absval3, absval4;
        logic [7:0] wrchar;

        @(negedge reset);
        @(negedge clock);
        
        outfile1 = $fopen(IMG1_OUT, "wb");
        outfile2 = $fopen(IMG2_OUT, "wb");
        outfile3 = $fopen(IMG3_OUT, "wb");
        outfile4 = $fopen(IMG4_OUT, "wb");
        reffile = $fopen(IMGREF, "rb");
  
        r = $fread(bmp_header, reffile, 0, BMP_HEADER_SIZE);
        
        for (i = 0; i < BMP_HEADER_SIZE; i++) begin
            $fwrite(outfile1, "%c", bmp_header[i]);
            $fwrite(outfile2, "%c", bmp_header[i]);
            $fwrite(outfile3, "%c", bmp_header[i]);
            $fwrite(outfile4, "%c", bmp_header[i]);
        end
        j = IM_WIDTH + 1;
        i = 0; 
        ct = 0;
        while (done == 0) begin
            @(negedge clock);
            if (outputs_valid == 1) begin
                ct += 1;
                absval1 = ($signed(result[7:0]) > 0) ? result[7:0] : -1 * result[7:0];
                absval2 = ($signed(result[15:8]) > 0) ? result[15:8] : -1 * result[15:8];
                absval3 = ($signed(result[23:16]) > 0) ? result[23:16] : -1 * result[23:16];
                absval4 = ($signed(result[31:24]) > 0) ? result[31:24] : -1 * result[31:24];
                $fwrite(outfile1, "%c%c%c", absval4[7:0], absval4[7:0], absval4[7:0]);
                $fwrite(outfile2, "%c%c%c", absval3[7:0], absval3[7:0], absval3[7:0]);
                $fwrite(outfile3, "%c%c%c", absval2[7:0], absval2[7:0], absval2[7:0]);
                $fwrite(outfile4, "%c%c%c", absval1[7:0], absval1[7:0], absval1[7:0]);
                $write("WRITE%0d: %0x\n",ct,result[7:0]);
                i += BYTES_PER_PIXEL;
                j ++;
            end
        end
        $write("%d elements written\n",j);
        @(negedge clock);
        output_enable = 1'b0;
        $fclose(outfile1);
        $fclose(outfile2);
        $fclose(outfile3);
        $fclose(outfile4);
        $fclose(reffile);
        out_read_done = 1;

    end



endmodule