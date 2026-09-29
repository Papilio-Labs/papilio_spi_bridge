// WS2812B driver adapted from papilio_tang_bootloader/fpga/src/ws2812b.v.
// Timing is for the Retrocade's 27 MHz FPGA clock.

module ws2812b(
    input wire clk,
    input wire rst_n,
    input wire [23:0] led_color_in,
    output reg dout
);

    parameter T0H = 9;
    parameter T0L = 22;
    parameter T1H = 19;
    parameter T1L = 16;
    parameter RES = 1350;

    reg [1:0] state;
    localparam IDLE = 2'b00;
    localparam SEND = 2'b01;
    localparam RESET = 2'b10;

    reg [9:0] bit_counter;
    // RES is 1,350 cycles, so this counter needs 11 bits.
    reg [10:0] cycle_counter;
    reg [23:0] led_data;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            dout <= 1'b0;
            bit_counter <= 10'd0;
            cycle_counter <= 11'd0;
            led_data <= 24'd0;
        end else begin
            case (state)
                IDLE: begin
                    dout <= 1'b0;
                    bit_counter <= 10'd23;
                    cycle_counter <= 11'd0;
                    led_data <= led_color_in;
                    state <= SEND;
                end

                SEND: begin
                    if (cycle_counter == 0) begin
                        dout <= 1'b1;
                    end else if (led_data[bit_counter] && cycle_counter == T1H) begin
                        dout <= 1'b0;
                    end else if (!led_data[bit_counter] && cycle_counter == T0H) begin
                        dout <= 1'b0;
                    end

                    if ((led_data[bit_counter] && cycle_counter == (T1H + T1L - 1)) ||
                        (!led_data[bit_counter] && cycle_counter == (T0H + T0L - 1))) begin
                        cycle_counter <= 11'd0;
                        if (bit_counter == 0) begin
                            state <= RESET;
                        end else begin
                            bit_counter <= bit_counter - 1'b1;
                        end
                    end else begin
                        cycle_counter <= cycle_counter + 1'b1;
                    end
                end

                RESET: begin
                    dout <= 1'b0;
                    if (cycle_counter == RES - 1) begin
                        state <= IDLE;
                        cycle_counter <= 11'd0;
                    end else begin
                        cycle_counter <= cycle_counter + 1'b1;
                    end
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule