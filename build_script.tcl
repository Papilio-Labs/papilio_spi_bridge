# Build script for the Papilio Retrocade SPI flash bridge.

open_project project.gprj
set_option -top_module papilio_spi_bridge

# The bridge explicitly exposes the onboard MSPI pins as regular I/O.
set_option -use_mspi_as_gpio 1

# Keep runtime reconfiguration aligned with the loader's flash write address.
set_option -multi_boot 1
set_option -spi_flash_addr 0x00000000

run all
exit
