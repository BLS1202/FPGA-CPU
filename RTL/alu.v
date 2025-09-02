
// `include "library.v"

module alu
(
input wire aluctr,
input wire [2:0] aluop,
input wire [31:0] inputA, inputB,
output wire [31:0] result,
output Less, zero);

    //sum, diff, and, or, xor, rshift, lshift, logical rshift
    wire [31:0] sum, diff, AND, OR, XOR, NOT, rshift, lshift, lrshift;
    reg ctr_sig;
    assign Less = Alt_B;

    wire AeqB, AltB, AgtB;
    reg [31:0] Aeq_B, Alt_B, Agt_B;
    wire [4:0] by;
    wire [15:0] op;
    reg [31:0] fin_out;
    assign by = inputB[4:0];
    assign result = fin_out;
    wire carry, overflow;

    always @* begin
        if(~AeqB) begin
            Aeq_B = 32'd0;
        end
        if(~AgtB) begin
            Agt_B = 32'd0;
        end
         if(~AltB) begin
            Alt_B = 32'd0;
        end
    end

    always @* begin
        if(aluop == 3'd0) begin
            ctr_sig = aluctr;
        end
        else if(aluop == 3'd2) begin
            ctr_sig = 1'b1;
        end
        else begin
            ctr_sig = 1'b0;
        end
    end

    //comparison datapath



    //basic operation
    Alu_Adder #(32) add(.A(inputA), .B(inputB), .cin(ctr_sig), .sum, .cout(carry),
    .zero(zero), .overflow);
    assign AND = inputA & inputB;
    assign OR = inputA | inputB;
    assign XOR = inputA ^ inputB;
    assign NOT = ~inputA;
    barrelshifterright #(32) Rshift(.V(inputA), .S(rshift), .by);
    barrelshifterleft #(32) Lshift(.V(inputA), .S(lshift), .by);
    logical_barrelshifterright #(32) LRshift(.V(inputA), .S(lrshift), .by);
    MagComp #(32) comp(.A(inputA), .B(inputB), .AltB, .AgtB, .AeqB);

    always @* begin
        case(aluop)
            3'd0: begin
                fin_out = sum;
            end
            3'd1: begin
                fin_out = lshift;
            end
            3'd2: begin
                fin_out = Alt_B;
            end
            3'd3: begin
                fin_out = inputB;
            end
            3'd4: begin
                fin_out = XOR;
            end
            3'd5: begin
                if(~aluop) fin_out = lrshift;
                else fin_out = rshift;
            end
            3'd6: begin
                fin_out = OR;
            end
            3'd7: begin
                fin_out = AND;
            end
        endcase

        // case(aluop)
        //     4'd0: assign fin_out = sum;
        //     4'd1: assign fin_out = diff;
        //     4'd2: assign fin_out = lshift;
        //     4'd

        //     4'd2: assign fin_out = AND;
        //     4'd3: assign fin_out = OR;
        //     4'd4: assign fin_out = XOR;
        //     4'd5: assign fin_out = NOT;
        //     4'd6: assign fin_out = rshift;
        //     4'd7: assign fin_out = lshift;
        //     4'd8: assign fin_out = lrshift;
        //     4'd9: assign fin_out = Alt_B;
        //     4'd10: assign fin_out = Aeq_B;
        //     4'd11: assign fin_out = Alt_B;
        //     default: assign fin_out = 32'd0;
        // endcase
    end

endmodule