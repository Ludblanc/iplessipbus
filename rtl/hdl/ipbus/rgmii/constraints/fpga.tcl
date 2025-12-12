# Copyright (c) 2025 Ludovic Damien Blanc

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# General configuration
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]

# System clocks
# 200 MHz Clock Setup
set_property -dict {LOC E19 IOSTANDARD LVDS} [get_ports sysclk_p]
set_property -dict {LOC E18 IOSTANDARD LVDS} [get_ports sysclk_n]
create_clock -period 5.000 -name sysclk [get_ports sysclk_p]

set_false_path -through [get_pins infra/clocks/rst_reg/Q]
set_false_path -through [get_nets infra/clocks/nuke_i]

# LED Configuration
set_property -dict {LOC AM39 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {leds[0]}]
set_property -dict {LOC AN39 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {leds[1]}]
set_property -dict {LOC AR37 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {leds[2]}]
set_property -dict {LOC AT37 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {leds[3]}]
#set_property -dict {LOC AR35 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {led[4]}]
#set_property -dict {LOC AP41 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {led[5]}]
#set_property -dict {LOC AP42 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {led[6]}]
#set_property -dict {LOC AU39 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {led[7]}]

set_false_path -to [get_ports {leds[*]}]
set_output_delay 0.000 [get_ports {leds[*]}]

# Push buttons configuration
#set_property -dict {LOC AR40 IOSTANDARD LVCMOS18} [get_ports btnu]
#set_property -dict {LOC AU38 IOSTANDARD LVCMOS18} [get_ports btnl]
#set_property -dict {LOC AP40 IOSTANDARD LVCMOS18} [get_ports btnd]
#set_property -dict {LOC AW40 IOSTANDARD LVCMOS18} [get_ports btnr]
#set_property -dict {LOC AV39 IOSTANDARD LVCMOS18} [get_ports btnc]

#set_false_path -from [get_ports {btnu btnl btnd btnr btnc}]
#set_input_delay 0.000 [get_ports {btnu btnl btnd btnr btnc}]

# Toggle switches
set_property -dict {LOC AV30 IOSTANDARD LVCMOS18} [get_ports {dip_sw[0]}]
set_property -dict {LOC AY33 IOSTANDARD LVCMOS18} [get_ports {dip_sw[1]}]
set_property -dict {LOC BA31 IOSTANDARD LVCMOS18} [get_ports {dip_sw[2]}]
set_property -dict {LOC BA32 IOSTANDARD LVCMOS18} [get_ports {dip_sw[3]}]

set_false_path -from [get_ports {dip_sw[*]}]
set_input_delay 0.000 [get_ports {dip_sw[*]}]

# UART Configuration
#set_property -dict {LOC AU36 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports uart_txd]
#set_property -dict {LOC AU33 IOSTANDARD LVCMOS18} [get_ports uart_rxd]
#set_property -dict {LOC AR34 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports uart_rts]
#set_property -dict {LOC AT32 IOSTANDARD LVCMOS18} [get_ports uart_cts]

#set_false_path -to [get_ports {uart_txd uart_rts}]
#set_output_delay 0.000 [get_ports {uart_txd uart_rts}]
#set_false_path -from [get_ports {uart_rxd uart_cts}]
#set_input_delay 0.000 [get_ports {uart_rxd uart_cts}]
# 125MHz clock
create_generated_clock -name clk_125 -multiply_by 125 -divide_by 200  -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT1]


# IPbus clock
create_generated_clock -name ipbus_clk -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT3]

# Other derived clocks
create_generated_clock -name clk_aux -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT4]

# Declare the oscillator clock, ipbus clock and aux clock as unrelated
set_clock_groups -asynchronous -group [get_clocks sysclk] -group [get_clocks ipbus_clk] -group [get_clocks -include_generated_clocks [get_clocks clk_aux]]



#############################################################################
# Ethernet PHY Configuration with Switch for Port A and B
#############################################################################
# Define a variable to easily switch between ports A and B
set port "A" ; # Set to "B" for second Ethernet port
set mode_mac "RGMII_1" ; # Set to "RGMII_1" "RGMII_2" "MII" "RMII" for different modes

# after reset on the ethernet board, the mode is sampled on MACSIF_SEL0 and MACSIF_SEL1
# see https://www.analog.com/media/en/technical-documentation/data-sheets/adin1300.pdf
# +------------------------------------+------------+------------+
# |      MAC Interface Selection       | MACIF_SEL1 | MACIF_SEL0 |
# +------------------------------------+------------+------------+
# | RGMII RXC/TXC 2 ns Delay (default) | Low        | Low        |
# | RGMII RXC Only, 2 ns Delay         | High       | Low        |
# | MII                                | Low        | High       |
# | RMII                               | High       | High       |
# +------------------------------------+------------+------------+

## for all:
set_property PULLUP true [get_ports rgmii_mdio_a]

# specific to port A or B
if {$port == "A"} {
    set_property -dict {PACKAGE_PIN AC38 IOSTANDARD LVCMOS18} [get_ports {phy_rst}]
    #set_property -dict {PACKAGE_PIN Y42 IOSTANDARD LVCMOS18} [get_ports {rgmii_mdio_a}]

    set_property -dict {PACKAGE_PIN AK39 IOSTANDARD LVCMOS18} [get_ports {rgmii_rxd[0]}]
    set_property -dict {PACKAGE_PIN AL39 IOSTANDARD LVCMOS18} [get_ports {rgmii_rxd[1]}]
    set_property -dict {PACKAGE_PIN AJ42 IOSTANDARD LVCMOS18} [get_ports {rgmii_rxd[2]}]
    set_property -dict {PACKAGE_PIN AK42 IOSTANDARD LVCMOS18} [get_ports {rgmii_rxd[3]}]
    set_property -dict {PACKAGE_PIN AC41 IOSTANDARD LVCMOS18} [get_ports {rgmii_rx_ctl}]
    set_property -dict {PACKAGE_PIN AD40 IOSTANDARD LVCMOS18} [get_ports {rgmii_rx_clk}]

    set_property -dict {PACKAGE_PIN AJ38 IOSTANDARD LVCMOS18 SLEW FAST DRIVE 16} [get_ports {rgmii_txd[0]}]
    set_property -dict {PACKAGE_PIN AK38 IOSTANDARD LVCMOS18 SLEW FAST DRIVE 16} [get_ports {rgmii_txd[1]}]
    set_property -dict {PACKAGE_PIN AD38 IOSTANDARD LVCMOS18 SLEW FAST DRIVE 16} [get_ports {rgmii_txd[2]}]
    set_property -dict {PACKAGE_PIN AE38 IOSTANDARD LVCMOS18 SLEW FAST DRIVE 16} [get_ports {rgmii_txd[3]}]
    set_property -dict {PACKAGE_PIN AC40 IOSTANDARD LVCMOS18 SLEW FAST DRIVE 16} [get_ports {rgmii_tx_ctl}]
    set_property -dict {PACKAGE_PIN AL42 IOSTANDARD LVCMOS18 SLEW FAST DRIVE 16} [get_ports {rgmii_gtx_clk}]
} elseif {$port == "B"} {
    set_property -dict {PACKAGE_PIN AC39 IOSTANDARD LVCMOS18} [get_ports {phy_rst}]
    #set_property -dict {PACKAGE_PIN V35 IOSTANDARD LVCMOS18} [get_ports {rgmii_mdio_a}]
    
    set_property -dict {PACKAGE_PIN U32 IOSTANDARD LVCMOS18} [get_ports {rgmii_rxd[0]}]
    set_property -dict {PACKAGE_PIN U33 IOSTANDARD LVCMOS18} [get_ports {rgmii_rxd[1]}]
    set_property -dict {PACKAGE_PIN V33 IOSTANDARD LVCMOS18} [get_ports {rgmii_rxd[2]}]
    set_property -dict {PACKAGE_PIN V34 IOSTANDARD LVCMOS18} [get_ports {rgmii_rxd[3]}]
    set_property -dict {PACKAGE_PIN T35 IOSTANDARD LVCMOS18} [get_ports {rgmii_rx_ctl}]
    set_property -dict {PACKAGE_PIN U36 IOSTANDARD LVCMOS18} [get_ports {rgmii_rx_clk}]

    set_property -dict {PACKAGE_PIN P35 IOSTANDARD LVCMOS18 SLEW FAST DRIVE 16} [get_ports {rgmii_txd[0]}]
    set_property -dict {PACKAGE_PIN P36 IOSTANDARD LVCMOS18 SLEW FAST DRIVE 16} [get_ports {rgmii_txd[1]}]
    set_property -dict {PACKAGE_PIN W32 IOSTANDARD LVCMOS18 SLEW FAST DRIVE 16} [get_ports {rgmii_txd[2]}]
    set_property -dict {PACKAGE_PIN W33 IOSTANDARD LVCMOS18 SLEW FAST DRIVE 16} [get_ports {rgmii_txd[3]}]
    set_property -dict {PACKAGE_PIN U34 IOSTANDARD LVCMOS18 SLEW FAST DRIVE 16} [get_ports {rgmii_tx_ctl}]
    set_property -dict {PACKAGE_PIN R34 IOSTANDARD LVCMOS18 SLEW FAST DRIVE 16} [get_ports {rgmii_gtx_clk}]
}

if {$mode_mac == "RGMII_1"} {
    #did not put anything as default
    #set_property PULLDOWN true [get_ports rgmii_rx_ctl]; # MACSIF_SEL1
    #set_property PULLDOWN true [get_ports rgmii_rx_clk]; # MACSIF_SEL0
} elseif {$mode_mac == "RGMII_2"} {
    set_property PULLUP true [get_ports rgmii_rx_ctl]; # MACSIF_SEL1
    set_property PULLDOWN true [get_ports rgmii_rx_clk]; # MACSIF_SEL0
} elseif {$mode_mac == "MII"} {
    set_property PULLDOWN true [get_ports rgmii_rx_ctl]; # MACSIF_SEL1
    set_property PULLUP true [get_ports rgmii_rx_clk]; # MACSIF_SEL0
} elseif {$mode_mac == "RMII"} {
    set_property PULLUP true [get_ports rgmii_rx_ctl]; # MACSIF_SEL1
    set_property PULLUP true [get_ports rgmii_rx_clk]; # MACSIF_SEL0
}