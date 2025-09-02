

module Program_Counter
#(parameter ADDR_WIDTH = 32)
(input clock, reset, en,
input [ADDR_WIDTH-1:0] next_pc, 
output reg [ADDR_WIDTH-1:0] pc);


    always @(posedge clock) begin
        if(~reset) begin
            pc <= 32'd0;
        end
        else if(en) begin
            pc <= next_pc;
        end
    end

endmodule