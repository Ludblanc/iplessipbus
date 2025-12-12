# Copyright (c) 2025 Ludovic Damien Blanc
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Ethernet constraints

# Timing constraints for Ethernet PHY 

# Clock Configuration for Ethernet PHY

create_clock -period 40.000 -name phy_rx_clk [get_ports phy_rx_clk]
create_clock -period 40.000 -name phy_tx_clk [get_ports phy_tx_clk]

create_generated_clock -name data_clk -source [get_pins {mii_bufg_inst/I}] [get_pins {mii_bufg_inst/O}] -divide_by 1


set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets phy_tx_clk_IBUF]

#  Rising Edge Source Synchronous Outputs 
#
#  Source synchronous output interfaces can be constrained either by the max data skew
#  relative to the generated clock or by the destination device setup/hold requirements.
#
#  Setup/Hold Case:
#  Setup and hold requirements for the destination device and board trace delays are known.
#  
# forwarded         ____                      ___________________ 
# clock                 |____________________|                   |____________ 
#                                            |
#                                     tsu    |    thd
#                                <---------->|<--------->
#                                ____________|___________
# data @ destination    XXXXXXXXX________________________XXXXX
#

set fwclk        data_clk;         # forwarded clock name (generated using create_generated_clock at output clock port)        
set tsu          12.000;           # destination device setup time requirement
set thd          3.000;            # destination device hold time requirement
set trce_dly_max 0.000;            # maximum board trace delay
set trce_dly_min 0.000;            # minimum board trace delay
set output_ports {phy_tx_en phy_txd[*]};   # list of output ports

## Output Delay Constraints
set_output_delay -clock $fwclk -max [expr $trce_dly_max + $tsu] [get_ports $output_ports];
set_output_delay -clock $fwclk -min [expr $trce_dly_min - $thd] [get_ports $output_ports];
		
## Input Delay Constraints		
#set input_ports {phy_rx_er phy_rx_dv phy_rxd[*]}
#set_input_delay -clock phy_rx_clk -max [expr $trce_dly_max + $thd] [get_ports $input_ports];
#set_input_delay -clock phy_rx_clk -min [expr $trce_dly_min - $thd] [get_ports $input_ports];


# False Paths and Multicycle Paths
set_false_path -to [get_ports phy_reset_n]

# old constraints for RGMII

#set_false_path -to [get_ports {phy_ref_clk phy_reset_n}]
#set_output_delay 0 [get_ports {phy_ref_clk phy_reset_n}]

# Clock Delay and Timing Constraints for PHY
#set min_v 0.2
#set max_v 0.35
#set clk_delay 0
#set output_ports {phy_tx_en phy_txd[*]}
#set clock_port {phy_tx_clk}

#set_output_delay -clock data_clk -max $max_v [get_ports $output_ports]
#set_output_delay -clock data_clk -min $min_v [get_ports $output_ports]
#set_output_delay -clock data_clk -max $max_v [get_ports $output_ports] -clock_fall -add_delay
#set_output_delay -clock data_clk -min $min_v [get_ports $output_ports] -clock_fall -add_delay

#set_output_delay -clock data_clk -max [expr $max_v + $clk_delay] [get_ports $clock_port]
#set_output_delay -clock data_clk -min [expr $min_v + $clk_delay] [get_ports $clock_port]
#set_output_delay -clock data_clk -max [expr $max_v + $clk_delay] [get_ports $clock_port] -clock_fall -add_delay
#set_output_delay -clock data_clk -min [expr $min_v + $clk_delay] [get_ports $clock_port] -clock_fall -add_delay




