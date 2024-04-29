`timescale 1ns/1ns

module avg_pool#(
    parameter DATA_WIDTH = 32
)(
    input logic                                 clock,
    input logic                                 reset,
    input logic [DATA_WIDTH-1:0]                newPointData,
    input logic                                 newPointValid,
    output logic                                done,
    output logic [DATA_WIDTH-1:0]               average
);

    logic [DATA_WIDTH-1:0] avg_c;
    logic [31:0] total_value_c, total_value_s;
    logic [5:0] inputCounter_c, inputCounter_s;

    logic reset_div, div_valid, overflow, div_go;
    logic [31:0] div_remainder, div_quotient, div_dividend;

    div #(
        .DIVIDEND_WIDTH(32),
        .DIVISOR_WIDTH(32)
    ) divider (
        .clk(clock),
        .reset(reset_div || reset),
        .dividend(div_dividend),
        .divisor(32'h00000031),
        .valid_in(div_go),
        .quotient(div_quotient),
        .remainder(div_remainder),
        .valid_out(div_valid),
        .overflow(overflow)
    );
    
    typedef enum logic[1:0] {accepting_new, start_div ,dividing} avg_state;
    avg_state state_c, state_s;

    always_comb begin
        total_value_c = total_value_s;
        state_c = state_s;
        reset_div = 0;
        div_dividend = 0;
        div_go = 0;
        case (state_s) 
        accepting_new: begin
            if (newPointValid == 1) begin
                if (inputCounter_s == 49) begin
                    state_c = start_div;
                end
                total_value_c = total_value_s + newPointData;
                inputCounter_c = inputCounter_s + 1;
            end
        end
        start_div: begin
            reset_div = 1;
            div_dividend = total_value_s;
            state_c = dividing;
        end
        dividing: begin
            div_dividend = total_value_s;
            div_go = 1;
            if (div_valid == 1) begin
                state_c = accepting_new;
                total_value_c = 0;
                inputCounter_c = 0;
                average = div_quotient;
                done = 1;
            end
        end
        endcase
    end

    always_ff @(posedge clock, posedge reset) begin
        if (reset == 1) begin
            total_value_s <= 0;
            state_s <= accepting_new;
            inputCounter_s <= 0;
        end else begin
            total_value_s <= total_value_c;
            state_s <= state_c;
            inputCounter_s <= inputCounter_c;
        end
    end


endmodule