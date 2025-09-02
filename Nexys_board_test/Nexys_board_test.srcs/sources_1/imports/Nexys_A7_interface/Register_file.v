
module Register_file
#(parameter DW = 32,
            AW = 5,
            W = 2**AW)
(input wire clock, 
input wire [AW-1:0] addr1, addr2, waddr,
input wire [DW-1:0] data,
input wire load, reset,
output wire [DW-1:0] outdata1, outdata2);


    reg [DW-1:0] R[0:W];
    reg [DW-1:0] rData;
    

    always@(posedge clock) begin
        if(load) begin
                if(waddr == 0) begin
                    R[waddr] <= 32'd0;
                end
                else begin
                    R[waddr] <= data;
                end
        end
    end

    assign outdata1 = R[addr1];
    assign outdata2 = R[addr2]; 

    // assign test_num = R[3];
    // assign reg_data1 = R[0]; //x0
    // assign reg_data2 = R[17]; //a7 - 93 if pass

endmodule

