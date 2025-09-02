
// `include "library.v"

module alu
(
input wire aluctr,
input wire [2:0] aluop,
input wire [31:0] inputA, inputB,
output wire [31:0] result,
output Less, zero);

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
    Alu_Adder #(32) 
    add(.A(inputA), .B(inputB), .cin(ctr_sig), .sum(sum), .cout(carry), .zero(zero), .overflow(overflow));
    assign AND = inputA & inputB;
    assign OR = inputA | inputB;
    assign XOR = inputA ^ inputB;
    assign NOT = ~inputA;
    barrelshifterright #(32) Rshift(.V(inputA), .S(rshift), .by(by));
    barrelshifterleft #(32) Lshift(.V(inputA), .S(lshift), .by(by));
    logical_barrelshifterright #(32) LRshift(.V(inputA), .S(lrshift), .by(by));
    MagComp #(32) comp(.A(inputA), .B(inputB), .AltB(AltB), .AgtB(AgtB), .AeqB(AeqB));

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

    end

endmodule