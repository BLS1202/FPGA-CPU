
`timescale 1 ns / 10 ps
`include "cpu_top.v"



module RV32ui_tb
#(
    parameter program_init = "addi_32_test.hex",
              memory_init = "memory_test.txt", 
              DATA_WIDTH = 16,
              ADDR_WIDTH = 32)();

    reg clock, reset, en; //program counter enable and reset
    wire[31:0] pc;
    wire instr_we, instr_re, instr_enable;
    wire [7:0] data1, data2, data3, data4;
    wire RegWr;
    wire [4:0] rs1, rs2, rd;
    wire [31:0] new_data, outdata1, outdata2;
    wire [31:0] test_num, reg_data1, reg_data2;
    wire [31:0] calc_result, mem_data;
    wire MemWr, mem_read;
    integer maxcycles =840;
    integer numcycles;
    reg [8*50:1] testcase; 
    // string testcase = "addi_32_test.hex";


    cpu_top #(.program(program_init), .memory(memory_init), 
    .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) 
    launch(.pc(pc), .instr_we(instr_we), .instr_enable(instr_enable),
    .instr_re(instr_re), .data1(data1), .data2(data2), .data3(data3),
    .data4(data4), .rs1(rs1), .rs2(rs2), .rd(rd), .new_data(new_data),
    .outdata1(outdata1), .outdata2(outdata2), .calc_result(calc_result),
    .mem_data(mem_data), .MemWr(MemWr), .mem_read(mem_read), .clock(clock), 
    .en(en), .reset(reset), .RegWr(RegWr));



    //instruction_mem
    memory_unit_instr #(.DATA_WIDTH(DATA_WIDTH), 
                        .WORDS(20000), 
                        .ADDR_WIDTH(ADDR_WIDTH)) 
    instr_mem(.addr(pc), 
            .data1(data1),
            .data2(data2),
            .data3(data3),
            .data4(data4),
            .we(instr_we), 
            .re(instr_re), 
            .enable(instr_enable), 
            .clock, 
            .rst(reset), 
            .mem_init(testcase));
    // wire [31:0] instr
    // assign instr = 
    //reg_file
    Register_file #(.DW(32), .AW(5)) reg_file(
        .clock, 
        .load(RegWr),
        .addr1(rs1),
        .addr2(rs2),
        .waddr(rd), 
        .data(new_data),
        .outdata1,
        .outdata2, 
        .reset(reset), 
        .test_num(test_num));

// .test_num(test_num)
// .reg_data1(reg_data1)
// .reg_data2(reg_data2))
    assign reg_data1 = reg_file.R[17];
    assign test_num = reg_file.R[3];
    //data_mem
    memory_unit #(.DATA_WIDTH(32), 
                  .WORDS(1024), 
                  .ADDR_WIDTH(32), 
                  .mem_init(memory_init))
    data_memory (.addr(calc_result), .we(MemWr), .re(mem_read), .enable(1'b1), 
    .clock, .data(mem_data), .rst(reset));
    assign mem_data = (MemWr) ? rs2 : 'hz;



    initial begin
        $dumpfile("rv32.vcd");
        $dumpvars();
    end

    task step;  //step for one cycle ends 1ns AFTER the posedge of the next cycle
        begin
            #9  clock=1'b0;
            #10 clock=1'b1;
            numcycles = numcycles + 1;
            #1 ;
        end
    endtask

    task run;
        integer i;
        begin
            i = 0;
            while(i<maxcycles)
                begin
                    step();
                    i = i+1;
                end
        end
    endtask

    task resetcpu;  //reset the CPU and the test
        begin
            reset = 1'b1;
            en = 0;
            step();
            #5 reset = 1'b0;
            en = 1;
            numcycles = 0;
            // $display("initialize register: %d",reg_file.R[17] );
        end
    endtask
    // initial begin
    //     clock = 0;
    //     forever #1 clock = ~clock;
    // end

    task checkregnum;
        begin
            // $display("register value: %d", reg_file.R[17]);
            // $display("register value: %d", reg_file.R[10]);
            if(numcycles>maxcycles)
                begin
                    $display("!!!Error:test case %s does not terminate!", testcase);
                end
            if(reg_file.R[17]==32'd93 && reg_file.R[10] == 32'd0)
                begin
                    $display("OK:test case %s finshed OK at cycle %d.",
                            testcase, numcycles-1);
                end
            else
                begin
                    $display("!!!ERROR:test case %s unknown error in cycle %d.",
                        testcase, numcycles-1);
                end
            // else if(reg_file.R[17]==32'h93 && numcycles < maxcycles && reg_file.R[10] == 0)
            //     begin
            //         $display("register value: %d", reg_file.R[17]);
            //         $display("register value: %d", reg_file.R[10]);
            //         $display("OK:test case %s finshed OK at cycle %d.",
            //                 testcase, numcycles-1);
            //     end
            // else if(reg_file.R[17]!=32'h93)
            //     begin
            //         $display("!!!ERROR:test case %s finshed with error in cycle %d.",
            //             testcase, numcycles-1);
            //     end
            // else
            //     begin
            //         $display("!!!ERROR:test case %s unknown error in cycle %d.",
            //             testcase, numcycles-1);
            //     end
        end
    endtask

    
    task run_riscv_test;
        begin
            // loadtestcase();
            // loaddatamem();
            resetcpu();
            run();
            checkregnum();
        end
    endtask

    initial begin
        // numcycles = 0;
        testcase = "../rv32ui-tests/rv32ui-p-add.hex";         run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-and.hex";         run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-andi.hex";        run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-auipc.hex";       run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-beq.hex";         run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-bge.hex";         run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-bgeu.hex";        run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-blt.hex";         run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-bltu.hex";        run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-bne.hex";         run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-jal.hex";         run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-jalr.hex";        run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-lb.hex";          run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-lbu.hex";         run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-lh.hex";          run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-lhu.hex";         run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-lui.hex";         run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-lw.hex";          run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-or.hex";          run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-ori.hex";         run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-sb.hex";          run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-sh.hex";          run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-sll.hex";         run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-slli.hex";        run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-slt.hex";         run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-slti.hex";        run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-sltiu.hex";       run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-sltu.hex";        run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-sra.hex";         run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-srai.hex";        run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-srl.hex";         run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-srli.hex";        run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-sub.hex";         run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-sw.hex";          run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-xor.hex";         run_riscv_test();
        testcase = "../rv32ui-tests/rv32ui-p-xori.hex";        run_riscv_test();
        $finish;
    end



endmodule


