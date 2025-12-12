"""
# Copyright (c) 2025 Ludovic Damien Blanc
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# Ethernet constraints

##  Author: Delphine Allimann, maintained by Ludovic Damien Blanc

"""



"""
adapted from verilog-ethernet of Alex Forencich with the follwing license:

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

"""



import logging
import os

import fcntl
import struct
import subprocess

from scapy.layers.l2 import Ether, ARP
from scapy.layers.inet import IP, UDP

import cocotb_test.simulator

import cocotb
from cocotb.log import SimLog
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

from cocotbext.eth import GmiiFrame

from rmii_ipbus import RmiiPhy

from utils import *


class TB:
    def __init__(self, dut, speed=100e6):
        self.dut = dut

        self.log = SimLog("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk_125_i, 8, units="ns").start())
        cocotb.start_soon(Clock(dut.clk_200_i, 5, units="ns").start())
        cocotb.start_soon(Clock(dut.clk_32_i, 32, units="ns").start())

        self.rmii_phy = RmiiPhy(dut.rmii_txd, dut.rmii_tx_en, dut.rmii_rxd, dut.rmii_rx_er, 
            dut.rmii_crs_dv, dut.rmii_ref_clk, speed=speed)

        dut.rmii_txd.setimmediatevalue(0)
        dut.rmii_tx_en.setimmediatevalue(0)
        dut.rgmii_mdio_a.setimmediatevalue(0)
        dut.dip_sw.setimmediatevalue(0)

        # dut.mac_addr.setimmediatevalue(0x0060d7c0ffe)
        # dut.ip_addr.setimmediatevalue(0xc0a80003)


    async def init(self):

        self.dut.rst_i.setimmediatevalue(0)

        for k in range(10):
            await RisingEdge(self.dut.clk_125_i)

        self.dut.rst_i.value = 1

        for k in range(10):
            await RisingEdge(self.dut.clk_125_i)

        self.dut.rst_i.value = 0


@cocotb.test()
async def run_test(dut):

    tb = TB(dut)

    await tb.init()

    ip_addr_dut = "192.168.2.3"
    mac_addr_dut = "00:60:d7:c0:ff:ee"

    ip_addr_tb = "192.168.2.1"
    mac_addr_tb = "08:01:f0:d6:2c:74"

    # send arp request
    tb.log.info("send ARP request")
    arp_req_frame, arp_req_pkt = build_arp()
    await tb.rmii_phy.rx.send(arp_req_frame)

    # receive arp response
    tb.log.info("receive ARP response")
    rx_frame = await tb.rmii_phy.tx.recv()
    rx_pkt = Ether(bytes(rx_frame.get_payload()))
    check_arp_response(arp_req_pkt, rx_pkt)

    # tb.log.info("RX packet: %s", repr(rx_pkt))


    # await test_ipbus_class(tb)

    #check features of ipbus class
    tb.log.info("check features of ipbus class outside of fct")

    some_test_data = [83,111,109,101,32,116,101,115,116,32,100,97,116,97,32,32]

    ### Send ipbus request, one read and one write
    write_transaction = build_ipbus_write_transaction(tb,id=0,nbr_words=4,data=some_test_data)
    read_transaction = build_ipbus_read_transaction(tb, id=1,nbr_words=4)
    request_frame, request_pkt, request_ipbus_pkt = build_ipbus_frame(tb,[write_transaction, read_transaction])
    tb.log.info("send request ipbus packet")
    request_ipbus_pkt.print_pkt()
    await tb.rmii_phy.rx.send(request_frame)

    ### Receive ipbus response
    response_frame = await tb.rmii_phy.tx.recv()
    response_pkt = Ether(bytes(response_frame.get_payload()))
    check_udp_response(request_pkt, response_pkt)
    tb.log.info("Ipbus packet received")

    response_ipbus_pkt = construct_ipbus_pkt(tb,response_pkt[UDP].load)
    # response_ipbus_pkt = construct_ipbus_pt

    response_ipbus_pkt.print_pkt()
    #TODO check ipbus packet (each transaction)

    ### Send ipbus request, one read with wrong address
    tb.log.info("Send read request that should generate an error")
    wrong_addr_trans = build_ipbus_read_transaction(tb, id=2, addr=[0xff,0xff,0xff,0xff])
    request_frame, request_pkt, request_ipbus_pkt = build_ipbus_frame(tb,[wrong_addr_trans])
    tb.log.info("send request ipbus packet")
    request_ipbus_pkt.print_pkt()
    await tb.rmii_phy.rx.send(request_frame)

    ### Receive ipbus response
    response_frame = await tb.rmii_phy.tx.recv()
    response_pkt = Ether(bytes(response_frame.get_payload()))
    check_udp_response(request_pkt, response_pkt)
    tb.log.info("Ipbus packet received")
    response_ipbus_pkt = ipbus_pkt.IpbusPkt(tb) #put this in construct_pkt fct
    response_ipbus_pkt.construct_pkt(response_pkt[UDP].load)
    response_ipbus_pkt.print_pkt()
    

    await RisingEdge(dut.clk_125_i)
    await RisingEdge(dut.clk_125_i)

    