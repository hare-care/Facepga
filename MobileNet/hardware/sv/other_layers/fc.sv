`timescale 1ns/1ns

module fc #(
    parameter DATA_WIDTH = 8,
    parameter OPS_PER_CYCLE = 10,
    parameter FC_TOTAL_COUNT = 1024
) (
    input logic                                     clock,
    input logic                                     reset,
    input logic [OPS_PER_CYCLE-1:0][DATA_WIDTH-1:0] operands,
    input logic [OPS_PER_CYCLE-1:0][DATA_WIDTH-1:0] weights,
    input logic [OPS_PER_CYCLE-1:0][DATA_WIDTH-1:0] biases,
    input logic                                     start,
    input logic                                     data_valid,
    output logic [31:0]                             result,
    output logic                                    done_out
);

typedef enum logic [1:0] {idle, calculating,done} fc_state;

fc_state state_c, state_s;

logic [4:0] loopVar;
logic [31:0] result_c;
logic [OPS_PER_CYCLE - 1 : 0][31:0]intermediateValueSubOps;
logic [15:0] operationCycleCounter_c, operationCycleCounter_s;

always_comb begin

    state_c = state_s;
    result_c = result;
    operationCycleCounter_c = operationCycleCounter_s;
    done_out = 0;
    intermediateValueSubOps = 0;
    loopVar = 0;

    case (state_s)

    idle: begin
        if (start == 1) begin
            state_c = calculating;
        end
    end
    calculating: begin
        if (data_valid == 1'b1) begin
            for (loopVar = 0; loopVar < OPS_PER_CYCLE; loopVar += 1) begin
                if (operationCycleCounter_s + loopVar < 1024) begin
                    intermediateValueSubOps[loopVar] = (weights[loopVar] * operands[loopVar]) + biases[loopVar];
                end else begin
                    intermediateValueSubOps[loopVar] = 0;
                    state_c = done;
                end
            end
            for (loopVar = 0; loopVar < OPS_PER_CYCLE; loopVar += 1) begin
                result_c += intermediateValueSubOps[loopVar];
            end
            operationCycleCounter_c = operationCycleCounter_s + OPS_PER_CYCLE;
        end
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
        state_s <= idle;
        result <= 0;
        operationCycleCounter_s <= 0;
    end else begin
        state_s <= state_c;
        result <= result_c;
        operationCycleCounter_s <= operationCycleCounter_c;
    end
end

endmodule