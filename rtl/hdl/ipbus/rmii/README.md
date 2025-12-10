# IPbus - RMII

## Overview

This directory contains a complete IPbus implementation with RMII (Reduced Media-Independent Interface) support, integrating verilog-ethernet and example slave modules.

## Hardware

The implementation targets the [PYNQ-Z2](../../../../documentation/readme.md) development board with the [LAN8720 Ethernet physical layer chip](../../../../documentation/readme.md).

## RMII Converter

The RMII to MII converter is implemented in `rtl/rmii_mii_converter.sv` with a VHDL wrapper and top-level MAC MII merge module for seamless protocol translation.

## Additional Information

In the `rtl/vivado` directory, there is a top-level design for the PYNQ board, along with a demo infrastructure that works with the software example located at [`../../../../software_examples/`](../../../../software_examples/).

In the `rtl/simulation` directory, you will find the necessary files to run simulations.



## Project Structure

- **rmii_dep.list** - RTL file dependencies for Vivado synthesis projects
- **constraints/** - FPGA constraint files for board configuration
