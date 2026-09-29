// Direct SPI flash bridge for the Papilio Retrocade.
//
// ESP32 GPIO1/2/3/4 are constrained to FPGA A9/L12/J11/F10.
// The bridge passes those signals directly to the onboard SPI flash.

`timescale 1ns/1ps

module papilio_spi_bridge (
    input  wire clk_27mhz,
    input  wire rst_n,
    input  wire esp_clk,
    input  wire esp_cs_n,
    output wire esp_miso,
    input  wire esp_mosi,

    output wire spiflash_clk,
    output wire spiflash_cs_n,
    input  wire spiflash_miso,
    output wire spiflash_mosi,
    output wire rgb_led
);

    reg [24:0] blink_counter;
    reg blink_on;
    wire [23:0] led_color;

    initial begin
        blink_counter = 25'd0;
        blink_on = 1'b1;
    end

    always @(posedge clk_27mhz or negedge rst_n) begin
        if (!rst_n) begin
            blink_counter <= 25'd0;
            blink_on <= 1'b1;
        end else if (blink_counter == 25'd26_999_999) begin
            blink_counter <= 25'd0;
            blink_on <= ~blink_on;
        end else begin
            blink_counter <= blink_counter + 1'b1;
        end
    end

    // WS2812B uses GRB order. Dim purple is red=8, blue=8.
    assign led_color = blink_on ? 24'h000808 : 24'h000000;

    ws2812b u_ws2812b (
        .clk(clk_27mhz),
        .rst_n(rst_n),
        .led_color_in(led_color),
        .dout(rgb_led)
    );

    assign spiflash_clk  = esp_clk;
    assign spiflash_mosi = esp_mosi;
    assign spiflash_cs_n = esp_cs_n;
    assign esp_miso      = spiflash_miso;

endmodule
