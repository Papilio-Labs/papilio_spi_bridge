# papilio_spi_bridge

Standalone Gowin FPGA SPI flash bridge for the Papilio Retrocade.

This repository contains the direct passthrough bridge used by the Papilio ESP32 loader to access the FPGA's external SPI flash. It is intentionally independent of the older `papilio_tang_bootloader` project and does not include LED, timer, or application logic.

## Signal mapping

ESP32-S3 to FPGA user I/O:

| ESP32 GPIO | FPGA pin | Signal |
| ---: | :---: | :--- |
| GPIO1 | A9 | SPI clock |
| GPIO2 | L12 | SPI MOSI |
| GPIO3 | J11 | SPI chip select |
| GPIO4 | F10 | SPI MISO |

FPGA bridge to the onboard SPI flash:

| FPGA signal | FPGA pin | Flash signal |
| --- | :---: | --- |
| `spiflash_clk` | L10 | clock |
| `spiflash_mosi` | R10 | MOSI |
| `spiflash_cs_n` | M9 | chip select |
| `spiflash_miso` | P10 | MISO |

The ESP32 loader writes the FPGA bitstream at flash address `0x000000`. The build script keeps the Gowin multi-boot address aligned with that location.

## Module

`papilio_spi_bridge` is a combinational SPI passthrough:

```verilog
assign spiflash_clk = esp_clk;
assign spiflash_mosi = esp_mosi;
assign spiflash_cs_n = esp_cs_n;
assign esp_miso = spiflash_miso;
```

The bridge has no clocked logic and does not interpret SPI commands.

## Build

Use Gowin EDA's `gw_sh` from this repository root:

```powershell
gw_sh build_script.tcl
```

The generated bitstream is written by Gowin under `impl/pnr/project.bin`.

The build requires MSPI pins to be exposed as regular GPIO because the bridge explicitly connects them in the top-level module.

## Programming

This project produces the temporary SRAM bridge used during external flash updates. A host loader must:

1. Load the bridge into FPGA SRAM through JTAG.
2. Wait for the bridge to settle.
3. Access the external SPI flash through the ESP32 GPIO1-GPIO4 mapping.
4. Write the target bitstream at address `0x000000`.
5. Trigger the FPGA's normal reconfiguration path when immediate activation is required.

## Validation

A working bridge reports the external flash JEDEC ID `0x0b4017` and an 8 MiB capacity on the validated Retrocade hardware.

## Supported hardware

- Papilio Retrocade
- Gowin GW2A-18C / GW2A-LV18PG256C8/I7
