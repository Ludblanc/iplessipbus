# General configuration
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]

# System clocks
# 200 MHz Clock Setup
set_property -dict {LOC E19 IOSTANDARD LVDS} [get_ports clk_200mhz_p]
set_property -dict {LOC E18 IOSTANDARD LVDS} [get_ports clk_200mhz_n]
create_clock -period 5.000 -name clk_200mhz [get_ports clk_200mhz_p]

set_property -dict {LOC AM39 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {led[0]}]
set_property -dict {LOC AN39 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {led[1]}]
set_property -dict {LOC AR37 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {led[2]}]
set_property -dict {LOC AT37 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {led[3]}]
set_property -dict {LOC AR35 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {led[4]}]
set_property -dict {LOC AP41 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {led[5]}]
set_property -dict {LOC AP42 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {led[6]}]
set_property -dict {LOC AU39 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {led[7]}]

set_false_path -to [get_ports {led[*]}]
set_output_delay 0.000 [get_ports {led[*]}]

# Push buttons configuration
set_property -dict {LOC AR40 IOSTANDARD LVCMOS18} [get_ports btnu]
set_property -dict {LOC AU38 IOSTANDARD LVCMOS18} [get_ports btnl]
set_property -dict {LOC AP40 IOSTANDARD LVCMOS18} [get_ports btnd]
set_property -dict {LOC AW40 IOSTANDARD LVCMOS18} [get_ports btnr]
set_property -dict {LOC AV39 IOSTANDARD LVCMOS18} [get_ports btnc]

set_false_path -from [get_ports {btnu btnl btnd btnr btnc}]
set_input_delay 0.000 [get_ports {btnu btnl btnd btnr btnc}]

# Toggle switches
set_property -dict {LOC AV30 IOSTANDARD LVCMOS18} [get_ports {sw[0]}]
set_property -dict {LOC AY33 IOSTANDARD LVCMOS18} [get_ports {sw[1]}]
set_property -dict {LOC BA31 IOSTANDARD LVCMOS18} [get_ports {sw[2]}]
set_property -dict {LOC BA32 IOSTANDARD LVCMOS18} [get_ports {sw[3]}]

set_false_path -from [get_ports {sw[*]}]
set_input_delay 0.000 [get_ports {sw[*]}]

# UART Configuration
set_property -dict {LOC AU36 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports uart_txd]
set_property -dict {LOC AU33 IOSTANDARD LVCMOS18} [get_ports uart_rxd]
set_property -dict {LOC AR34 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports uart_rts]
set_property -dict {LOC AT32 IOSTANDARD LVCMOS18} [get_ports uart_cts]

set_false_path -to [get_ports {uart_txd uart_rts}]
set_output_delay 0.000 [get_ports {uart_txd uart_rts}]
set_false_path -from [get_ports {uart_rxd uart_cts}]
set_input_delay 0.000 [get_ports {uart_rxd uart_cts}]

#############################################################################
# Ethernet PHY Configuration with Switch for Port A and B
#############################################################################
# Define a variable to easily switch between ports A and B
set port "A" ; # Set to "B" for second Ethernet port
set mode_mac "RMII" ; # Set to "RGMII_1" "RGMII_2" "MII" "RMII" for different modes

# after reset on the ethernet board, the mode is sampled on MACIF_SEL0 and MACIF_SEL1
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
    set_property -dict {PACKAGE_PIN AC38 IOSTANDARD LVCMOS18} [get_ports {phy_reset_n}]
    set_property -dict {PACKAGE_PIN Y42 IOSTANDARD LVCMOS18} [get_ports {rgmii_mdio_a}]

    set_property -dict {PACKAGE_PIN AK39 IOSTANDARD LVCMOS18} [get_ports {phy_rxd[0]}]
    set_property -dict {PACKAGE_PIN AL39 IOSTANDARD LVCMOS18} [get_ports {phy_rxd[1]}]
    set_property -dict {PACKAGE_PIN AG41 IOSTANDARD LVCMOS18} [get_ports {phy_rx_er}]

    set_property -dict {PACKAGE_PIN AC41 IOSTANDARD LVCMOS18} [get_ports {phy_crs_dv}]

    set_property -dict {PACKAGE_PIN AJ38 IOSTANDARD LVCMOS18 SLEW FAST DRIVE 16} [get_ports {phy_txd[0]}]
    set_property -dict {PACKAGE_PIN AK38 IOSTANDARD LVCMOS18 SLEW FAST DRIVE 16} [get_ports {phy_txd[1]}]
    set_property -dict {PACKAGE_PIN AC40 IOSTANDARD LVCMOS18 SLEW FAST DRIVE 16} [get_ports {phy_tx_en}]

    set_property -dict {PACKAGE_PIN J40 IOSTANDARD LVCMOS18 SLEW FAST DRIVE 16} [get_ports {phy_ref_clk}]
    
} elseif {$port == "B"} {
    set_property -dict {PACKAGE_PIN AC39 IOSTANDARD LVCMOS18} [get_ports {phy_reset_n}]
    set_property -dict {PACKAGE_PIN V35 IOSTANDARD LVCMOS18} [get_ports {rgmii_mdio_a}]
    
    set_property -dict {PACKAGE_PIN U32 IOSTANDARD LVCMOS18} [get_ports {phy_rxd[0]}]
    set_property -dict {PACKAGE_PIN U33 IOSTANDARD LVCMOS18} [get_ports {phy_rxd[1]}]
    set_property -dict {PACKAGE_PIN U38 IOSTANDARD LVCMOS18} [get_ports {phy_rx_er}]
    
    set_property -dict {PACKAGE_PIN U36 IOSTANDARD LVCMOS18} [get_ports {macif_sel0}]
    
    set_property -dict {PACKAGE_PIN T35 IOSTANDARD LVCMOS18} [get_ports {phy_crs_dv}]

    set_property -dict {PACKAGE_PIN P35 IOSTANDARD LVCMOS18 SLEW FAST DRIVE 16} [get_ports {phy_txd[0]}]
    set_property -dict {PACKAGE_PIN P36 IOSTANDARD LVCMOS18 SLEW FAST DRIVE 16} [get_ports {phy_txd[1]}]
    set_property -dict {PACKAGE_PIN U34 IOSTANDARD LVCMOS18 SLEW FAST DRIVE 16} [get_ports {phy_tx_en}]

    set_property -dict {PACKAGE_PIN L31 IOSTANDARD LVCMOS18 SLEW FAST DRIVE 16} [get_ports {phy_ref_clk}]
}

if {$mode_mac == "RGMII_1"} {
    #did not put anything as default
    #set_property PULLDOWN true [get_ports phy_rx_ctl]; # MACIF_SEL1
    #set_property PULLDOWN true [get_ports phy_rx_clk]; # MACIF_SEL0
} elseif {$mode_mac == "RGMII_2"} {
    set_property PULLUP true [get_ports phy_crs_dv];     # MACIF_SEL1
    set_property PULLDOWN true [get_ports macif_sel0];   # MACIF_SEL0
} elseif {$mode_mac == "MII"} {
    set_property PULLDOWN true [get_ports phy_crs_dv];   # MACIF_SEL1
   set_property PULLUP true [get_ports macif_sel0];      # MACIF_SEL0
} elseif {$mode_mac == "RMII"} {
    set_property PULLUP true [get_ports phy_crs_dv];     # MACIF_SEL1
   set_property PULLUP true [get_ports macif_sel0];      # MACIF_SEL0
    
}