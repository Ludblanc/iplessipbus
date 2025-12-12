-- Copyright (c) 2025 Ludovic Damien Blanc
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


-- Author: Delphine Allimann, maintained by Ludovic Damien Blanc

--- rmii_mii_converter wrapper
-- EPFL - TCL 2025

library ieee;
use ieee.std_logic_1164.all;

entity converter_wrapper is 
    port(
        rst : in std_logic;

        --MII interface    
        mii_rx_clk : out std_logic;
        mii_rxd    : out std_logic_vector(3 downto 0);
        mii_rx_dv  : out std_logic;
        mii_rx_er  : out std_logic;
        mii_tx_clk : out std_logic;
        mii_txd    : in  std_logic_vector(3 downto 0);
        mii_tx_en  : in  std_logic;
        mii_tx_er  : in  std_logic;

        --RMII interface    
        rmii_rxd     : in  std_logic_vector(1 downto 0);
        rmii_rx_er   : in  std_logic;
        rmii_crs_dv  : in  std_logic;
        rmii_txd     : out std_logic_vector(1 downto 0);
        rmii_tx_en   : out std_logic;
        rmii_ref_clk : in  std_logic
    );
end converter_wrapper;

architecture rtl of converter_wrapper is 

    component rmii_mii_converter
        generic (TARGET : string);
        port (
            rst : in std_logic;

            --MII interface    
            mii_rx_clk : out std_logic;
            mii_rxd    : out std_logic_vector(3 downto 0);
            mii_rx_dv  : out std_logic;
            mii_rx_er  : out std_logic;
            mii_tx_clk : out std_logic;
            mii_txd    : in  std_logic_vector(3 downto 0);
            mii_tx_en  : in  std_logic;
            mii_tx_er  : in  std_logic;

            --RMII interface    
            rmii_rxd     : in  std_logic_vector(1 downto 0);
            rmii_rx_er   : in  std_logic;
            rmii_crs_dv  : in  std_logic;
            rmii_txd     : out std_logic_vector(1 downto 0);
            rmii_tx_en   : out std_logic;
            rmii_ref_clk : in  std_logic
        );
    end component;

begin 

    rmii_mii_converter_inst : rmii_mii_converter
    generic map(
        TARGET => "GENERIC"
    )
    port map(
        rst => rst,

        mii_rx_clk => mii_rx_clk,
        mii_rxd    => mii_rxd,
        mii_rx_dv  => mii_rx_dv,
        mii_rx_er  => mii_rx_er, 
        mii_tx_clk => mii_tx_clk, 
        mii_txd    => mii_txd, 
        mii_tx_en  => mii_tx_en,
        mii_tx_er  => mii_tx_er, 

        rmii_rxd    => rmii_rxd, 
        rmii_rx_er  => rmii_rx_er, 
        rmii_crs_dv => rmii_crs_dv,
        rmii_txd    => rmii_txd,
        rmii_tx_en  => rmii_tx_en,

        rmii_ref_clk => rmii_ref_clk
    );

end rtl;