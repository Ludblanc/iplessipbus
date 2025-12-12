# Copyright (c) 2025 Ludovic Damien Blanc
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#------------------------------------------------------------------------------
#
# AUTHOR: Ludovic Damien Blanc
#
# PURPOSE: Generic do file for simulations
#
#------------------------------------------------------------------------------


# Restart simulation and remove waves
#restart -f -nowave

# Configure waveforms to remove long names
# config wave -signalnamewidth 1
radix -hex

set NumericStdNoWarnings 1
set StdArithNoWarnings 1
# Adds the waveforms in the testbench (otherwise .wlf is empty, but slower) recursively for 2 levels
add wave -recursive -depth 1 /*;

# Adds all waveforms in the testbench recursively for all levels
# add wave -recursive /*;


# Run until the end
# run -all
