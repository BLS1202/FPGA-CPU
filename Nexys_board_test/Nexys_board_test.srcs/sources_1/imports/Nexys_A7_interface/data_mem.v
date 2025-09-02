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
    
    initial begin
        if(~rst) begin
            $readmemh(mem_init, M);
        end
    end

endmodule
