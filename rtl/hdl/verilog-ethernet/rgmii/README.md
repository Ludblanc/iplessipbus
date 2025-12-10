# Verilog-ethernet - RGMII

Test of verilog-ethernet alone. It decodes Ethernet/IP/UDP packets, and echoes them. 

It was implemented on the [VC707 Evaluation Board](../../../../documentation/ug885_VC707_Eval_Bd.pdf) with the [CN-0506 Ethernet physical chip](../../../../documentation/cn0506-2256336.pdf)

The file verilog-ethernet_rgmii_dep.list is the list of all necessary files to create a vivado project.

### Timing Constraints

RGMII works in DDR, i.e. data are transmitted on both rising and falling edges.

The timing constraints are defined in the constraint file to synchronize `tx_clk`and `tx_data`. In the diagram (below), the red lines represent the applied timing constraints. $t_{min}$ and $t_{max}$ are both positive value used to set the output delay. (very small)

![timing_image](../../../../report/images/timing_fpga.svg)