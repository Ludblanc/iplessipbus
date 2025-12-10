---------------------------------------------------------------------------------
--
--   Copyright 2017 - Rutherford Appleton Laboratory and University of Bristol
--
--   Licensed under the Apache License, Version 2.0 (the "License");
--   you may not use this file except in compliance with the License.
--   You may obtain a copy of the License at
--
--       http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--
--                                     - - -
--
--   Additional information about ipbus-firmare and the list of ipbus-firmware
--   contacts are available at
--
--       https://ipbus.web.cern.ch/ipbus
--
---------------------------------------------------------------------------------


-- Top-level design for ipbus demo
--
-- This version is for VC707 eval board
--
-- You must edit this file to set the IP and MAC addresses
--


library IEEE;
use IEEE.STD_LOGIC_1164.all;
Library UNISIM;
use UNISIM.vcomponents.bufg;

use work.ipbus.all;

entity top is generic (
	ENABLE_DHCP  : std_logic := '0'; -- Default is build with support for RARP rather than DHCP
	USE_IPAM     : std_logic := '0'; -- Default is no, use static IP address as specified by ip_addr below
	MAC_ADDRESS  : std_logic_vector(47 downto 0) := X"0060d7c0ffee"-- Careful here, arbitrary addresses do not always work
	);
	port (
    sysclk_p     : in  std_logic;
    sysclk_n     : in  std_logic;
    leds         : out std_logic_vector(3 downto 0);  -- status LEDs
    dip_sw       : in  std_logic_vector(3 downto 0);  -- switches
    rgmii_gtx_clk: out std_logic;
    rgmii_tx_ctl : out std_logic;
    rgmii_txd    : out std_logic_vector(3 downto 0);
    rgmii_rx_clk : in  std_logic;
    rgmii_rx_ctl : in  std_logic;
    rgmii_rxd    : in  std_logic_vector(3 downto 0);
    phy_rst      : out std_logic;
    rgmii_mdio_a : inout std_logic
    );

end top;

architecture rtl of top is

    signal clk_ipb, rst_ipb, clk_aux, rst_aux, nuke, soft_rst, phy_rst_e, userled : std_logic;
    signal mac_addr                                                               : std_logic_vector(47 downto 0);
    signal ip_addr                                                                : std_logic_vector(31 downto 0);
    signal ipb_out                                                                : ipb_wbus;
    signal ipb_in                                                                 : ipb_rbus;

begin

-- Infrastructure

    infra : entity work.vc707_rgmii_infra
		generic map(
			DHCP_not_RARP => ENABLE_DHCP
		)
        port map(
            sysclk_p     => sysclk_p,
            sysclk_n     => sysclk_n,
            clk_ipb_o    => clk_ipb,
            rst_ipb_o    => rst_ipb,
            rst_125_o    => phy_rst_e,
            clk_aux_o    => clk_aux,
            rst_aux_o    => rst_aux,
            nuke         => nuke,
            soft_rst     => soft_rst,
            leds         => leds(1 downto 0),
            rgmii_txc    => rgmii_gtx_clk,
            rgmii_txd    => rgmii_txd,
            rgmii_tx_ctl => rgmii_tx_ctl,
            rgmii_rxc    => rgmii_rx_clk,
            rgmii_rxd    => rgmii_rxd,
            rgmii_rx_ctl => rgmii_rx_ctl,
            mac_addr     => mac_addr,
            ip_addr      => ip_addr,
            ipam_select  => USE_IPAM,
            ipb_in       => ipb_in,
            ipb_out      => ipb_out
            );

    leds(3 downto 2) <= '0' & userled;
    --phy_rst          <= not phy_rst_e;
    phy_rst          <= phy_rst_e;

    mac_addr <= MAC_ADDRESS;
	ip_addr <= X"c0a80003"; -- 192.168.0.3

-- ipbus slaves live in the entity below, and can expose top-level ports
-- The ipbus fabric is instantiated within.

    payload : entity work.payload
        port map(
            ipb_clk  => clk_ipb,
            ipb_rst  => rst_ipb,
            ipb_in   => ipb_out,
            ipb_out  => ipb_in,
            clk      => clk_aux,
            rst      => rst_aux,
            nuke     => nuke,
            soft_rst => soft_rst,
            userled  => userled
            );

end rtl;
