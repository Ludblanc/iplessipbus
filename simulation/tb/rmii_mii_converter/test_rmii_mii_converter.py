"""

Copyright (c) 2020 Alex Forencich

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

from scapy.layers.l2 import Ether, ARP
from scapy.layers.inet import IP, UDP

import cocotb_test.simulator

import cocotb
from cocotb.log import SimLog
from cocotb.clock import Clock

from cocotb.triggers import RisingEdge, Timer

from cocotbext.eth import GmiiFrame#, MiiPhy

from rmii import RmiiPhy
from mii import MiiPhy

class TB:
    def __init__(self, dut, speed=100e6):
        self.dut = dut

        self.log = SimLog("cocotb.tb")
        self.log.setLevel(logging.DEBUG)
        
        self.dut.rmii_ref_clk.setimmediatevalue(0)

        # tx and rx are inverted
        self.mii_phy = MiiPhy(dut.mii_rxd, None, dut.mii_rx_dv, dut.mii_rx_clk, 
            dut.mii_txd, dut.mii_tx_er, dut.mii_tx_en, dut.mii_rx_clk, speed=speed)

        self.rmii_phy = RmiiPhy(dut.rmii_txd, dut.rmii_tx_en, dut.rmii_rxd, dut.rmii_rx_er,
            dut.rmii_crs_dv, dut.rmii_ref_clk)

    async def init(self):

        self.dut.rst.setimmediatevalue(0)

        await Timer(10, units='ns')

        self.dut.rst.value = 1

        await Timer(10, units='ns')

        self.dut.rst.value = 0

        cocotb.start_soon(Clock(self.dut.rmii_ref_clk, 20, units="ns").start())
        



@cocotb.test()
async def run_test(dut):

    tb = TB(dut)

    await tb.init()

    # await Timer(10, units='ns') #comment to be sync

    tb.log.info("test UDP RX packet")

    payload = bytes([x % 256 for x in range(256)])
    eth = Ether(src='5a:51:52:53:54:55', dst='00:60:d7:c0:ff:ee')
    ip = IP(src='192.168.0.1', dst='192.168.0.3')
    udp = UDP(sport=5678, dport=1234)
    test_pkt = eth / ip / udp / payload

    rmii_test_frame = GmiiFrame.from_payload(test_pkt.build())
    mii_test_frame  = GmiiFrame.from_payload(test_pkt.build())

    tb.log.info("Send RMII frame")

    await tb.rmii_phy.rx.send(rmii_test_frame) # send rmii frame     

    tb.log.info("finish to send")

    # await Timer(40, units='us')

    tb.log.info("Recive MII frame")
    mii_rx_frame = await tb.mii_phy.tx.recv() # receive mii

    rx_pkt = Ether(bytes(mii_rx_frame.get_payload()))

    tb.log.info("RX packet: %s", repr(rx_pkt))

    assert mii_rx_frame == rmii_test_frame

    tb.log.info("Frame are the same")


    tb.log.info("Send MII frame")

    await tb.mii_phy.rx.send(mii_test_frame)   # send  mii frame          

    tb.log.info("finish to send")

    # await Timer(40, units='us')

    tb.log.info("Receive RMII frame")
    rmii_rx_frame = await tb.rmii_phy.tx.recv() # receive rmii

    rx_pkt = Ether(bytes(rmii_rx_frame.get_payload()))

    tb.log.info("RX packet: %s", repr(rx_pkt))

    assert rmii_rx_frame == mii_test_frame

    tb.log.info("Frame are the same")

    await RisingEdge(dut.rmii_ref_clk)
    await RisingEdge(dut.rmii_ref_clk)


# cocotb-test

tests_dir = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))
lib_dir = os.path.abspath(os.path.join(rtl_dir, '..', 'lib'))
axis_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'eth', 'lib', 'axis', 'rtl'))
eth_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'eth', 'rtl'))


def test_rmii_mii_converter(request):
    dut = "rmii_mii_converter"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),

    ]

    parameters = {}

    # parameters['A'] = val

    extra_env = {f'PARAM_{k}': str(v) for k, v in parameters.items()}

    sim_build = os.path.join(tests_dir, "sim_build",
        request.node.name.replace('[', '-').replace(']', ''))

    cocotb_test.simulator.run(
        python_search=[tests_dir],
        verilog_sources=verilog_sources,
        toplevel=toplevel,
        module=module,
        parameters=parameters,
        sim_build=sim_build,
        extra_env=extra_env,
    )
