# Copyright (c) 2025 Ludovic Damien Blanc
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#------------------------------------------------------------------------------
#
# AUTHOR: Ludovic Damien Blanc
#
# PURPOSE: Generic TCL script for Modelsim simulations
#
#------------------------------------------------------------------------------

# The wildcard command of Modelsim does not match unpacked arrays (memories), so  add this
# See: https://www.reddit.com/r/FPGA/comments/c3hork/why_do_unpacked_arrays_not_show_up_in_modelsim/
set WildcardFilter [lsearch -not -all -inline $WildcardFilter Memory];


# Adds the waveforms in the testbench (otherwise .wlf is empty, but slower) recursively for 2 levels
# add wave -recursive -depth 2 /*;
# Adds all waveforms in the testbench recursively for all levels
add wave -recursive /*;


set DefaultRadix hex;
# Ignore integer warnings from IEEE 'numeric_std' at time 0.
set NumericStdNoWarnings 1;
#run 0;
#set NumericStdNoWarnings 0;

run -all;

exit;
