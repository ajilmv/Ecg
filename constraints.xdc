############################################
## Clock
############################################
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -period 10.00 -name sys_clk [get_ports clk]

############################################
## MAX30003 SPI — PMOD JA
############################################

# MISO
set_property PACKAGE_PIN C17 IOSTANDARD LVCMOS33 [get_ports spi_miso]

# MOSI
set_property PACKAGE_PIN D18 IOSTANDARD LVCMOS33 [get_ports spi_mosi]

# SCLK
set_property PACKAGE_PIN E18 IOSTANDARD LVCMOS33 [get_ports spi_sclk]

# CS
set_property PACKAGE_PIN G17 IOSTANDARD LVCMOS33 [get_ports spi_cs]

# INT1 (optional)
set_property PACKAGE_PIN D17 IOSTANDARD LVCMOS33 [get_ports ecg_int]

############################################
## UART (USB to PC)
############################################

# FPGA → PC
set_property PACKAGE_PIN D4 IOSTANDARD LVCMOS33 [get_ports uart_tx]

# PC → FPGA (optional)
set_property PACKAGE_PIN C4 IOSTANDARD LVCMOS33 [get_ports uart_rx]
