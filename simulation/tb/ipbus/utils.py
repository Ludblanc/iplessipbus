##  Author: Delphine Allimann
##  EPFL - TCL 2025

import fcntl
import os
import struct
import subprocess

from scapy.layers.l2 import Ether, ARP
from scapy.layers.inet import IP, UDP
from cocotbext.eth import GmiiFrame

import ipbus_pkt

def build_arp(mac_src="08:01:f0:d6:2c:74", mac_dst="00:60:d7:c0:ff:ee", 
              ip_src="192.168.2.1", ip_dst="192.168.2.3"):
    """
    Build an arp request

    Args:
        mac_src (string): mac address of the source (tb)
        mac_dst (string): mac address of the destination (dut)
        ip_src (string): ip address of the source (tb)
        ip_dst (string): ip destination of the destination (dut)
        
    Returns:
        Tuple:
            - arp_frame: GmiiFrame of the arp request
            - arp_pkt: Ethernet packet of the arp request
    """
    whohas = ARP(psrc=ip_src, pdst=ip_dst)
    eth = Ether(src=mac_src, dst=mac_dst)
    arp_pkt = eth / whohas
    arp_frame = GmiiFrame.from_payload(arp_pkt.build())
    return arp_frame, arp_pkt

def check_arp_response(req_pkt, rsp_pkt):
    """
    Check that the arp response match the arp request

    Args:
        req_pkt (scapy Packet): Ethernet packet of the arp request
        rsp_pkt (scapy Packet): Ethernet packet of the arp responsezen
    """
    assert rsp_pkt.dst == req_pkt.src
    assert rsp_pkt[ARP].psrc == req_pkt[ARP].pdst
    assert rsp_pkt[ARP].pdst == req_pkt[ARP].psrc
    return


def build_udp(mac_src="08:01:f0:d6:2c:74", mac_dst="00:60:d7:c0:ff:ee", 
              ip_src="192.168.2.1",ip_dst="192.168.2.3", 
              sport=53460, dport=50001, payload=[x % 256 for x in range(256)]):
    """
    Build an Ethernet frame, eth/ip/udp 

    Args:
        mac_src (string): mac address of the source (tb)
        mac_dst (string): mac address of the destination (dut)
        ip_src (string): ip address of the source (tb)
        ip_dst (string): ip destination of the destination (dut)
        sport (int): udp port of the source (tb)
        dport (int): udp port of the destination (dut)
        payload : payload (can be an ipbus packet)

    Returns:
        Tuple:
            - udp_frame : GmiiFrame of the encapsulated udp message
            - udp_eth_pkt : Ethernet packet of the encapsulated udp message
    """
    payload = bytes(payload)
    eth = Ether(src=mac_src, dst=mac_dst)
    ip = IP(src=ip_src, dst=ip_dst)
    udp = UDP(sport=sport, dport=dport)
    
    udp_eth_pkt = eth / ip / udp / payload
    udp_frame = GmiiFrame.from_payload(udp_eth_pkt.build())

    return udp_frame, udp_eth_pkt

def check_udp_response(req_pkt, res_pkt):
    """
    Check that eth, ip and udp header of the response match the request

    Args:
        req_pkt (scapy Packet): Ethernet packet of the request
        rsp_pkt (scapy Packet):Ethernet packet of the response
    """
    assert req_pkt[Ether].src == res_pkt[Ether].dst
    assert req_pkt[Ether].dst == res_pkt[Ether].src
    assert req_pkt[IP].src    == res_pkt[IP].dst
    assert req_pkt[IP].dst    == res_pkt[IP].src
    assert req_pkt[UDP].sport == res_pkt[UDP].dport
    assert req_pkt[UDP].dport == res_pkt[UDP].sport

    return

def build_ipbus_read_transaction(tb, id:int, nbr_words=2, addr:list=[0x00,0x10,0x00,0x00]):
    """
    Build an ipbus read transaction

    Args:
        tb (TB): used for logging (tb.log.info())
        id (int) : id of the ipbus transaction
        nbr_words (int): read size in words of 32bits
        addr (list[int], size 4): address of the target (32bits)

    Returns:
        rd_trans (IpbusTransaction):

    """
    rd_trans = ipbus_pkt.IpbusTransaction(tb, id)
    rd_trans.build_read(nbr_words, addr)
    return rd_trans

def build_ipbus_write_transaction(tb, id, nbr_words=2, addr:list[int]=[0x00,0x10,0x00,0x00],
                                   data:list[int]=[x for x in range(64)]):
    """
    Build an ipbus write transaction

    Args:
        tb (TB): used for logging (tb.log.info())
        id (int) : id of the ipbus transaction
        nbr_words (int): read size in words of 32bits
        addr (list[int], size 4): address of the target (32bits)
        data (list[int]): write data

    Returns:
        wr_trans (IpbusTransaction):

    """
    wr_trans = ipbus_pkt.IpbusTransaction(tb, id)
    wr_trans.build_write(nbr_words, addr, data)
    return wr_trans


def build_ipbus_frame(tb, trans:list, mac_src='08:01:f0:d6:2c:74', mac_dst='00:60:d7:c0:ff:ee', 
                      ip_src="192.168.2.1", ip_dst="192.168.2.3", sport=53460, dport=50001):
    """
    Build ipbus packet and frame
    
    Args:
        tb (TB): used for logging (tb.log.info())
        trans (list): list of the Ipbus transactions to send
        mac_src (string): mac address of the source (tb)
        mac_dst (string): mac address of the destination (dut)
        ip_src (string) : ip address of the source (tb)
        ip_dst (string) : ip destination of the destination (dut)
        sport (int) : udp port of the source (tb)
        dport (int) : udp port of the destination (dut)

    Returns:
        Tuple:
            - ipbus_frame (GmiiFrame): GmiiFrame of the encapsulated ipbus packet (eth/ip/udp/ipbus)
            - ipbus_eth_pkt (scapy Packet): Ethernet packet of the encapsulated ipbus packet
            - pkt (IpbusPkt): Ipbus packet itself
    """
    pkt = ipbus_pkt.IpbusPkt(tb)
    pkt.add_transactions(trans)
    # pkt.print_pkt() 
    ipbus_frame,ipbus_eth_pkt = build_udp(mac_src, mac_dst, ip_src, ip_dst, sport, dport, payload=pkt.get_pkt())
    return ipbus_frame, ipbus_eth_pkt, pkt

def construct_ipbus_pkt(tb,response_ipbus_frame):
    """
    Construct an ipbus packet from the received frame

    Args:
        tb (TB): used for logging (tb.log.info())
        response_ipbus_frame (response_frame[UDP].load)

    Returns:
        response_ipbus_pkt (TODO)response_frame[UDP].load
    """
    response_ipbus_pkt = ipbus_pkt.IpbusPkt(tb)
    response_ipbus_pkt.construct_pkt(response_ipbus_frame)
    return response_ipbus_pkt

# async def test_ipbus_class(tb):

#     some_test_data = [83,111,109,101,32,116,101,115,116,32,100,97,116,97,32,32]
#     some_other_test_data = [83,111,109,101,32,116,101,115,116,32,100,97,116,97,97,97]
#     test_data = [76,112,240,124]

#     # req_ipbus_pkt = ipbus_pkt.IpbusPkt(tb)         #create an empty ipbus packet
#     # wr = ipbus_pkt.IpbusTransaction(tb,id=1)       #create an empty ipbus transaction
#     # wr.build_write(nbr_words=4,data=some_test_data)#make it a write transaction
#     wr_test = build_ipbus_write_transaction(tb, id=0, nbr_words=1, data = test_data)
#     wr_trans = build_ipbus_write_transaction(tb, id=1, nbr_words=4, data=some_test_data)
#     # rd = ipbus_pkt.IpbusTransaction(tb,id=2)       #create an empty ipbus transaction
#     # rd.build_read(nbr_words=4)                     #make it a read transaction
#     rd_trans = build_ipbus_read_transaction(tb, id=2, nbr_words=4)
#     # rd.print_clean()
#     # req_ipbus_pkt.add_transactions([wr_trans,rd_trans])        #add these transactions in the packet 
    
#     frame_raw, req_frame, req_ipbus_pkt = build_ipbus_frame(tb, [wr_trans,rd_trans])

#     _, _, test_pkt = build_ipbus_frame(tb,[wr_test])
  
#     tb.log.info("test_pkt")
#     test_pkt.print_pkt()
    
#     tb.log.info("req_ipbus_pkt")
#     req_ipbus_pkt.print_pkt()
#     # frame_raw,req_frame = build_udp(payload=req_ipbus_pkt.get_pkt()) #make it an etheret frame

#     await tb.rmii_phy.rx.send(frame_raw)           #send the frame  

#     res_frame_raw = await tb.rmii_phy.tx.recv()    #receive rmii response frame
#     res_frame = Ether(bytes(res_frame_raw.get_payload())) #make it ethernet frame

#     check_udp_response(req_frame, res_frame) 

#     # tb.log.info("sent %s, received %s", request_frame[UDP].load, response_frame[UDP].load)

#     tb.log.info("Ipbus packet received")
#     res_ipbus_pkt = ipbus_pkt.IpbusPkt(tb)      
#     res_ipbus_pkt.construct_pkt(res_frame[UDP].load) #interpret the received ipbus packet
#     res_ipbus_pkt.print_pkt()

#     tb.log.info("Send read request that should generate an error")
#     wrong_addr_pkt = ipbus_pkt.IpbusPkt(tb)
#     req = ipbus_pkt.IpbusTransaction(tb,3)
#     req.build_read(addr=[0xff, 0xff, 0xff, 0xff])
#     wrong_addr_pkt.add_transactions([req])
#     wrong_addr_pkt.print_pkt()
#     raw, req_frame = build_udp(payload=wrong_addr_pkt.get_pkt())

#     await tb.rmii_phy.rx.send(raw)

#     response_raw = await tb.rmii_phy.tx.recv()
#     response_frame = Ether(bytes(response_raw.get_payload()))
#     check_udp_response(req_frame, response_frame)
#     res_ipbus_pkt = ipbus_pkt.IpbusPkt(tb)
#     res_ipbus_pkt.construct_pkt(response_frame[UDP].load)
#     res_ipbus_pkt.print_pkt()

#     return


    

