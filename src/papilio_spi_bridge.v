// Direct SPI flash bridge for the Papilio Retrocade.
//
// ESP32 GPIO1/2/3/4 are constrained to FPGA A9/L12/J11/F10.
// The bridge passes those signals directly to the onboard SPI flash.

`timescale 1ns/1ps

module papilio_spi_bridge (
    input  wire esp_clk,
    input  wire esp_cs_n,
    output wire esp_miso,
    input  wire esp_mosi,

    output wire spiflash_clk,
    output wire spiflash_cs_n,
    input  wire spiflash_miso,
    output wire spiflash_mosi
);

    assign spiflash_clk  = esp_clk;
    assign spiflash_mosi = esp_mosi;
    assign spiflash_cs_n = esp_cs_n;
    assign esp_miso      = spiflash_miso;

endmodule
