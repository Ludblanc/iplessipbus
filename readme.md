## Setup

Initialize submodules:

```bash
git submodule init
git submodule update
```

Or in one step:

```bash
git clone  git@github.com:Ludblanc/iplessipbus.git --recursive          
```

Python and cocotb dependencies (except IPbus software) use Conda. See `environment.yml`.
```bash
conda env create -f environment.yml
```

IPbus software environment is provided via Apptainer (see the [`apptainer`](apptainer) directory).

Useful datasheets and standards are in [`documentation/`](documentation).

- Timing constraints for our RMII PHY: [`rtl/hdl/ipbus/rmii/constraint`](rtl/hdl/ipbus/rmii/constraint)  
- And for RGMII : [`rtl/hdl/ipbus/rgmii/constraints`](rtl/hdl/ipbus/rgmii/constraints)
## Simulation

- Top-level IPbus simulation with RMII/MII converter and Verilog Ethernet PHY: [`simulation/ipbus/simulation_ipbus`](simulation/ipbus/simulation_ipbus)  
- RMII/MII converter simulations: [`simulation/verilog-ethernet`](simulation/verilog-ethernet)
- cocotb custom library and testbenches: [`simulation/tb`](simulation/tb)

This design has been validated on multiple FPGA projects (e.g., a reverse-engineered RP2040 PIO) and is intended for tape-out in a future TCL EPFL ASIC as a link to memory-mapped accelerators.

## Project description

For ASICs or FPGA projects, we need reliable external communication (status, register/memory programming, etc.). Historically at TCL, communication relied on a custom chip interface: slow, custom protocol, extra FPGA, limited documentation, and no robust software.

[IPbus](https://ipbus.web.cern.ch/) provides a hardware UDP stack (no CPU) plus software for memory read/write with packet-loss handling over standard Ethernet. The original MAC used Xilinx IP; here it is replaced by [Verilog-Ethernet](https://github.com/alexforencich/verilog-ethernet).



## Implementation

Below is the block diagram:

![block_diagram](documentation/figures/ipbus_block_diagram_dev_conv.svg)

Ethernet PHY ⇔ MAC interface options:

| MII    | RMII   | GMII   | RGMII  |
|:-------|:-------|:-------|:-------|
| 13 I/Os| 8 I/Os | 22 I/Os| 12 I/Os|
| 25 MHz | 50 MHz | 125 MHz| 125 MHz|
| 100 Mbps | 100 Mbps | 1 Gbps | 1 Gbps |

This project focuses on RMII (fewer I/Os). Since Verilog-Ethernet lacks RMII, an RMII→MII converter was designed.

## Attach a payload to the bus

1. Write `address_table.xml` describing the payload memory map.
2. Run `gen_ipbus_addr_decode.py` to generate `address_decoder.vhd` and add it to the RTL.
3. Access memory-mapped resources in Python using the address table.

More details:
- [IPbus software guide](https://ipbus.web.cern.ch/doc/user/html/software/uhalQuickTutorial.html) (examples in `software_examples`)
- Firmware integration: [bus interface](https://ipbus.web.cern.ch/doc/user/html/firmware/bus.html)
- Clock domain crossing: [ipbus_clk_bridge](https://github.com/ipbus/ipbus-firmware/blob/master/components/ipbus_util/firmware/hdl/ipbus_clk_bridge.vhd)

## Synthesis (Design Compiler, 65nm)

Without payload:

| Total area | Total memory area | Total logic area |
|:----------:|:-----------------:|:----------------:|
| 610'788    | 562'095           | 48'953           |

Area is dominated by packet buffers; reducing buffer sizes saves area but increases packet loss under heavy traffic. Software handles packet loss, so reliability is preserved, though throughput may decrease.

## References 📚

- [IPbus main page](https://ipbus.web.cern.ch/) and [GitHub](https://github.com/ipbus/ipbus-firmware)
- [Verilog-Ethernet](https://github.com/alexforencich/verilog-ethernet) → deprecated, see [taxi](https://github.com/fpganinja/taxi)

## Copyright
Originally a semester project by Delphine Allimann at the Telecommunications Circuits Laboratory (TCL), EPFL, Lausanne, Switzerland. Currently maintained by Ludovic Blanc, PhD student at TCL.
