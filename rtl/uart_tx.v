module TX_1(
 input        clk,
 input        rst,
 input   		st,
 input        [7:0]data_in,
 output       busy,
 output    	  tx

);

reg [1:0] NS, PS;
reg [10:0] shift_reg;
reg [3:0] counter;
reg [14:0] baud_rate;
reg baud_clk;
//reg  [7:0] data_in;

assign busy = (PS == start || PS == data);


parameter
    idle  = 2'd0,
    start = 2'd1,
    data  = 2'd2,
    stop  = 2'd3;

// Baud rate generator (50 MHz -> 9600 baud)
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        baud_rate <= 12'd0;
        baud_clk  <= 1'b0;
    end
    else begin
			baud_clk <= 1'b0;
        if (baud_rate == 14'd9600) begin
            baud_rate <= 14'd0;
            baud_clk  <= 1'b1;
        end
        else begin
            baud_rate <= baud_rate + 14'd1;
        end
    end
end

// Present state
always @(posedge clk or negedge rst) begin
    if (!rst)
        PS <= idle;
    else
		if(baud_clk)
        PS <= NS;
end

// Next state logic
always @(*) begin
    case (PS)

        idle: begin
					if (!st)
                NS = start;
            else
					NS = idle;
        end

        start: begin
            NS = data;
        end

        data: begin
            if (counter == 4'd8)
                NS = stop;
            else
                NS = data;
        end

        stop: begin
			  
            NS = idle;
			
        end

        default: NS = idle;

    endcase
end

// Shift register and counter
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        shift_reg <= 10'h3FF;
        counter   <= 4'd0;
    end
    else begin
		if (baud_clk)
        case (PS)

            idle: begin
                counter <= 4'd0;
					 shift_reg <= 10'h3ff;
					 end
					 
                //frame load in start state
			start:
                    shift_reg <= {1'b1, data_in, 2'b01};
//						  led <= data_in;
            

            data: begin
                shift_reg <= { 1'b1,shift_reg[10:1]};
                counter   <= counter + 4'd1;
            end
				stop:begin
					counter <= 4'd0;
				
					end
						
        endcase
    end
end
assign tx = ~shift_reg[0];
endmodule
