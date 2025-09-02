
//multiplexer
module Multiplexer
#(parameter WIDTH = 8,
            N = $clog2(WIDTH))
(
    input [WIDTH-1:0]I, 
    input [N-1:0]S,
    output Y);

    reg val;
    assign Y = val;
    always @* begin
        val = I[S];
    end


endmodule

//2to1 mux for 7 bits
module Mux2to1
#(parameter WIDTH = 8)
(
    input sel, 
    input [WIDTH -1:0]I0, I1,
    output [WIDTH-1:0]Y);
    //Choose input based on S

    reg [WIDTH-1:0]val;
    assign Y = val;
    always @* begin
        if(sel)
            val = I1;
        else
            val = I0;
    end

endmodule


module Mux4to1
#(parameter WIDTH = 8)
(input [1:0] sel, 
    input [WIDTH -1:0]I0, I1, I2, I3,
    output [WIDTH-1:0]Y);

    reg [WIDTH-1:0] val;
    assign Y = val;
    always @* begin
        case(sel)
            2'd0: begin
                val = I0;
            end
            2'd1: begin
                val = I1;
            end
            2'd2: begin
                val = I2;
            end
            2'd3: begin
                val = I3;
            end
        endcase
    end

endmodule


// //magnitude comparator
module MagComp
#(parameter WIDTH = 8)
(
    input [WIDTH-1:0]A, B,
    output AltB, AeqB, AgtB);

    assign AeqB = (A == B);
    assign AltB = (A < B);
    assign AgtB = (A > B);
endmodule


// //comparator
// module Comparator
// #(parameter WIDTH = 4)
// (
//     input [WIDTH-1:0]A, B,
//     output AeqB);

//     assign AeqB = (A === B);

// endmodule

// //register
// module Register
// #(parameter WIDTH = 8)
// (
//     input en, clear, clock,
//     input [WIDTH-1:0] D,
//     output [WIDTH-1:0] Q
// );

//     reg [WIDTH-1:0] val;
//     assign Q = val;
//     always @(posedge clock) begin
//         if(en) val <= D;
//         else begin
//             if(clear) val <= 0;
//         end
//     end

// endmodule

module Adder
#(parameter WIDTH = 4)(
    input cin,
    input [WIDTH-1:0] A, B, 
    output [WIDTH-1:0]sum,
    output cout
);
    assign {cout, sum} = A+B+cin;

endmodule


module Alu_Adder
#(parameter WIDTH = 4)(
    input cin,
    input [WIDTH-1:0] A, B, 
    output [WIDTH-1:0]sum,
    output cout,
    output overflow,
    output zero
);
    wire [WIDTH-1:0] cin_extend, B_xor;
    assign cin_extend = {WIDTH{cin}};
    assign B_xor = (cin_extend^B) + cin;
    assign {cout, sum} = A + B_xor;
    assign overflow = (A[WIDTH-1] == B_xor[WIDTH-1]) 
    && (sum[WIDTH-1] != A[WIDTH-1]) ;
    assign zero = ~(| sum);

endmodule



module barrelshifterleft
#(parameter WIDTH = 4,
            B = $clog2(WIDTH))
(input [WIDTH-1:0] V,
input [B-1:0] by,
output [WIDTH-1:0] S);

    assign S = V << by;

endmodule



module barrelshifterright
#(parameter WIDTH = 4,
            B = $clog2(WIDTH))
(input [WIDTH-1:0] V,
input [B-1:0] by,
output [WIDTH-1:0] S);

    assign S = $signed(V) >> by;

endmodule

module logical_barrelshifterright
#(parameter WIDTH = 4,
            B = $clog2(WIDTH))
(input [WIDTH-1:0] V,
input [B-1:0] by,
output [WIDTH-1:0] S);

    assign S = $signed(V) >>> by;

endmodule

//32 bits command decode
module command_decode
#(parameter OP_WIDTH = 32)
(
    input [31:0] command,
    output [6:0] func7,
    output [6:0] opcode,
    output [4:0] rs2, rs1,
    output [2:0] func3,
    output [31:0] imm_I,
    output [31:0] imm_S,
    output [31:0] imm_U,
    output [31:0] imm_B,
    output [31:0] imm_J,
    output [4:0] rd 
);

    assign func7 = command[31:25];
    assign rs2 = command[24:20];
    assign rs1 = command[19:15];
    assign opcode = command[6:0];
    assign func3 = command[14:12];
    assign rd = command[11:7];
    assign imm_I = {{20{command[31]}}, command[31:20]};
    assign imm_S = {{20{command[31]}}, command[31:25], command[11:7]};
    assign imm_U = {command[31:12], 12'b0};
    assign imm_B = {{20{command[31]}}, command[7], command[30:25], command[11:8], 1'b0};
    assign imm_J = {{12{command[31]}}, command[19:12], command[20], command[30:21], 1'b0};

endmodule

module bra_cond
(input Zero, Less,
input [2:0] Branch, 
output reg PCAsrc, PCBsrc);
    always @(*) begin
            case (Branch)
            // No branch or JAL (000)
            3'b000: begin
                PCAsrc = 1'b0;
                PCBsrc = 1'b0;
            end
            
            // JAL (001)
            3'b001: begin
                PCAsrc = 1'b1;
                PCBsrc = 1'b0;

            end
            
            // JALR (010)
            3'b010: begin
                PCAsrc = 1'b1;
                PCBsrc = 1'b1;

            end
            
            // BEQ (100)
            3'b100: begin
                if (Zero) begin
                    PCAsrc = 1'b1;
                    PCBsrc = 1'b0;
        
                end
                else begin
                    PCAsrc = 1'b0;
                    PCBsrc = 1'b0;
    
                end
            end
            
            // BNE (101)
            3'b101: begin
                if (!Zero) begin
                    PCAsrc = 1'b1;
                    PCBsrc = 1'b0;
        
                end
                else begin
                    PCAsrc = 1'b0;
                    PCBsrc = 1'b0;

                end
            end
            
            // BLT/BLTU (110)
            3'b110: begin
                if (Less) begin
                    PCAsrc = 1'b1;
                    PCBsrc = 1'b0;

                end
                else begin
                    PCAsrc = 1'b0;
                    PCBsrc = 1'b0;

                end
            end
            
            // BGE/BGEU (111)
            3'b111: begin
                if (!Less) begin
                    PCAsrc = 1'b1;
                    PCBsrc = 1'b0;

                end
                else begin
                    PCAsrc = 1'b0;
                    PCBsrc = 1'b0;
        
                end
            end
            default: begin
                PCAsrc = 1'b0;
                PCBsrc = 1'b0;

            end
        endcase
    end
endmodule
