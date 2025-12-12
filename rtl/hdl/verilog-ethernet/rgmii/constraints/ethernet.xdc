# Copyright (c) 2025 Ludovic Damien Blanc
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# Ethernet constraints

# Timing constraints for Ethernet PHY 

# Clock Configuration for Ethernet PHY
create_clock -period 8.000 -name phy_rx_clk [get_ports phy_rx_clk]
create_generated_clock -name data_clk -source [get_pins {clk_bufg_inst/I}] [get_pins {clk_bufg_inst/O}] -divide_by 1
# create_generated_clock -name data_clk_90 -source [get_pins {clk90_bufg_inst/I}] [get_pins {clk90_bufg_inst/O}] -divide_by 1
# create_generated_clock -name clk_out -source [get_pins {clk90_bufg_inst/O}] [get_ports phy_tx_clk] -divide_by 1

# Clock Delay and Timing Constraints for PHY
set min_v 0.2
set max_v 0.35
set clk_delay 0
set output_ports {phy_tx_ctl phy_txd[*]}
set clock_port {phy_tx_clk}

set_output_delay -clock data_clk -max $max_v [get_ports $output_ports]
set_output_delay -clock data_clk -min $min_v [get_ports $output_ports]
set_output_delay -clock data_clk -max $max_v [get_ports $output_ports] -clock_fall -add_delay
set_output_delay -clock data_clk -min $min_v [get_ports $output_ports] -clock_fall -add_delay

set_output_delay -clock data_clk -max [expr $max_v + $clk_delay] [get_ports $clock_port]
set_output_delay -clock data_clk -min [expr $min_v + $clk_delay] [get_ports $clock_port]
set_output_delay -clock data_clk -max [expr $max_v + $clk_delay] [get_ports $clock_port] -clock_fall -add_delay
set_output_delay -clock data_clk -min [expr $min_v + $clk_delay] [get_ports $clock_port] -clock_fall -add_delay

# False Paths and Multicycle Paths
set_false_path -to [get_ports phy_reset_n]