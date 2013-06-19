----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:39:51 06/04/2013 
-- Design Name: 
-- Module Name:    SPIClk - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPISck is
	port(
		spiClkOut: out std_logic;
		spiClkVisible: in std_logic;
		spiClkReset: in std_logic;
		spiClkEnable: in std_logic;
		clk: in std_logic;
		cpol: in std_logic;
		sck: out std_logic;
		sigData:  in std_logic_vector(15 downto 0)
	);
end SPISck;

architecture Behavioral of SPISck is
	component Counter
		generic(
			size: positive:= 16
		);
		port(
			enable: in std_logic;
			reset: in std_logic;
			clk: in std_logic;
			count: out std_logic_vector(size-1 downto 0)
		);
	end component;
	
	component Compare
	generic(
		size: positive:= 16
	);
	port(
		compareIn: in std_logic_vector(size-1 downto 0);
		dataIn: in std_logic_vector(size-1 downto 0);
		clk: in std_logic;
		compareCapture: out std_logic;
		wr: in std_logic
	);
	end component;
	
	--Signale
	signal sigValue: std_logic_vector(15 downto 0);
	signal sigReset: std_logic;
	signal sigResetFinal: std_logic;
	signal sigSck: std_logic:='0';
	
begin
   countInst: Counter port map (
		enable=>spiClkEnable,
		reset=>sigResetFinal,
		clk=>clk,
		count=>sigValue
	);
	compareInst: Compare port map (
		compareIn=>sigValue,
		dataIn=>sigData,
		clk=>clk,
		compareCapture=>sigReset,
		wr=>'1'
	);

	process(sigReset)
	begin
		if sigReset'event and sigReset='1' then
			sigSck<= not sigSck;
		end if;
	end process;
	
	sigResetFinal<= sigReset or spiClkReset;
	sck<= (spiClkVisible and sigSck) xor cpol;
	spiClkOut<=sigSck;
end Behavioral;

