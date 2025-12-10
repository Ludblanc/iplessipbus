
## Repository Structure
- **ipbus**: workspace for testing `ipbus` under different configuration using rmii everywhere.
- **verilog-ethernet**: Workspaces for testing `verilog-ethernet` under different configurations (MII, RMII, or RMII–MII converter only).
- **tb**: Cocotb testbenches and supporting Python files for MII/RMII converters, verilog-ethernet and IPbus.

### IPbus Notes
In `ipbus_pkt.py`, `IpbusPkt` implements IPbus packets. IPbus transactions are implemented in `IpbusTransaction` as described in the [IPbus protocol v2.0](https://ipbus.web.cern.ch/doc/user/html/_downloads/d251e03ea4badd71f62cffb24f110cfa/ipbus_protocol_v2_0.pdf).
