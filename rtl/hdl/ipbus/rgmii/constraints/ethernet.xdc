# Timing constraints for Ethernet PHY 

# Clock Configuration for Ethernet PHY

create_clock -period 8.000 -name phy_rx_clk [get_ports rgmii_rx_clk]
create_generated_clock -name data_clk -source [get_pins {infra/clocks/bufg125/I}] [get_pins {infra/clocks/bufg125/O}] -divide_by 1

# Clock Delay and Timing Constraints for PHY
set min_v 0.2
set max_v 0.35
set clk_delay 0
set output_ports {rgmii_tx_ctl rgmii_txd[*]}
set clock_port {rgmii_gtx_clk}

set_output_delay -clock data_clk -max $max_v [get_ports $output_ports]
set_output_delay -clock data_clk -min $min_v [get_ports $output_ports]
set_output_delay -clock data_clk -max $max_v [get_ports $output_ports] -clock_fall -add_delay
set_output_delay -clock data_clk -min $min_v [get_ports $output_ports] -clock_fall -add_delay

set_output_delay -clock data_clk -max [expr $max_v + $clk_delay] [get_ports $clock_port]
set_output_delay -clock data_clk -min [expr $min_v + $clk_delay] [get_ports $clock_port]
set_output_delay -clock data_clk -max [expr $max_v + $clk_delay] [get_ports $clock_port] -clock_fall -add_delay
set_output_delay -clock data_clk -min [expr $min_v + $clk_delay] [get_ports $clock_port] -clock_fall -add_delay

# False Paths and Multicycle Paths
set_false_path -to [get_ports phy_rst]

