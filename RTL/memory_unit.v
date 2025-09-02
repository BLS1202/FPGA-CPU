// `include "library.v"

module memory_unit
#(parameter mem_init = "",
  parameter WORDS = 1024,
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 10)
(input [ADDR_WIDTH-1:0] addr,
inout [DATA_WIDTH-1:0] data,
input clock, enable, we, re,
input rst);

    reg [DATA_WIDTH-1:0] M[0:WORDS];
    reg [DATA_WIDTH-1:0] tmp_data;

    always @(posedge clock) begin
        if(enable) begin
            if(we) 
                M[addr] <= data;
        end
    end

    assign data = (enable && re) ? tmp_data : 'hz;

    always @* begin
        tmp_data = M[addr];
    end

    // initial begin
    //     if(mem_init != "") begin
    //         $readmemh(mem_init, M);
    //     end
    // end
    initial begin
        if(rst) begin
            $readmemh(mem_init, M);
        end
    end

endmodule




module memory_unit_instr
// #(parameter mem_init = "",
#(
  parameter WORDS = 1024,
  parameter DATA_WIDTH = 16,
  parameter ADDR_WIDTH = 10,
  parameter ACT_WIDTH = DATA_WIDTH/2)
(input [ADDR_WIDTH-1:0] addr,
inout [ACT_WIDTH-1:0] data1,data2,data3, data4,
input clock, enable, we, re,
input rst, 
input [8*50:1] mem_init);


    reg [DATA_WIDTH-1:0] M[0:WORDS];       //for reading
    reg [ACT_WIDTH-1:0] mem8 [0:WORDS]; //actual memory
    reg [ACT_WIDTH-1:0] tmp_data1, tmp_data2, tmp_data3, tmp_data4;


    always @* begin
        if(rst) begin
            $readmemh(mem_init, M);
            $display("filename: %s",mem_init);
        end
        for(integer i = 0; i < 20000; i = i + 1) begin
                mem8[2*i] = M[i][7:0];
                mem8[2*i+1] = M[i][15:8];
        end
    end

    always @(posedge clock) begin
        if(enable) begin
            if(we) 
                mem8[addr] <= data1;
                mem8[addr+1] <= data2;
                mem8[addr+2] <= data3;
                mem8[addr+3] <= data4;
        end
    end

    assign data1 = (enable && re) ? tmp_data1 : 'hz;
    assign data2 = (enable && re) ? tmp_data2 : 'hz;
    assign data3 = (enable && re) ? tmp_data3 : 'hz;
    assign data4 = (enable && re) ? tmp_data4 : 'hz;

    always @* begin
        tmp_data1 = mem8[addr];
        tmp_data2 = mem8[addr+1];
        tmp_data3 = mem8[addr+2];
        tmp_data4 = mem8[addr+3];
    end



endmodule