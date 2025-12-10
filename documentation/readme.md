# Project Documentation & Literature References

This document organizes and explains the external references used by the MAC + IPbus project as well as the datasheet of the different used FPGA boards. **PDF links are referenced from their original hosts**

---

## 1. Ethernet PHYs

* [**ADIN1300 – Robust, Industrial 10/100/1000 Mbps Ethernet PHY (PDF)**](https://www.analog.com/media/en/technical-documentation/data-sheets/adin1300.pdf)

  * Features: low latency, low power, 10/100/1000 operation, auto‑negotiation
  * Useful for: electrical/timing specs, interface pinouts (MII/GMII/RGMII), configuration
  * Used for our first tests with RGMII

* [**Analog Devices CN0506 — ADIN1300 Reference Design (PDF)**](https://www.analog.com/media/en/reference-design-documentation/reference-designs/cn0506.pdf)

  * Reference design, schematics, PCB/layout notes, PHY setup examples

* [**LAN8720A PHY — Datasheet (PDF)**](https://www.waveshare.com/w/upload/1/1a/LAN8720A.pdf)

  * Single‑chip Ethernet PHY with RMII support; register map and electrical requirements

* [**LAN8720 — Waveshare Board Schematic (PDF)**](https://www.waveshare.com/w/upload/0/08/LAN8720-ETH-Board-Schematic.pdf)

  * Example board that is used for our tests with rmii

## 2. MII / GMII / RMII Protocols (Interface Specifications)

* [**RMII Specification (rev 1.0) — archived copy (PDF)**](http://ebook.pldworld.com/_eBook/-Telecommunications,Networks-/TCPIP/RMII/rmii_rev10.pdf)

  * Historical reference for RMII timing, signal definitions and clocking. *Do not redistribute — link only.*

* [**IEEE paper: Ethernet PHY Interfaces — sections on MII & GMII (PDF)**](https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=9844436)

  * Section 2: MII overview; Section 3: GMII operation; covers timing/semantics useful when implementing MAC logic

> **Note:** RMII is specified by the RMII consortium; vendor datasheets often implement/describe RMII behavior. When in doubt, prefer manufacturer datasheets + consortium spec for timing.

## 3. IPBus (Control & Communication Protocol)

* [**IPBus Protocol Specification v2.0 (CERN) (PDF)**](https://ipbus.web.cern.ch/doc/user/html/_downloads/d251e03ea4badd71f62cffb24f110cfa/ipbus_protocol_v2_0.pdf)

  * Defines transport, transaction semantics, and register mapping useful for mapping your MAC/registers to remote control via Ethernet

## 4. Board & Platform Documentation

* [**PYNQ‑Z2 User Manual (PDF)**](https://dpoauwgwqsy2x.cloudfront.net/Download/pynqz2_user_manual_v1_0.pdf)

  * Board schematic, FPGA IO assignments, Ethernet subsystem connections — useful for integration and validation

* [**VC707 Evaluation Board User Guide (UG885) (PDF)**](https://docs.amd.com/v/u/en-US/ug885_VC707_Eval_Bd)

  * Info on FPGA IO, PHY connectors and typical MAC/PHY mappings for Xilinx/AMD boards

