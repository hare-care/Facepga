`timescale 1ns/1ns

module fc #(
    parameter DATA_WIDTH = 8,
    parameter FC_TOTAL_COUNT = 1024
) (
    input logic                                     clock,
    input logic                                     reset,
    input logic [31:0]                              new_data,
    input logic                                     start,
    input logic                                     ops_valid,
    input logic                                     weights_valid,
    input logic                                     biases_valid,
    output logic [31:0]                             result,
    output logic                                    in_rd_en,
    output logic                                    done_out
);

typedef enum logic [1:0] {load_data, calculating, done} fc_state;

fc_state state_c, state_s;

logic [4:0] loopVar;
logic [31:0] result_c;
logic [3 : 0][31:0]intermediateValueSubOps;
logic [15:0] operationCycleCounter_c, operationCycleCounter_s;
logic [3:0][7:0] weights_c, weights_s, biases_c, biases_s, operands_c, operands_s; 

always_comb begin

    state_c = state_s;
    result_c = result;
    operationCycleCounter_c = operationCycleCounter_s;
    done_out = 0;
    intermediateValueSubOps = 0;
    loopVar = 0;
    in_rd_en = 0;
    weights_c = weights_s;
    biases_c = biases_s;
    operands_c = operands_s;
    case (state_s)
    load_data: begin
        if (weights_valid == 1) begin
            weights_c[0] = new_data[7:0];
            weights_c[1] = new_data[15:8];
            weights_c[2] = new_data[23:16];
            weights_c[3] = new_data[31:24];
        end else if (biases_valid == 1) begin
            biases_c[0] = new_data[7:0];
            biases_c[1] = new_data[15:8];
            biases_c[2] = new_data[23:16];
            biases_c[3] = new_data[31:24];
        end else if (ops_valid == 1)begin
            operands_c[0] = new_data[7:0];
            operands_c[1] = new_data[15:8];
            operands_c[2] = new_data[23:16];
            operands_c[3] = new_data[31:24];
            state_c = calculating;
        end
    end
    calculating: begin
        result_c = result + (operands_s[0] * weights_s[0] + biases_s[0]) + (operands_s[1] * weights_s[1] + biases_s[1]) + (operands_s[2] * weights_s[2] + biases_s[2]) + (operands_s[3] * weights_s[3] + biases_s[3]);
        if (operationCycleCounter_s >= FC_TOTAL_COUNT - 4) begin
            operationCycleCounter_c = 0;
            state_c = done;
        end else begin
            operationCycleCounter_c = operationCycleCounter_s + 4;
            state_c = load_data;
        end
        in_rd_en = 1;
    end
    done: begin
        operationCycleCounter_c = 0;
        done_out = 1;
        state_c = done;
    end
    default: begin

    end
    endcase

end

always_ff @(posedge clock, posedge reset) begin
    if (reset == 1) begin
        state_s <= load_data;
        result <= 0;
        operationCycleCounter_s <= 0;
        weights_s <= 0;
        biases_s <= 0;
        operands_s <= 0;
    end else begin
        state_s <= state_c;
        result <= result_c;
        operationCycleCounter_s <= operationCycleCounter_c;
        weights_s <= weights_c;
        biases_s <= biases_c;
        operands_s <= operands_c;
    end
end

endmodule