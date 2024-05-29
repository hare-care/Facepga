`timescale  1ns/1ns

module top_tb();

    localparam inputFile1 = "./assets/bucket2.bmp";
    localparam inputFile2 = "./assets/floor2.bmp";
    localparam inputFile3 = "./assets/smile2.bmp";
    localparam inputFile4 = "./assets/sleep2.bmp";
    localparam conv1File1 = "./results1/bucket2conv1.bmp";
    localparam conv1File2 = "./results1/floor2conv1.bmp";
    localparam conv1File3 = "./results1/smile2conv1.bmp";
    localparam conv1File4 = "./results1/sleep2conv1.bmp";
    localparam conv2File1 = "./results2/bucket2conv2.bmp";
    localparam conv2File2 = "./results2/floor2conv2.bmp";
    localparam conv2File3 = "./results2/smile2conv2.bmp";
    localparam conv2File4 = "./results2/sleep2conv2.bmp";
    localparam conv3File1 = "./results3/bucket2conv3.bmp";
    localparam conv3File2 = "./results3/floor2conv3.bmp";
    localparam conv3File3 = "./results3/smile2conv3.bmp";
    localparam conv3File4 = "./results3/sleep2conv3.bmp";
    localparam conv4File1 = "./results4/bucket2conv4.bmp";
    localparam conv4File2 = "./results4/floor2conv4.bmp";
    localparam conv4File3 = "./results4/smile2conv4.bmp";
    localparam conv4File4 = "./results4/sleep2conv4.bmp";
    localparam avgPool1 = "./results5/avgPoolResult";
    localparam refFile = "./assets/conv1bucket.bmp";
    localparam CLOCK_PERIOD = 10;
    localparam IM_WIDTH_1 = 224;
    localparam IM_HEIGHT_1 = 224;
    localparam IM_WIDTH_2 = 112;
    localparam IM_HEIGHT_2 = 112;
    localparam IM_WIDTH_3 = 56;
    localparam IM_HEIGHT_3 = 56;
    localparam BMP_HEADER_SIZE = 54;
    localparam BYTES_PER_PIXEL = 3;
    localparam BMP_DATA_SIZE_1 = IM_WIDTH_1*IM_HEIGHT_1*BYTES_PER_PIXEL;
    localparam BMP_DATA_SIZE_2 = IM_WIDTH_2*IM_HEIGHT_2*BYTES_PER_PIXEL;
    localparam BMP_DATA_SIZE_3 = IM_WIDTH_3*IM_HEIGHT_3*BYTES_PER_PIXEL;
    localparam int Weights1[9] = {
        32'h01010101,
        32'h02020202,
        32'h01010101,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'hFFFFFFFF,
        32'hFEFEFEFE,
        32'hFFFFFFFF
    };
    localparam int Weights2[9] = {
        32'h01010101,
        32'h01010101,
        32'h01010101,
        32'h00000000,
        32'h00000000,
        32'h01010101,
        32'h01010101,
        32'h00000000,
        32'hFFFFFFFF
    };
    localparam int WeightsEmph[9] = {
        32'hFFFFFFFF,
        32'hFFFFFFFF,
        32'hFFFFFFFF,
        32'hFFFFFFFF,
        32'h08080808,
        32'hFFFFFFFF,
        32'hFFFFFFFF,
        32'hFFFFFFFF,
        32'hFFFFFFFF
    };
    localparam int WeightsCompress[9] = {
         32'h00000000,
         32'h00000000,
         32'h00000000,
         32'h00000000,
         32'h01010101,
         32'h00000000,
         32'h00000000,
         32'h00000000,
         32'h00000000
    };
    localparam int WeightsInvert[9] = {
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h01010101,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000
    };
    localparam int BiasZero[9] = {
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000
    };
    localparam int BiasInvert[9] = {
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'hF0F0F0F0,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000
    };
    
    logic clock;
    logic reset;
    logic [31:0] DDR3_Input, DDR3_Address, Processor_Result;
    logic Begin_Calc, Network_Output_Valid, Network_Done;
    logic DDR3_WE, DDR3_Input_Valid, InputEnable;
    logic [23:0] pixel1,pixel2,pixel3,pixel4;
    logic original_proc_done = 0;
    logic proc2_done = 0;
    logic proc3_done = 0;
    logic proc4_done = 0;

    processing_state_controller top_inst (
        .clock(clock),
        .reset(reset),
        .DDR3_Input(DDR3_Input),
        .Begin_Calc(Begin_Calc),
        .DDR3_Address(DDR3_Address),
        .DDR3_Input_Valid(DDR3_Input_Valid),
        .DDR3_WE(DDR3_WE),
        .Processor_Result(Processor_Result),
        .Network_Output_Valid(Network_Output_Valid),
        .Proc_Done(Network_Done),
        .Input_Enable(InputEnable)
    );

    always begin
        clock = 1'b1;
        #(CLOCK_PERIOD/2);
        clock = 1'b0;
        #(CLOCK_PERIOD/2);
    end

    initial begin
        @(negedge clock);
        reset = 1'b1;
        @(negedge clock);
        reset = 1'b0;
    end

    initial begin : tb_process

        longint unsigned start_time, end_time;
        @(negedge reset);
        @(negedge clock);
        start_time = $time;
        // start
        $display("@ %0t: Beginning simulation...", start_time);
        wait(Network_Done);
        end_time = $time;
        $display("@ %0t: Simulation completed.", end_time);
        $display("Total simulation cycle count: %0d", (end_time-start_time)/CLOCK_PERIOD);
        $finish;
    end

    initial begin : read_original

        int i, r1, r2, r3, r4;
        int cnt;
        int infile1, infile2, infile3, infile4;
        logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];
        @(negedge reset);
        $display("@ %0t: Loading files %s, %s, %s, %s...", $time, inputFile1, inputFile2, inputFile3, inputFile4);
        infile1 = $fopen(inputFile1, "rb");
        infile2= $fopen(inputFile2, "rb");
        infile3 = $fopen(inputFile3, "rb");
        infile4 = $fopen(inputFile4, "rb");
        DDR3_Input_Valid = 1'b0;
        // Skip BMP header
        r1 = $fread(bmp_header, infile1, 0, BMP_HEADER_SIZE);
        r2 = $fread(bmp_header, infile2, 0, BMP_HEADER_SIZE);
        r3 = $fread(bmp_header, infile3, 0, BMP_HEADER_SIZE);
        r4 = $fread(bmp_header, infile4, 0, BMP_HEADER_SIZE);
        cnt = 0;
        @(negedge clock);
        Begin_Calc = 1;
        for (i = 0; i < 9; i ++) begin
            @(negedge clock);
            Begin_Calc = 0;
            DDR3_Input = Weights1[i];
            DDR3_Input_Valid = 1;
        end
        for (i = 0; i < 9; i ++) begin
            @(negedge clock);
            DDR3_Input = BiasZero[i];
            DDR3_Input_Valid = 1;
        end
        // Read data from image file
        i = 0;
        while ( i < BMP_DATA_SIZE_1 ) begin
            @(negedge clock);
            DDR3_Input_Valid = 1'b0;
            if (InputEnable == 1'b1) begin
                cnt ++;
                r1 = $fread(pixel1, infile1, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
                r2 = $fread(pixel2, infile2, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
                r3 = $fread(pixel3, infile3, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
                r4 = $fread(pixel4, infile4, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
                DDR3_Input = {pixel1[7:0],pixel2[7:0],pixel3[7:0],pixel4[7:0]};
                DDR3_Input_Valid = 1'b1;
                i += 3;
            end
        end
        @(negedge clock);
        DDR3_Input_Valid = 1'b0;
        $fclose(infile1);
        $fclose(infile2);
        $fclose(infile3);
        $fclose(infile4);
    end

     initial begin : img_write_1
        int i, r, j, ct;
        int outfile1, outfile2, outfile3, outfile4, reffile;
        logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];
        logic [31:0] absval1, absval2, absval3, absval4;
        logic [7:0] wrchar;
        @(negedge reset);
        @(negedge clock);
        outfile1 = $fopen(conv1File1, "wb");
        outfile2 = $fopen(conv1File2, "wb");
        outfile3 = $fopen(conv1File3, "wb");
        outfile4 = $fopen(conv1File4, "wb");
        reffile = $fopen(refFile, "rb");
        r = $fread(bmp_header, reffile, 0, BMP_HEADER_SIZE);
        if (!(r && outfile1 && outfile2 && outfile3 && outfile4)) begin
            $write("OPEN ERRROR\n\n\n");
        end
        $write("RES: %0u\n%0u\n%0u\n%0u\n%0u\n",r,outfile1,outfile2,outfile3,outfile4);
        for (i = 0; i < BMP_HEADER_SIZE; i++) begin
            $fwrite(outfile1, "%c", bmp_header[i]);
            $fwrite(outfile2, "%c", bmp_header[i]);
            $fwrite(outfile3, "%c", bmp_header[i]);
            $fwrite(outfile4, "%c", bmp_header[i]);
        end
        j = IM_WIDTH_1 + 1;
        i = 0; 
        ct = 0;
        while (i < BMP_DATA_SIZE_1) begin
            @(negedge clock);
            if (Network_Output_Valid == 1) begin
                ct += 1;
                absval1 = ($signed(Processor_Result[7:0]) > 0) ? Processor_Result[7:0] : -1 * Processor_Result[7:0];
                absval2 = ($signed(Processor_Result[15:8]) > 0) ? Processor_Result[15:8] : -1 * Processor_Result[15:8];
                absval3 = ($signed(Processor_Result[23:16]) > 0) ? Processor_Result[23:16] : -1 * Processor_Result[23:16];
                absval4 = ($signed(Processor_Result[31:24]) > 0) ? Processor_Result[31:24] : -1 * Processor_Result[31:24];
                //if ((j % 226) != 100 & (j % 226) != 101) begin
                    $fwrite(outfile1, "%c%c%c", absval4[7:0], absval4[7:0], absval4[7:0]);
                    $fwrite(outfile2, "%c%c%c", absval3[7:0], absval3[7:0], absval3[7:0]);
                    $fwrite(outfile3, "%c%c%c", absval2[7:0], absval2[7:0], absval2[7:0]);
                    $fwrite(outfile4, "%c%c%c", absval1[7:0], absval1[7:0], absval1[7:0]);
                    //$write("WRITE%0d: %0x\n",ct,Processor_Result[7:0]);
                //end    
                i += BYTES_PER_PIXEL;
                j ++;
            end
        end
        $write("%d elements written\n",j);
        @(negedge clock);
        $fclose(outfile1);
        $fclose(outfile2);
        $fclose(outfile3);
        $fclose(outfile4);
        $fclose(reffile);
        original_proc_done = 1;
    end

    initial begin: img_read_2
        
        int i, r1, r2, r3, r4;
        int cnt;
        int infile1, infile2, infile3, infile4;
        logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];
        wait(original_proc_done);
        $display("@ %0t: Loading files %s, %s, %s, %s...", $time, conv1File1, conv1File2, conv1File3, conv1File4);
        infile1 = $fopen(conv1File1, "rb");
        infile2= $fopen(conv1File2, "rb");
        infile3 = $fopen(conv1File3, "rb");
        infile4 = $fopen(conv1File4, "rb");
        DDR3_Input_Valid = 1'b0;
        // Skip BMP header
        r1 = $fread(bmp_header, infile1, 0, BMP_HEADER_SIZE);
        r2 = $fread(bmp_header, infile2, 0, BMP_HEADER_SIZE);
        r3 = $fread(bmp_header, infile3, 0, BMP_HEADER_SIZE);
        r4 = $fread(bmp_header, infile4, 0, BMP_HEADER_SIZE);
        cnt = 0;
        for (i = 0; i < 9; i ++) begin
            @(negedge clock);
            Begin_Calc = 0;
            DDR3_Input = WeightsInvert[i];
            DDR3_Input_Valid = 1;
        end
        for (i = 0; i < 9; i ++) begin
            @(negedge clock);
            DDR3_Input = BiasInvert[i];
            DDR3_Input_Valid = 1;
        end
        // Read data from image file
        i = 0;
        while ( i < BMP_DATA_SIZE_1 ) begin
            @(negedge clock);
            DDR3_Input_Valid = 1'b0;
            if (InputEnable == 1'b1) begin
                cnt ++;
                r1 = $fread(pixel1, infile1, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
                r2 = $fread(pixel2, infile2, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
                r3 = $fread(pixel3, infile3, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
                r4 = $fread(pixel4, infile4, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
                DDR3_Input = {pixel1[7:0],pixel2[7:0],pixel3[7:0],pixel4[7:0]};
                DDR3_Input_Valid = 1'b1;
                i += 3;
            end
        end
        @(negedge clock);
        DDR3_Input_Valid = 1'b0;
        $fclose(infile1);
        $fclose(infile2);
        $fclose(infile3);
        $fclose(infile4);
        end

    initial begin : img_write_2
        int i, r, j, ct;
        int outfile1, outfile2, outfile3, outfile4, reffile;
        logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];
        logic [31:0] absval1, absval2, absval3, absval4;
        logic [7:0] wrchar;
        wait(original_proc_done);
        @(negedge clock);
        outfile1 = $fopen(conv2File1, "wb");
        outfile2 = $fopen(conv2File2, "wb");
        outfile3 = $fopen(conv2File3, "wb");
        outfile4 = $fopen(conv2File4, "wb");
        reffile = $fopen(refFile, "rb");
        r = $fread(bmp_header, reffile, 0, BMP_HEADER_SIZE);
        if (!(r && outfile1 && outfile2 && outfile3 && outfile4)) begin
            $write("OPEN ERRROR\n\n\n");
        end
        $write("RES: %0u\n%0u\n%0u\n%0u\n%0u\n",r,outfile1,outfile2,outfile3,outfile4);
        for (i = 0; i < BMP_HEADER_SIZE; i++) begin
            $fwrite(outfile1, "%c", bmp_header[i]);
            $fwrite(outfile2, "%c", bmp_header[i]);
            $fwrite(outfile3, "%c", bmp_header[i]);
            $fwrite(outfile4, "%c", bmp_header[i]);
        end
        j = IM_WIDTH_1 + 1;
        i = 0; 
        ct = 0;
        while (i < BMP_DATA_SIZE_1) begin
            @(negedge clock);
            if (Network_Output_Valid == 1) begin
                ct += 1;
                absval1 = ($signed(Processor_Result[7:0]) > 0) ? Processor_Result[7:0] : -1 * Processor_Result[7:0];
                absval2 = ($signed(Processor_Result[15:8]) > 0) ? Processor_Result[15:8] : -1 * Processor_Result[15:8];
                absval3 = ($signed(Processor_Result[23:16]) > 0) ? Processor_Result[23:16] : -1 * Processor_Result[23:16];
                absval4 = ($signed(Processor_Result[31:24]) > 0) ? Processor_Result[31:24] : -1 * Processor_Result[31:24];
                //if ((j % 226) != 100 & (j % 226) != 101) begin
                    $fwrite(outfile1, "%c%c%c", absval4[7:0], absval4[7:0], absval4[7:0]);
                    $fwrite(outfile2, "%c%c%c", absval3[7:0], absval3[7:0], absval3[7:0]);
                    $fwrite(outfile3, "%c%c%c", absval2[7:0], absval2[7:0], absval2[7:0]);
                    $fwrite(outfile4, "%c%c%c", absval1[7:0], absval1[7:0], absval1[7:0]);
                    //$write("WRITE%0d: %0x\n",ct,Processor_Result[7:0]);
                //end    
                i += BYTES_PER_PIXEL;
                j ++;
            end
        end
        $write("%d elements written\n",j);
        @(negedge clock);
        $fclose(outfile1);
        $fclose(outfile2);
        $fclose(outfile3);
        $fclose(outfile4);
        $fclose(reffile);
        proc2_done = 1;
    end

    initial begin: img_read_3
        
        int i, r1, r2, r3, r4;
        int cnt;
        int infile1, infile2, infile3, infile4;
        logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];
        wait(proc2_done);
        $display("@ %0t: Loading files %s, %s, %s, %s...", $time, conv2File1, conv2File2, conv2File3, conv2File4);
        infile1 = $fopen(conv2File1, "rb");
        infile2= $fopen(conv2File2, "rb");
        infile3 = $fopen(conv2File3, "rb");
        infile4 = $fopen(conv2File4, "rb");
        DDR3_Input_Valid = 1'b0;
        // Skip BMP header
        r1 = $fread(bmp_header, infile1, 0, BMP_HEADER_SIZE);
        r2 = $fread(bmp_header, infile2, 0, BMP_HEADER_SIZE);
        r3 = $fread(bmp_header, infile3, 0, BMP_HEADER_SIZE);
        r4 = $fread(bmp_header, infile4, 0, BMP_HEADER_SIZE);
        cnt = 0;
        for (i = 0; i < 9; i ++) begin
            @(negedge clock);
            Begin_Calc = 0;
            DDR3_Input = WeightsCompress[i];
            DDR3_Input_Valid = 1;
        end
        for (i = 0; i < 9; i ++) begin
            @(negedge clock);
            DDR3_Input = BiasZero[i];
            DDR3_Input_Valid = 1;
        end
        // Read data from image file
        i = 0;
        while ( i < BMP_DATA_SIZE_1 ) begin
            @(negedge clock);
            DDR3_Input_Valid = 1'b0;
            if (InputEnable == 1'b1) begin
                cnt ++;
                r1 = $fread(pixel1, infile1, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
                r2 = $fread(pixel2, infile2, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
                r3 = $fread(pixel3, infile3, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
                r4 = $fread(pixel4, infile4, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
                DDR3_Input = {pixel1[7:0],pixel2[7:0],pixel3[7:0],pixel4[7:0]};
                DDR3_Input_Valid = 1'b1;
                i += 3;
            end
        end
        @(negedge clock);
        DDR3_Input_Valid = 1'b0;
        $fclose(infile1);
        $fclose(infile2);
        $fclose(infile3);
        $fclose(infile4);
        end

     initial begin : img_write_3
        int i, r, j, ct;
        int outfile1, outfile2, outfile3, outfile4, reffile;
        logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];
        logic [31:0] absval1, absval2, absval3, absval4;
        logic [7:0] wrchar;
        wait(proc2_done);
        @(negedge clock);
        outfile1 = $fopen(conv3File1, "wb");
        outfile2 = $fopen(conv3File2, "wb");
        outfile3 = $fopen(conv3File3, "wb");
        outfile4 = $fopen(conv3File4, "wb");
        reffile = $fopen(refFile, "rb");
        r = $fread(bmp_header, reffile, 0, BMP_HEADER_SIZE);
        if (!(r && outfile1 && outfile2 && outfile3 && outfile4)) begin
            $write("OPEN ERRROR\n\n\n");
        end
        $write("RES: %0u\n%0u\n%0u\n%0u\n%0u\n",r,outfile1,outfile2,outfile3,outfile4);
        for (i = 0; i < BMP_HEADER_SIZE; i++) begin
            if (i == 18 || i == 22) begin
                $fwrite(outfile1, "%c", $unsigned(bmp_header[i])/2);
                $fwrite(outfile2, "%c", $unsigned(bmp_header[i])/2);
                $fwrite(outfile3, "%c", $unsigned(bmp_header[i])/2);
                $fwrite(outfile4, "%c", $unsigned(bmp_header[i])/2);
            end else begin
                $fwrite(outfile1, "%c", bmp_header[i]);
                $fwrite(outfile2, "%c", bmp_header[i]);
                $fwrite(outfile3, "%c", bmp_header[i]);
                $fwrite(outfile4, "%c", bmp_header[i]);
            end
        end
        j = IM_WIDTH_1 + 1;
        i = 0; 
        ct = 0;
        while (i < BMP_DATA_SIZE_2) begin
            @(negedge clock);
            if (Network_Output_Valid == 1) begin
                ct += 1;
                absval1 = ($signed(Processor_Result[7:0]) > 0) ? Processor_Result[7:0] : -1 * Processor_Result[7:0];
                absval2 = ($signed(Processor_Result[15:8]) > 0) ? Processor_Result[15:8] : -1 * Processor_Result[15:8];
                absval3 = ($signed(Processor_Result[23:16]) > 0) ? Processor_Result[23:16] : -1 * Processor_Result[23:16];
                absval4 = ($signed(Processor_Result[31:24]) > 0) ? Processor_Result[31:24] : -1 * Processor_Result[31:24];
                //if ((j % 226) != 100 & (j % 226) != 101) begin
                    $fwrite(outfile1, "%c%c%c", absval4[7:0], absval4[7:0], absval4[7:0]);
                    $fwrite(outfile2, "%c%c%c", absval3[7:0], absval3[7:0], absval3[7:0]);
                    $fwrite(outfile3, "%c%c%c", absval2[7:0], absval2[7:0], absval2[7:0]);
                    $fwrite(outfile4, "%c%c%c", absval1[7:0], absval1[7:0], absval1[7:0]);
                    //$write("WRITE%0d: %0x\n",ct,Processor_Result[7:0]);
                //end    
                i += BYTES_PER_PIXEL;
                j ++;
            end
        end
        $write("%d elements written\n",j);
        @(negedge clock);
        $fclose(outfile1);
        $fclose(outfile2);
        $fclose(outfile3);
        $fclose(outfile4);
        $fclose(reffile);
        proc3_done = 1;
    end

    initial begin: img_read_4
        
        int i, r1, r2, r3, r4;
        int cnt;
        int infile1, infile2, infile3, infile4;
        logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];
        wait(proc3_done);
        $display("@ %0t: Loading files %s, %s, %s, %s...", $time, conv3File1, conv3File2, conv3File3, conv3File4);
        infile1 = $fopen(conv3File1, "rb");
        infile2= $fopen(conv3File2, "rb");
        infile3 = $fopen(conv3File3, "rb");
        infile4 = $fopen(conv3File4, "rb");
        DDR3_Input_Valid = 1'b0;
        // Skip BMP header
        r1 = $fread(bmp_header, infile1, 0, BMP_HEADER_SIZE);
        r2 = $fread(bmp_header, infile2, 0, BMP_HEADER_SIZE);
        r3 = $fread(bmp_header, infile3, 0, BMP_HEADER_SIZE);
        r4 = $fread(bmp_header, infile4, 0, BMP_HEADER_SIZE);
        cnt = 0;
        for (i = 0; i < 9; i ++) begin
            @(negedge clock);
            Begin_Calc = 0;
            DDR3_Input = WeightsCompress[i];
            DDR3_Input_Valid = 1;
        end
        for (i = 0; i < 9; i ++) begin
            @(negedge clock);
            DDR3_Input = BiasZero[i];
            DDR3_Input_Valid = 1;
        end
        // Read data from image file
        i = 0;
        while ( i < BMP_DATA_SIZE_2 ) begin
            @(negedge clock);
            DDR3_Input_Valid = 1'b0;
            if (InputEnable == 1'b1) begin
                cnt ++;
                r1 = $fread(pixel1, infile1, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
                r2 = $fread(pixel2, infile2, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
                r3 = $fread(pixel3, infile3, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
                r4 = $fread(pixel4, infile4, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
                DDR3_Input = {pixel1[7:0],pixel2[7:0],pixel3[7:0],pixel4[7:0]};
                DDR3_Input_Valid = 1'b1;
                i += 3;
            end
        end
        @(negedge clock);
        DDR3_Input_Valid = 1'b0;
        $fclose(infile1);
        $fclose(infile2);
        $fclose(infile3);
        $fclose(infile4);
        end

        initial begin : img_write_4
            int i, r, j, ct;
            int outfile1, outfile2, outfile3, outfile4, reffile;
            logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];
            logic [31:0] absval1, absval2, absval3, absval4;
            logic [7:0] wrchar;
            wait(proc3_done);
            @(negedge clock);
            outfile1 = $fopen(conv4File1, "wb");
            outfile2 = $fopen(conv4File2, "wb");
            outfile3 = $fopen(conv4File3, "wb");
            outfile4 = $fopen(conv4File4, "wb");
            reffile = $fopen(refFile, "rb");
            r = $fread(bmp_header, reffile, 0, BMP_HEADER_SIZE);
            if (!(r && outfile1 && outfile2 && outfile3 && outfile4)) begin
                $write("OPEN ERRROR\n\n\n");
            end
            $write("RES: %0u\n%0u\n%0u\n%0u\n%0u\n",r,outfile1,outfile2,outfile3,outfile4);
            for (i = 0; i < BMP_HEADER_SIZE; i++) begin
                if (i == 18 || i == 22) begin
                    $fwrite(outfile1, "%c", $unsigned(bmp_header[i])/4);
                    $fwrite(outfile2, "%c", $unsigned(bmp_header[i])/4);
                    $fwrite(outfile3, "%c", $unsigned(bmp_header[i])/4);
                    $fwrite(outfile4, "%c", $unsigned(bmp_header[i])/4);
                end else begin
                    $fwrite(outfile1, "%c", bmp_header[i]);
                    $fwrite(outfile2, "%c", bmp_header[i]);
                    $fwrite(outfile3, "%c", bmp_header[i]);
                    $fwrite(outfile4, "%c", bmp_header[i]);
                end
            end
            j = IM_WIDTH_1 + 1;
            i = 0; 
            ct = 0;
            while (i < BMP_DATA_SIZE_3) begin
                @(negedge clock);
                if (Network_Output_Valid == 1) begin
                    ct += 1;
                    absval1 = ($signed(Processor_Result[7:0]) > 0) ? Processor_Result[7:0] : -1 * Processor_Result[7:0];
                    absval2 = ($signed(Processor_Result[15:8]) > 0) ? Processor_Result[15:8] : -1 * Processor_Result[15:8];
                    absval3 = ($signed(Processor_Result[23:16]) > 0) ? Processor_Result[23:16] : -1 * Processor_Result[23:16];
                    absval4 = ($signed(Processor_Result[31:24]) > 0) ? Processor_Result[31:24] : -1 * Processor_Result[31:24];
                    //if ((j % 226) != 100 & (j % 226) != 101) begin
                        $fwrite(outfile1, "%c%c%c", absval4[7:0], absval4[7:0], absval4[7:0]);
                        $fwrite(outfile2, "%c%c%c", absval3[7:0], absval3[7:0], absval3[7:0]);
                        $fwrite(outfile3, "%c%c%c", absval2[7:0], absval2[7:0], absval2[7:0]);
                        $fwrite(outfile4, "%c%c%c", absval1[7:0], absval1[7:0], absval1[7:0]);
                        //$write("WRITE%0d: %0x\n",ct,Processor_Result[7:0]);
                    //end    
                    i += BYTES_PER_PIXEL;
                    j ++;
                end
            end
            $write("%d elements written\n",j);
            @(negedge clock);
            $fclose(outfile1);
            $fclose(outfile2);
            $fclose(outfile3);
            $fclose(outfile4);
            $fclose(reffile);
            $finish;// proc3_done = 1;
    end

endmodule