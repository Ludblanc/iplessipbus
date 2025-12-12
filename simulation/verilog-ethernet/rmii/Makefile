# Copyright (c) 2025 Ludovic Damien Blanc

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#==============================================================================
#
# AUTHOR: Andreas Toftegaard Kristensen, 
# adapted for this project, by ludo
#
# BRIEF: Makefile for Modelsim
#
# DESCRIPTION: LUDO: INCLUDE support of cocotb
#
# EXAMPLES:
# Compile the toplevel block
# > make toplevel
#
# Compile a PE block testbench
# > make tb_toplevel
#
# Simulate the toplevel (with and without GUI)
# > make sim_toplevel
# > make sim_toplevel -GUI=1
#
#==============================================================================

command_header = 
# epfl
#command_header = ""

vcom    =$(command_header) vcom
vlib    =$(command_header) vlib
vlog    =$(command_header) vlog
vopt    =$(command_header) vopt
vsim 	=$(command_header) vsim 
sdfcom  =$(command_header) sdfcom
vacom   =$(command_header) vacom
valib   =$(command_header) valib
vaspi   =$(command_header) vaspi
vasim   =$(command_header) vasim
vmap    =$(command_header) vmap
wlf2vcd	=$(command_header) wlf2vcd

#------------------------------------------------------------------------------
# DIRECTORIES
#------------------------------------------------------------------------------

# Main directories
RTL_DIR=../../../rtl/hdl/verilog-ethernet/rmii/rtl/
RTL_DIR2=../../../rtl/hdl/ipbus/rmii/rtl/
TB_DIR =../../tb/verilog-ethernet/
LIBRTL = ../../../rtl/ip/verilog-ethernet/
# IP_DIR=./ip
# GATE_DIR = ../lib/eth/example/PYNQ_TCL/fpga_rmii/gate

# Misc
DO_DIR     =./sim/do
SCRIPT_DIR =./sim/scripts
SCRATCH_DIR_LN=./sim/scratch

# Output directories
export OUTPUT_DIR=$(SCRATCH_DIR_LN)/output

#------------------------------------------------------------------------------
# MODULES/LIBRARIES
#------------------------------------------------------------------------------

LIB =$(SCRATCH_DIR_LN)/work

#------------------------------------------------------------------------------
# CLEAN
#------------------------------------------------------------------------------

# We use echo_sep as a global pre-requisite to always run it
# https://stackoverflow.com/questions/52718536/global-prerequisite-in-gnu-make-is-it-possible
-include echo_sep

#.PHONY: clean echo_sep
.PHONY: echo_sep
# Clean up the directory
clean:
	mkdir -p ./sim/
	mkdir -p ./modelsim/rmiimii
	rm -f $(SCRATCH_DIR_LN)

	ln -sf ../modelsim/rmiimii $(SCRATCH_DIR_LN)
	rm -rf $(OUTPUT_DIR)
	mkdir $(OUTPUT_DIR)
	rm -f *.wlf *.vcd transcript *.mpf *.mti *.out *.in *.ini *.dbg
	rm -rf $(LIB)
	$(vlib) $(LIB)

#------------------------------------------------------------------------------
# BASE COMPILATION
#------------------------------------------------------------------------------

# Logfiles
VCOM_LOG=$(OUTPUT_DIR)/vcom_compile.log
VLOG_LOG=$(OUTPUT_DIR)/vlog_compile.log
VOPT_LOG=$(OUTPUT_DIR)/vopt.log
STAT_LOG=$(OUTPUT_DIR)/static_checks.txt

# COMMON_FLAGS: Common flags to simulation and compilation
# -64           Uses 64-bit executable (default is 32)
# -fsmdebug     Allows access to FSMs for debugging
# -hazards      Detects event order hazards (must also be used for vsim)
COMMON_FLAGS=-64 -fsmdebug 

# +acc enables design object visibility as optimization otherwise removes access (may make simulation slower)
# If <spec> is omitted, access is enabled for all objects.
# -novopt is deprecated, so +acc is needed for design visibility
VOPTARGS=+acc
# VOPTARGS=

# COMP_FLAGS: Compilation flags
# -fsmverbose   Displays information on detected FSMs
# -incr         Performs incremental compilation (REVISIT: Not supported in 2020.4 for VHDL)
# -lint         Issues warnings on lint-style static checks
# -nodebug      compiles and hides the internal data, plus the ports, of the lower-level design unit
# -nologo       Removes startupbanner
# -source       Displays line of source code before each error message
#
# -O0 | -O1 | -O4 | -O5   Controls the optimization level (increasing, -O4 is default)
#
COMP_FLAGS_VERILOG=$(COMMON_FLAGS) -incr -nologo -source $(VOPTARGS)

# COMP_FLAGS_VHDL=$(COMMON_FLAGS) -nologo -source $(VOPTARGS)
COMP_FLAGS_VHDL=$(COMMON_FLAGS) -nologo -source


# VLOG_FLAGS: Flags for compiling Verilog and SystemVerilog
# -sv         Enables SystemVerilog features and keywords (if .sv extension, MSIM uses SV)
# -sv12compat Ensure compatibility with keyword set of IEEE Std 1800-2012 (REVISIT: SystemVerilog 2017?)
# -logfile    Logfile name
# +incdir+    Specifies directories to search for files included with `include compiler directives
VLOG_FLAGS=$(COMP_FLAGS_VERILOG) -sv -sv12compat -logfile $(VLOG_LOG) +incdir+$(RTL_DIR)

# VLOG_TB_FLAGS: Flags for compiling Verilog and SystemVerilog testbenches
# -assertdebug  Allows you to debug SVA/PSL objects when used with vsim -assertdebug
# +incdir       Searches directory for files (such as .svh)
VLOG_TB_FLAGS=$(VLOG_FLAGS) -assertdebug +incdir+$(TB_DIR)/utils

# VCOM_FLAGS: Flags for compiling VHDL code
# -2008               Enables VHDL 2008
# -check_synthesis    Performs some synthesis checks
# -logfile            Logfile name
# -explicit           Directs the compiler to resolve ambiguous function overloading by favoring the explicit function definition over the implicit function definition.
# VCOM_FLAGS=$(COMP_FLAGS_VHDL) -2008 -logfile $(VCOM_LOG)
VCOM_FLAGS=$(COMP_FLAGS_VHDL) -logfile $(VCOM_LOG)

# VCOM_TB_FLAGS: Flags for compiling VHDL testbenches
VCOM_TB_FLAGS=$(VCOM_FLAGS)

# b: Branch statistics
# c: Condition statistics
# e: Expression statistics
# s: Statement statistics
# t: Toggle statistics
# x: Extended toggle statistics (precendence over t)
# f: FSM statistics
COV_FLAGS=+cover=bcesxf

#------------------------------------------------------------------------------
# BASE SIMULATION
#------------------------------------------------------------------------------

# If no GUI, then set flags accordingly (-c for console -gui for GUI)
GUI=0
ifeq ($(GUI),0)
	GUI_FLAG=-c
else
	GUI_FLAG=-gui
endif

ifeq ($(GUI),0)
	DO_FLAG="$(TCL_FILE)"
else
	DO_FLAG="$(DO_FILE)"
endif

DO_FILE=$(DO_DIR)/default.do
TCL_FILE=$(SCRIPT_DIR)/default.tcl

SIM_LOG=$(OUTPUT_DIR)/simulation.log
WLF_FILE=$(OUTPUT_DIR)/vsim.wlf
VCD_FILE=$(OUTPUT_DIR)/vsim.vcd
SAIF_FILE=$(OUTPUT_DIR)/vsim.saif

# Arguments passed from the command line with GEN_ARGS=
GEN_ARGS =
# REVISIT: Check if these are actually doing anything
PLUSARGS=\
	+LOG_INFO_FILE=$(SIM_LOG) \
	+LOG_WARN_FILE=$(SIM_LOG) \
	+LOG_ERROR_FILE=$(SIM_LOG)

# SIM_FLAGS: Common flags for simulation
# -displaymsgmode Outputs messages to both the transcript and the WLF file
# -msgmode        Location(s) for the simulator to output elaboration and runtime
# -debugdb        (optional) Instructs Questa SIM to generate a database of connectivity information to use for post-sim debug in the Dataflow and Schematic windows.
# -donotcollapsepartiallydriven (optional) Prevents the collapse of partially driven and undriven output ports during optimization.
SIM_FLAGS=$(COMMON_FLAGS) -displaymsgmode both -msgmode both -t ns -logfile $(SIM_LOG) -wlf $(WLF_FILE) -debugdb
#SIM_FLAGS=$(COMMON_FLAGS) -displaymsgmode both -msgmode both -t ns -logfile $(SIM_LOG)

# VSIM_FLAGS: Flags for vsim
# VSIM_FLAGS=$(GUI_FLAG) $(SIM_FLAGS) -vopt -voptargs="$(VOPTARGS)" $(PLUSARGS) $(GEN_ARGS)
VSIM_FLAGS=$(GUI_FLAG) $(SIM_FLAGS) -vopt $(PLUSARGS) $(GEN_ARGS)

# VSIM_FLAGS_VHDL
# -nocollapse	 (optional) Disables the optimization of internal port map connections.
#------------------------------------------------------------------------------
# COCOTB COMMANDS
#------------------------------------------------------------------------------
#include $(shell cocotb-config --makefiles)/Makefile.inc
export LIBPYTHON_LOC := $(shell cocotb-config --libpython)
FLI_LIB := $(shell cocotb-config --lib-name-path fli questa)
export GPI_EXTRA := $(shell cocotb-config --lib-name-path vpi questa):cocotbvpi_entry_point
COCOTBTESTBENCH_DIR = $(TB_DIR)
export PYTHONPATH := $(COCOTBTESTBENCH_DIR):$(PYTHONPATH)

orbgrand_test_dir = python_model
export PYTHONPATH:= $(orbgrand_test_dir):$(PYTHONPATH)
#------------------------------------------------------------------------------
# MISC COMMANDS
#------------------------------------------------------------------------------

# Generates a .vcd file from the modelsim .wlf file to view in other editors
gen_vcd:
	$(wlf2vcd) $(WLF_FILE) -o $(VCD_FILE)

# Prints a seperator in red (-e option enables SYNTHsing escape sequences)
echo_sep:
	@echo -e "\n\e[1;33m======================================================================\e[0m\n"
echo_start_sim:
	@echo -e "\n\e[1;33m======================================================================\e[0m\n"
	@echo -e "\e[1;33mStarting Simulation          \e[0m\n"
	@echo -e "\e[1;33m======================================================================\e[0m\n"

#------------------------------------------------------------------------------
# COMPILE
#------------------------------------------------------------------------------
fpga_core : $(RTL_DIR)/fpga_core.v
	$(vlog) -work $(LIB) $(VLOG_FLAGS) \
		$(RTL_DIR)/fpga_core.v\
		$(RTL_DIR2)/rmii_mii_converter.sv\
		$(LIBRTL)/rtl/eth_mac_mii_fifo.v\
		$(LIBRTL)/rtl/eth_mac_mii.v\
		$(LIBRTL)/rtl/ssio_sdr_in.v\
		$(LIBRTL)/rtl/mii_phy_if.v\
		$(LIBRTL)/rtl/eth_mac_1g.v\
		$(LIBRTL)/rtl/axis_gmii_rx.v\
		$(LIBRTL)/rtl/axis_gmii_tx.v\
		$(LIBRTL)/rtl/lfsr.v\
		$(LIBRTL)/rtl/eth_axis_rx.v\
		$(LIBRTL)/rtl/eth_axis_tx.v\
		$(LIBRTL)/rtl/udp_complete.v\
		$(LIBRTL)/rtl/udp_checksum_gen.v\
		$(LIBRTL)/rtl/udp.v\
		$(LIBRTL)/rtl/udp_ip_rx.v\
		$(LIBRTL)/rtl/udp_ip_tx.v\
		$(LIBRTL)/rtl/ip_complete.v\
		$(LIBRTL)/rtl/ip.v\
		$(LIBRTL)/rtl/ip_eth_rx.v\
		$(LIBRTL)/rtl/ip_eth_tx.v\
		$(LIBRTL)/rtl/ip_arb_mux.v\
		$(LIBRTL)/rtl/arp.v\
		$(LIBRTL)/rtl/arp_cache.v\
		$(LIBRTL)/rtl/arp_eth_rx.v\
		$(LIBRTL)/rtl/arp_eth_tx.v\
		$(LIBRTL)/rtl/eth_arb_mux.v\
		$(LIBRTL)/lib/axis/rtl/arbiter.v\
		$(LIBRTL)/lib/axis/rtl/priority_encoder.v\
		$(LIBRTL)/lib/axis/rtl/axis_fifo.v\
		$(LIBRTL)/lib/axis/rtl/axis_async_fifo.v\
		$(LIBRTL)/lib/axis/rtl/axis_async_fifo_adapter.v
	
##############################################################################################
# Simulations
##############################################################################################

simulate: clean fpga_core
	set -o pipefail; MODULE=test_fpga_core \
	TOPLEVEL=fpga_core \
	TOPLEVEL_LANG=verilog \
	GPI_EXTRA=$(GPI_EXTRA) \
	COCOTB_RESULTS_FILE=$(OUTPUT_DIR)/cocotb_results.xml \
	$(vsim) $(VSIM_FLAGS) $(LIB).fpga_core -do $(DO_FLAG) -foreign \"cocotb_init $(FLI_LIB)\" -t 1ps


