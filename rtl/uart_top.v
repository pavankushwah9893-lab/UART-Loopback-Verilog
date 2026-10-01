module UART1(
    input  wire clk,
    input  wire rst,
	 input wire st,
    input  wire rx,
    output wire tx,
	 output reg btn_out
);

wire [7:0] rx_buffer;
wire rx_done;
wire busy;
reg [7:0] tx_data;
//reg st;
reg rx_read;
reg [25:0]clk_div;
always@(posedge clk , negedge rst)begin
   if(!rst)begin
		clk_div <= 24'd0;
	  end
	  
	else
		clk_div <= clk_div + 24'b1;
		 
	end

wire slow_clk = clk_div[9];

// UART Receiver
RX_1 RX(
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .rx_read(rx_read),
    .rx_buffer(rx_buffer),
    .rx_done(rx_done)
);

// UART Transmitter
TX_1 TX(
    .clk(clk),
    .rst(rst),
    .st(~btn_out),
    .data_in(tx_data),
    .busy(busy),
    .tx(tx)
);

// Loopback Logic  
always @(posedge clk or negedge rst)
begin
    if(!rst)
    begin
        tx_data <= 8'd0;
       // st      <= 1'b0;
        rx_read <= 1'b0;
    end
    else
    begin
        //st      <= 1'b0;
        rx_read <= 1'b0;

        // New byte received
        if(rx_done && !busy)
        begin
            tx_data <= rx_buffer;
           // st      <= 1'b1;
            rx_read <= 1'b1;
        end
    end
end
wire my_rst;
reg [5:0]counter;
always@(negedge st , negedge my_rst)begin
    if(!my_rst)
        btn_out <= 1'b0;
    else
       btn_out <= 1'b1;
    end
  
      
always@(posedge slow_clk , negedge my_rst)begin
    if(!my_rst)
        counter <= 6'd0;
    else
        if(btn_out)
            counter <= counter + 6'd1;
    end
    
    assign my_rst = (!rst || counter == 6'd50)? 1'b0 : 1'b1;

endmodule
