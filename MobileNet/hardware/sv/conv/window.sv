`timescale 1ns/1ns

module window#(
    parameter DATA_WIDTH = 8,
    parameter MAXIMUM_SIZE = 9,
    parameter MAXIMUM_INPUT_SIZE = 224*2 + 3
)(
    input logic [DATA_WIDTH-1:0]                                    new_data,
    input logic                                                     clock,
    input logic                                                     reset,
    input logic                                                     new_data_valid, //In cases of stalls need to know when its a new piece of data
    input logic                                                     out_wr_en, //Need to know data can be recieved by the output, else dont shift
    //Parameter logic
    input logic                                                     stride,// 0 = 1, 1 = 2
    input logic [1:0]                                               window_dim, 
    input logic [DATA_WIDTH-1:0]                                    input_dim,

    output logic                                                    window_valid,//Signal that the window is ready for read - i.e. not stale and not edge frame
    output logic [8:0][DATA_WIDTH-1:0]                              output_window,
    output logic                                                    in_rd_en //Signal backwards propogation of delay                                      
);

    localparam buff_size = MAXIMUM_INPUT_SIZE;
    /*Only way to avoid 7k Lut*/
    logic [0:(224*2) + 2][DATA_WIDTH-1:0] shift_buffer_s1, shift_buffer_c1;
    logic [0:(112*2) + 2][DATA_WIDTH-1:0] shift_buffer_s2, shift_buffer_c2;
    logic [0:(56*2) + 2][DATA_WIDTH-1:0] shift_buffer_s3, shift_buffer_c3;
    logic [0:(28*2) + 2][DATA_WIDTH-1:0] shift_buffer_s4, shift_buffer_c4;
    logic [0:(14*2) + 2][DATA_WIDTH-1:0] shift_buffer_s5, shift_buffer_c5;
    logic [0:(7*2) + 2][DATA_WIDTH-1:0] shift_buffer_s6, shift_buffer_c6;


    logic strideFlop_c, strideFlop_s;
    logic strideCol_c, strideCol_s;
    logic [31:0] rowCounter_s, rowCounter_c;    
    logic [31:0] cycleCounter_c, cycleCounter_s;
    logic full_s, full_c;

    always_comb begin
        rowCounter_c = rowCounter_s;
        shift_buffer_c1 = shift_buffer_s1;
        shift_buffer_c2 = shift_buffer_s2;
        shift_buffer_c3 = shift_buffer_s3;
        shift_buffer_c4 = shift_buffer_s4;
        shift_buffer_c5 = shift_buffer_s5;
        shift_buffer_c6 = shift_buffer_s6;
        cycleCounter_c = cycleCounter_s;
        full_c = full_s;
        in_rd_en = 1;
        strideFlop_c = strideFlop_s;
        strideCol_c = strideCol_s;
        //Set output values
        for(int i = 0; i < 3; i = i + 1) begin
            for (int j = 0; j < 3; j = j + 1) begin
                output_window[3*i + j] = shift_buffer_s6[(7*i) + j]; 
                if ($unsigned(input_dim) == 224) begin
                    output_window[3*i + j] = shift_buffer_s1[224*i + j]; 
                end
                if (input_dim == 112) begin
                    output_window[3*i + j] = shift_buffer_s2[(112*i) + j]; 
                end
                if (input_dim == 56) begin
                    output_window[3*i + j] = shift_buffer_s3[(56*i) + j]; 
                end
                if (input_dim == 28) begin
                    output_window[3*i + j] = shift_buffer_s4[(28*i) + j]; 
                end
                if (input_dim == 14) begin
                    output_window[3*i + j] = shift_buffer_s5[(14*i) + j]; 
                end
            end
        end

        //After reset box should never be empty once filled
        if (cycleCounter_s == input_dim * 2 + 3) begin
            full_c = 1;
        end
        if (full_s == 1'b1) begin
            if (window_dim == 3) begin
                if (rowCounter_s == input_dim - 1 || rowCounter_s == input_dim - 2) begin
                    window_valid = 0;
                end else begin
                    window_valid = 1;
                end
            end else begin
                window_valid = 1;
            end
        end else begin
            window_valid = 0;
        end
        if ((strideFlop_s == 1 || strideCol_s == 1) && stride == 1)begin
            window_valid = 0;
        end

        //Shift should occur when new data is valid and value is requested
        //If both are present, shift, else signal delay backwards
        if ((full_s != 1 || out_wr_en == 1'b1) && new_data_valid == 1'b1) begin
            shift_buffer_c1[0:(224 * 2) + 1] = shift_buffer_s1[1:(224 * 2) + 2];
            shift_buffer_c1[(224 * 2) + 2] = new_data;
            shift_buffer_c2[0:(112 * 2) + 1] = shift_buffer_s2[1:(112 * 2) + 2];
            shift_buffer_c2[(112 * 2) + 2] = new_data;
            shift_buffer_c3[0:(56 * 2) + 1] = shift_buffer_s3[1:(56 * 2) + 2];
            shift_buffer_c3[(56 * 2) + 2] = new_data;
            shift_buffer_c4[0:(28 * 2) + 1] = shift_buffer_s4[1:(28 * 2) + 2];
            shift_buffer_c4[(28 * 2) + 2] = new_data;
            shift_buffer_c5[0:(14* 2) + 1] = shift_buffer_s5[1:(14* 2) + 2];
            shift_buffer_c5[(14 * 2) + 2] = new_data;
            shift_buffer_c6[0:(7 * 2) + 1] = shift_buffer_s6[1:(7 * 2) + 2];
            shift_buffer_c6[(7 * 2) + 2] = new_data;
            if (stride == 1) begin
                strideFlop_c = ~strideFlop_s;
            end
            if (cycleCounter_s < buff_size) begin
                cycleCounter_c = cycleCounter_s + 1;
            end else begin
                cycleCounter_c = 0;
            end
            if (full_s == 1) begin
                if (rowCounter_c == input_dim - 1) begin
                    rowCounter_c = 0;
                    if (stride == 1) begin
                        strideCol_c = ~strideCol_s;
                    end
                end else begin
                    rowCounter_c = rowCounter_s + 1;
                end
            end
        end else begin
            window_valid = 0;
            in_rd_en = 0;
        end

        
    end

    always_ff @(posedge clock, posedge reset) begin
        if (reset == 1'b1) begin
            rowCounter_s <= 0;
            shift_buffer_s1 <= 0;
            shift_buffer_s2 <= 0;
            shift_buffer_s3 <= 0;
            shift_buffer_s4 <= 0;
            shift_buffer_s5 <= 0;
            shift_buffer_s6 <= 0;
            cycleCounter_s <= 0;
            full_s <= 0;
            strideFlop_s <= 0;
            strideCol_s <= 0;
        end else begin
            rowCounter_s <= rowCounter_c;
            strideFlop_s <= strideFlop_c;
            shift_buffer_s1 <= shift_buffer_c1;
            shift_buffer_s2 <= shift_buffer_c2;
            shift_buffer_s3 <= shift_buffer_c3;
            shift_buffer_s4 <= shift_buffer_c4;
            shift_buffer_s5 <= shift_buffer_c5;
            shift_buffer_s6 <= shift_buffer_c6;
            cycleCounter_s <= cycleCounter_c;
            full_s <= full_c;
            strideCol_s <= strideCol_c;
        end
    end

    
endmodule