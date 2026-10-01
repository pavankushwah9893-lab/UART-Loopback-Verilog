module RX_1 (
    input wire clk,          
    input wire rst,          
    input wire rx,           
    input wire rx_read,      
    output reg [7:0] rx_buffer,  
    output reg rx_done       
);

    // Parameters
    parameter CLK_FREQ   = 100_000_000;  // System clock frequency in Hz
    parameter BAUD_RATE  = 9600;        // Baud rate
    parameter OVERSAMPLE = 16;          // Oversampling factor (standard)

    localparam BAUD_TICK_COUNT = CLK_FREQ / (BAUD_RATE * OVERSAMPLE);
    localparam HALF_BIT        = OVERSAMPLE / 2;  // Sample in the middle of the bit
	
    // Internal signals
    reg [$clog2(BAUD_TICK_COUNT)-1:0] baud_counter;
    reg [3:0] bit_index;           // 0-7 for data bits, plus start/stop
    reg [3:0] oversample_counter;  // 0-15 oversample ticks
    reg rx_reg, rx_meta;           // Metastability synchronizer

    // State machine
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;
    reg [1:0] state;

    // Synchronize rx input
    always @(posedge clk) begin
        rx_meta <= ~rx;
        rx_reg  <= rx_meta;
    end
	reg [7:0] rx_buffer1;
	always @(posedge clk) begin
		if (!rst)
				rx_buffer <= 8'd0;
		else
			if (rx_done)
				rx_buffer <= rx_buffer1;
	end
    // Main UART RX logic
    always @(posedge clk) begin
        if (!rst) begin
            state         <= IDLE;
            rx_done       <= 1'b0;
            rx_buffer1     <= 8'b0;
            baud_counter  <= 0;
            oversample_counter <= 0;
            bit_index     <= 0;
        end else begin
            // rx_read clears done flag (priority)
            if (rx_read) begin
                rx_done <= 1'b0;
            end

            case (state)
                IDLE: begin
                    baud_counter  <= 0;
                    oversample_counter <= 0;
                    bit_index     <= 0;
                    if (~rx_reg) begin  // Start bit detected (falling edge)
                        state <= START;
                    end
                end

                START: begin
                    // Wait for middle of start bit
                    if (baud_counter == BAUD_TICK_COUNT - 1) begin
                        baud_counter <= 0;
                        oversample_counter <= oversample_counter + 1;
                        
                        if (oversample_counter == HALF_BIT - 1) begin
                            if (~rx_reg) begin  // Confirm start bit is still low
                                oversample_counter <= 0;
                                state <= DATA;
                            end else begin
                                state <= IDLE;  // False start
                            end
                        end
                    end else begin
                        baud_counter <= baud_counter + 1;
                    end
                end

                DATA: begin
                    if (baud_counter == BAUD_TICK_COUNT - 1) begin
                        baud_counter <= 0;
                        oversample_counter <= oversample_counter + 1;
                        
                        if (oversample_counter == OVERSAMPLE - 1) begin
                            // Sample data bit (LSB first)
                            rx_buffer1[bit_index] <= rx_reg;
                            bit_index <= bit_index + 1;
                            oversample_counter <= 0;
                            
                            if (bit_index == 7) begin
                                state <= STOP;
                            end
                        end
                    end else begin
                        baud_counter <= baud_counter + 1;
                    end
                end

                STOP: begin
                    if (baud_counter == BAUD_TICK_COUNT - 1) begin
                        baud_counter <= 0;
                        oversample_counter <= oversample_counter + 1;
                        
                        if (oversample_counter == OVERSAMPLE - 1) begin
                            // Check stop bit (should be high)
                            if (rx_reg) begin
                                rx_done <= 1'b1;  // Successful reception
                            end
                            // else: framing error (ignore for simplicity)
                            state <= IDLE;
                        end
                    end else begin
                        baud_counter <= baud_counter + 1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
