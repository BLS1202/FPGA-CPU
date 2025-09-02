
module main_top(
input CPU_RESETN,
input CLK100MHZ,
input [15:0] SW,
input BTNC,
output wire [15:0] LED,
output DP,
output [6:0] SEG,
output [7:0] AN);
    wire clk;
    wire rst;
    assign rst = CPU_RESETN;
    assign clk = CLK100MHZ;
    wire [31:0] pc;
    wire [31:0] next_pc;
//    assign next_pc = pc + 32'd4;
//    always @(posedge clk) begin
//        if(~rst) begin
//            pc <= 32'd0;
//        end
//        else if(add) begin
//            pc <= next_pc;
//        end
//    end
    
    wire [31:0] dsp;
    wire [31:0] instr;
    assign instr = {instr1, instr2, instr3, instr4};
    assign dsp = SW[0] ? instr : pc;
//    assign dsp = pc;
    HEXtoSevenSegment hs1(.x(dsp), .seg(SEG[6:0]), .clk(clk), .an(AN[7:0]), .dp(DP));
    debounce(.clk(clk), .rst(rst), .incr(BTNC), .add(add));
    //cpu connections
    wire instr_we, instr_re;
    wire add;


     wire [7:0] data1, data2, data3, data4;
     wire RegWr;
     wire [4:0] rs1, rs2, rd;
     wire [31:0] new_data, outdata1, outdata2;
     wire [31:0] test_num, reg_data1, reg_data2;
     wire [31:0] calc_result, mem_data;
     wire MemWr, mem_read;
     parameter program_init = "rv32ui-p-add.mem";
     parameter memory_init = "data.mem";
    
    
     cpu_top #(.program(program_init), .memory(memory_init), 
     .ADDR_WIDTH(32), .DATA_WIDTH(16)) launch(
         .pc(pc),
         .instr_we    (instr_we),
         .instr_re    (instr_re),
         .instr_enable(instr_enable),
         .data1       (data1),
         .data2       (data2),
         .data3       (data3),
         .data4       (data4),
         .RegWr       (RegWr),
         .rs1         (rs1),
         .rs2         (rs2),
         .rd          (rd),
         .new_data    (new_data),
         .outdata1    (outdata1),
         .outdata2    (outdata2),
         .calc_result (calc_result),
         .mem_data    (mem_data),
         .MemWr       (MemWr),
         .mem_read    (mem_read),
         .clock       (clk),
         .en          (1'b1),
         .rst(rst));
        
             
     //ip core ram
     wire [7:0] instr_in1, instr_in2, instr_in3, instr_in4;
//     blk_mem_gen_0 instr_ram(.ena(instr_re), .wea(instr_we), .clka(clk), .addra(pc), .dina(instr_in), .douta(instr));
    
     blk_mem_gen_1 instr_ram1(.ena(instr_re), .wea(instr_we), .clka(clk), .addra(pc), .dina(instr_in1), .douta(instr1));
     blk_mem_gen_2 instr_ram2(.ena(instr_re), .wea(instr_we), .clka(clk), .addra(pc+1), .dina(instr_in2), .douta(instr2));
     blk_mem_gen_3 instr_ram3(.ena(instr_re), .wea(instr_we), .clka(clk), .addra(pc+2), .dina(instr_in3), .douta(instr3));
     blk_mem_gen_4 instr_ram4(.ena(instr_re), .wea(instr_we), .clka(clk), .addra(pc+3), .dina(instr_in4), .douta(instr4));
     wire [3:0] num1, num2, num3, num4, num5, num6, num7, num8;
     wire [7:0] instr1, instr2, instr3, instr4;
//     assign instr = {data3, data4, data1, data2};
     assign num1 = instr1[7:4];
     assign num2 = instr1[3:0];
     assign num3 = instr2[7:4];
     assign num4 = instr2[3:0];
     assign num5 = instr3[7:4];
     assign num6 = instr3[3:0];
     assign num7 = instr4[7:4];
     assign num8 = instr4[3:0];


     Register_file #(.DW(32), .AW(5)) reg_file(
         .clock(clk), 
         .load(RegWr),
         .addr1(rs1),
         .addr2(rs2),
         .waddr(rd), 
         .data(new_data),
         .outdata1(outdata1),
         .outdata2(outdata2), 
         .reset(rst));

     memory_unit #(.DATA_WIDTH(32), 
                   .WORDS(10), 
                   .ADDR_WIDTH(32), 
                   .mem_init(memory_init))
     data_memory (.addr(calc_result), .we(MemWr), .re(mem_read), .enable(1'b1), 
     .clock(clk), .data(mem_data), .rst(rst));
     assign mem_data = (MemWr) ? rs2 : 'hz;


endmodule