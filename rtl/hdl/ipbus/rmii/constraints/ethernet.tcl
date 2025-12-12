## Copyright (c) 2025 Ludovic Damien Blanc
## Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
## The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# Clock Configuration for Ethernet PHY

create_clock -period 20.000 -name ref_clk [get_ports rmii_ref_clk]
create_generated_clock -name mii_clk -source [get_ports rmii_ref_clk] -divide_by 2 [get_pins infra/converter/rmii_mii_converter_inst/mii_clk_reg*/Q]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets rmii_ref_clk_IBUF]


# Timing constraints for Ethernet PHY

# TODO add documentation 

## Output Delay Constraints
set_output_delay -clock ref_clk -max 7.000 [get_ports {rmii_tx_en {rmii_txd[*]}}]
set_output_delay -clock ref_clk -min -2.500 [get_ports {rmii_tx_en {rmii_txd[*]}}]

# Input Delay Constraint
set_input_delay -clock ref_clk -max 6.000 [get_ports {rmii_crs_dv {rmii_rxd[*]}}]
set_input_delay -clock ref_clk -min 1.500 [get_ports {rmii_crs_dv {rmii_rxd[*]}}]