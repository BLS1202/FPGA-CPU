// `include "library.v"

module control_unit
(input wire [6:0] op,
input wire [2:0] func3,
input wire [6:0] func7,
output reg RegWr,
output reg ALUAsrc,
output reg [1:0] ALUBsrc,
output reg [3:0] ALUctr,
output reg [2:0] Branch,
output reg MemtoReg,
output reg MemWr,
output reg MemOp,
output reg [2:0] ExtOp);





    wire [5:0] opcode;
    assign opcode = op[6:2];
    always @(*) begin
        RegWr = 1'b0;
        ALUAsrc = 1'b0;
        ALUBsrc = 2'b00;
        ALUctr = 4'b0000;
        Branch = 1'b0;
        MemtoReg = 1'b0;
        MemWr = 1'b0;
        MemOp = 1'b0;
        ExtOp = 3'd0;

            case (opcode)
                // LUI
                5'b01101: begin
                    ExtOp = 3'b001;
                    RegWr = 1'b1;
                    ALUBsrc = 2'b01;
                    ALUctr = 4'b0011; // Copy immediate
                end
                
                // AUIPC
                5'b00101: begin
                    ExtOp = 3'b001;
                    RegWr = 1'b1;
                    ALUAsrc = 1'b1;
                    ALUBsrc = 2'b01;
                    ALUctr = 4'b0000; // PC + immediate
                end
                
                // Immediate instructions
                5'b00100: begin
                    ExtOp = 3'b000;
                    RegWr = 1'b1;
                    ALUBsrc = 2'b01;
                    
                    case (func3)
                        3'b000: ALUctr = 4'b0000; // ADDI
                        3'b010: ALUctr = 4'b0010; // SLTI
                        3'b011: ALUctr = 4'b1010; // SLTIU
                        3'b100: ALUctr = 4'b0100; // XORI
                        3'b110: ALUctr = 4'b0110; // ORI
                        3'b111: ALUctr = 4'b0111; // ANDI
                        3'b001: ALUctr = 4'b0001; // SLLI
                        3'b101: begin
                            if (func7[5])
                                ALUctr = 4'b1101; // SRAI
                            else
                                ALUctr = 4'b0101; // SRLI
                        end
                    endcase
                end
                
                // Register-register instructions
                5'b01100: begin
                    RegWr = 1'b1;
                    ALUBsrc = 2'b00;
                    
                    case ({func7[5], func3})
                        {1'b0, 3'b000}: ALUctr = 4'b0000; // ADD
                        {1'b1, 3'b000}: ALUctr = 4'b1000; // SUB
                        {1'b0, 3'b001}: ALUctr = 4'b0001; // SLL
                        {1'b0, 3'b010}: ALUctr = 4'b0010; // SLT
                        {1'b0, 3'b011}: ALUctr = 4'b1010; // SLTU
                        {1'b0, 3'b100}: ALUctr = 4'b0100; // XOR
                        {1'b0, 3'b101}: ALUctr = 4'b0101; // SRL
                        {1'b1, 3'b101}: ALUctr = 4'b1101; // SRA
                        {1'b0, 3'b110}: ALUctr = 4'b0110; // OR
                        {1'b0, 3'b111}: ALUctr = 4'b0111; // AND
                    endcase
                end
                
                // JAL
                5'b11011: begin
                    ExtOp = 3'b100;
                    RegWr = 1'b1;
                    Branch = 3'b001;
                    ALUAsrc = 1'b1;
                    ALUBsrc = 2'b10;
                    ALUctr = 4'b0000; // PC + 4
                end
                
                // JALR
                5'b11001: begin
                    if (func3 == 3'b000) begin
                        ExtOp = 3'b000;
                        RegWr = 1'b1;
                        Branch = 3'b010;
                        ALUAsrc = 1'b1;
                        ALUBsrc = 2'b10;
                        ALUctr = 4'b0000; // PC + 4
                    end
                end
                
                // Branch instructions
                5'b11000: begin
                    ExtOp = 3'b011;
                    ALUBsrc = 2'b00;
                    ALUctr = (func3[2]) ? 4'b1010 : 4'b0010; // Unsigned or signed comparison
                    
                    case (func3)
                        3'b000: Branch = 3'b100; // BEQ
                        3'b001: Branch = 3'b101; // BNE
                        3'b100: Branch = 3'b110; // BLT
                        3'b101: Branch = 3'b111; // BGE
                        3'b110: Branch = 3'b110; // BLTU
                        3'b111: Branch = 3'b111; // BGEU
                    endcase
                end
                
                // Load instructions
                5'b00000: begin
                    ExtOp = 3'b000;
                    RegWr = 1'b1;
                    MemtoReg = 1'b1;
                    ALUBsrc = 2'b01;
                    ALUctr = 4'b0000; // rs1 + imm
                    
                    case (func3)
                        3'b000: MemOp = 3'b000; // LB
                        3'b001: MemOp = 3'b001; // LH
                        3'b010: MemOp = 3'b010; // LW
                        3'b100: MemOp = 3'b100; // LBU
                        3'b101: MemOp = 3'b101; // LHU
                    endcase
                end
                
                // Store instructions
                5'b01000: begin
                    ExtOp = 3'b010;
                    MemWr = 1'b1;
                    ALUBsrc = 2'b01;
                    ALUctr = 4'b0000; // rs1 + imm
                    
                    case (func3)
                        3'b000: MemOp = 3'b000; // SB
                        3'b001: MemOp = 3'b001; // SH
                        3'b010: MemOp = 3'b010; // SW
                    endcase
                end
            endcase
    end



endmodule
