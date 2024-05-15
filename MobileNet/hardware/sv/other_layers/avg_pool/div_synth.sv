// virtual class functionClass #(parameter int DATA_WIDTH);

//     static function int get_msb_pos;    
//         input logic [DATA_WIDTH-1:0] vec;
//         begin
//             if (DATA_WIDTH > 1) begin
//                 logic [(DATA_WIDTH/2)-1:0] lhs = vec[DATA_WIDTH-1:DATA_WIDTH/2];
//                 logic [(DATA_WIDTH/2)-1:0] rhs = vec[(DATA_WIDTH/2)-1:0];

//                 if (lhs > 0) begin
//                     return functionClass#(DATA_WIDTH/2)::get_msb_pos(lhs) + (DATA_WIDTH/2);
//                 end else if (rhs > 0) begin
//                     return functionClass#(DATA_WIDTH/2)::get_msb_pos(rhs);
//                 end else begin
//                     return 0;
//                 end
//             end else begin
//                 if ($unsigned(vec) == 1) begin
//                     return 1;
//                 end else begin
//                     return 0;
//                 end
//             end
//         end
//     endfunction
// endclass

module div #(
    parameter DIVIDEND_WIDTH = 64,
    parameter DIVISOR_WIDTH = 32
)
(
    input  logic                        clk,
    input  logic                        reset,
    input  logic                        valid_in,
    input  logic [DIVIDEND_WIDTH-1:0]   dividend,
    input  logic [DIVISOR_WIDTH-1:0]    divisor,
    output logic [DIVIDEND_WIDTH-1:0]   quotient,
    output logic [DIVISOR_WIDTH-1:0]    remainder,
    output logic                        valid_out,
    output logic                        overflow
);

typedef enum logic [2:0] { INIT, IDLE, B_EQ_1, GET_MSB_A, GET_MSB_B, LOOP, EPILOGUE, DONE } state_t;
state_t state, state_c;

    
logic [DIVIDEND_WIDTH-1:0] a, a_c;
logic [DIVISOR_WIDTH-1:0] b, b_c;
logic [DIVIDEND_WIDTH-1:0] q, q_c;
// logic [DIVISOR_WIDTH-1:0] r, r_c;
logic internal_sign;
integer p;
integer a_minus_b;
integer remainder_condition;
integer msb_a, msb_a_c;
integer msb_b, msb_b_c;

always_ff @( posedge clk or posedge reset ) begin
    if (reset == 1'b1) begin
        state <= IDLE;
        a <= '0;
        b <= '0;
        q <= '0;
        msb_a <= '0;
        msb_b <= '0;
    end else begin
        state <= state_c;
        a <= a_c;
        b <= b_c;
        q <= q_c;
        msb_a <= msb_a_c;
        msb_b <= msb_b_c;
    end
end


always_comb begin
    overflow = 1'b0; //default to 0
    remainder = '0; //default to 0
    quotient = q; // default to q
    a_c = a;
    b_c = b;
    q_c = q;
    internal_sign = 1'b0; // defaulted value
    a_minus_b = '0; //defaulted value
    remainder_condition = 1'b0; // defaulted value
    p = '0; // defaulted value
    valid_out = '0;
    msb_a_c = msb_a;
    msb_b_c = msb_b;
    case(state)
        IDLE: begin
            if (valid_in == 1'b1) begin
                state_c = INIT;
            end else begin
                state_c = IDLE;
            end
        end

        INIT: begin
            overflow = 1'b0;
            a_c = (dividend[31] == 1'b0) ? $signed(dividend) : $signed(-dividend);
            b_c = (divisor[31] == 1'b0) ? $signed(divisor) : $signed(-divisor);
            q_c = '0;
            p = 0; 
            msb_a_c = 31; // 32 was reading unitialized signals
            msb_b_c = 31;

            if (divisor == 1) begin
                state_c = B_EQ_1;
            end else if (divisor == 0) begin
                overflow = 1'b1;
                state_c = B_EQ_1;
            end else begin
                state_c = GET_MSB_A;
            end
        end

        B_EQ_1: begin
            q_c = dividend;
            a_c = '0;
            b_c = b;
            state_c = EPILOGUE;
        end

        GET_MSB_A: begin
            msb_a_c = (a[msb_a] == 1'b1) ? msb_a : msb_a - 1;    
            state_c = (a[msb_a] == 1'b1) ? GET_MSB_B : GET_MSB_A;    
        end
        
        GET_MSB_B: begin // fixed typo (before was also GET_MSB_A)
            msb_b_c = (a[msb_b] == 1'b1) ? msb_b : msb_b - 1;    
            state_c = (a[msb_b] == 1'b1) ? LOOP : GET_MSB_B;    
        end

        LOOP: begin
            b_c = b;
            p = msb_a - msb_b;
            if (($signed(b) << p) > $signed(a)) begin
                p = p - 1;
            end

            q_c = DIVIDEND_WIDTH'(q + (1 << p));

            if (($signed(b) != '0) && ($signed(b) <= $signed(a))) begin
                a_minus_b = $signed(a) - $signed($signed(b) << p);
                a_c = a_minus_b;
                state_c = GET_MSB_A;
            end else begin
                state_c = EPILOGUE;
            end
        end

        EPILOGUE: begin
            internal_sign = dividend[DIVIDEND_WIDTH-1] ^ divisor[DIVISOR_WIDTH-1];
            
            quotient = (internal_sign == 1'b0) ? q : -q;

            remainder_condition = $signed(dividend) >>> (DIVIDEND_WIDTH - 1);
            remainder = (remainder_condition != 1) ? a : -a;
            valid_out = 1'b1;
            state_c = IDLE;
        end

        default: begin
            state_c = IDLE;
            a_c = a;
            b_c = b;
            q_c = q;
        end
    endcase
end

endmodule
