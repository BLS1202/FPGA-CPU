//`include "alu.v"
//`include "memory_unit.v"
//`include "Register_file.v"
//`include "library.v"
//`include "Program_Counter.v"
//`include "control_unit.v"
//`timescale 1ns/1ps

module cpu_top
#(parameter program = "",
            memory = "",
            ADDR_WIDTH = 32,
            DATA_WIDTH = 16,
            WORDS = 2**ADDR_WIDTH,
            ACT_WIDTH = DATA_WIDTH/2)
(
    output [31:0] pc, 
    output instr_we, instr_re, instr_enable,
    input [7:0] data1, data2, data3, data4,
    output RegWr,
    output [4:0] rs1, rs2, rd,
    output [31:0] new_data,
    input [31:0] outdata1, outdata2,
    output [31:0] calc_result,
    input [31:0] mem_data,
    output MemWr, mem_read,
    input clock, en,
    input rst
);
    //program counter
    wire [ADDR_WIDTH-1:0] next_pc;
    Program_Counter #(ADDR_WIDTH)PC(.pc(pc), .clock(clock), 
        .reset(rst), .en(en), .next_pc(next_pc));


    //program memory
    assign instr_enable = 1'b1;
    assign instr_we = 1'b0;
    assign instr_re = 1'b1;

    wire [31:0] instr;
    assign instr = {data3, data4, data1, data2};

    //R type instruction
    wire [6:0] func7;
    wire [2:0] func3;
    wire [6:0] opcode;
    //rd, rs1, rs2
    //I type
    wire [31:0] imm_I;
    //S_type
    wire [31:0] imm_S;
    //U-type
    wire [31:0] imm_U;
    wire [31:0] imm_B;
    wire [31:0] imm_J;


    //command slice
    command_decode #(32) cd(.command(instr), .func7(func7), .opcode(opcode), .rs2(rs2),
    .rs1(rs1), .func3(func3),.imm_I(imm_I), .imm_S(imm_S), .imm_U(imm_U), .imm_B(imm_B),
    .imm_J(imm_J), .rd(rd));

    //reg_file
    reg [31:0] ext_imm;
    always @(*) begin
        case(ExtOp)
            3'd0: begin
                ext_imm = imm_I;
            end
            3'd1: begin
                ext_imm = imm_U;
            end
            3'd2: begin
                ext_imm = imm_S;
            end
            3'd3: begin
                ext_imm = imm_B;
            end
            3'd4: begin
                ext_imm = imm_J;
            end
        endcase
    end

    //add immediate
    wire [31:0] dataA, dataB;
    Mux2to1 #(32) SRCA(.I0(outdata1), .I1(pc), .Y(dataA), .sel(ALUAsrc));
    Mux4to1 #(32) SRCB(.I0(outdata2), .I1(ext_imm), 
    .I2(32'd4), .I3(32'd0), .Y(dataB), .sel(ALUBsrc));

    //control unit
    
    wire [3:0] ALUctr;
    wire [1:0] ALUBsrc;
    wire [2:0] Branch;
    wire [2:0] ExtOp;
    wire ALUAsrc, MemtoReg, MemOp; //MemWr
   
    
    
    control_unit cu(.op(opcode),  
        .func3(func3),
        .func7(func7),
        .RegWr(RegWr),
        .ALUAsrc(ALUAsrc),
        .ALUBsrc(ALUBsrc),
        .ALUctr(ALUctr),
        .Branch(Branch),
        .MemtoReg(MemtoReg),
        .MemWr(MemWr),
        .MemOp(MemOp),
        .ExtOp(ExtOp));


    //branch
    wire [31:0] PCA_data, PCB_data;
    Mux2to1 #(32) MuxA(.sel(PCAsrc), .I0(32'd4), .I1(ext_imm), .Y(PCA_data));
    Mux2to1 #(32) MuxB(.sel(PCBsrc), .I0(pc), .I1(outdata1), .Y(PCB_data));
    Adder #(32) PCAdder(.cin(1'b0), .A(PCA_data), .B(PCB_data), .cout(pc_add), .sum(next_pc));
    wire Less, zero;
    
    //ALU
    alu ALU(.aluctr(ALUctr[3]),
            .aluop(ALUctr[2:0]), 
            .inputA(dataA), 
            .inputB(dataB), 
            .result(calc_result),
            .zero(zero),
            .Less(Less));
    
    //branch condition
    wire PCAsrc, PCBsrc;
    bra_cond BRA(.Zero(zero), .Less(Less), .Branch(Branch), .PCAsrc(PCAsrc), 
    .PCBsrc(PCBsrc));


    //data memory
    assign mem_read = ~MemWr;


    Mux2to1 #(32) MuxE(.sel(MemtoReg), .I0(calc_result), .I1(mem_data), .Y(new_data));

endmodule
