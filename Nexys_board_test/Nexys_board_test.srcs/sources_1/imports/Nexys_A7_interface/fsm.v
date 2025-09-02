module debounce
(input clk, rst,
output add,
input incr);
    parameter MS_MAX = 20'd499_999;
    reg add_flag;
    assign add = add_flag;
    reg [19:0] ms_count;

    always@(posedge clk or negedge rst) begin
        if(~rst)
            ms_count <= 0;
        else begin
            if ((incr == 0))
                ms_count <= 0;
            else begin
                if(ms_count == MS_MAX)
                    ms_count <= ms_count;
                else
                    ms_count = ms_count + 1;    
            end
        end
    end

    always@(posedge clk or negedge rst)
        if(~rst)
            add_flag <= 0;
        else if (ms_count == MS_MAX - 1) begin
            if(incr == 1)
                add_flag <= 1; 
        end else
            add_flag <= 0;

    

endmodule
    

