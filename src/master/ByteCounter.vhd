----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:30:05 06/04/2013 
-- Design Name: 
-- Module Name:    ByteCounter - Behavioral 
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

entity ByteCounter is
	port(
		enable: in std_logic;
		compareCapture: out std_logic;
		clk: in std_logic;
		reset: in std_logic
	);
end ByteCounter;

architecture Behavioral of ByteCounter is
component Counter
		generic(
			size: positive:= 5
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
		size: positive:= 5
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
	signal sigValue: std_logic_vector(4 downto 0);
	signal sigReset: std_logic;
	signal sigSck: std_logic:='0';
	--TODO remove me
	signal sigData: std_logic_vector(4 downto 0):=std_logic_vector(to_unsigned(8,5));
begin
	countInst: Counter port map (
		enable=>enable,
		reset=>reset,
		clk=>clk,
		count=>sigValue
	);
	compareInst: Compare port map (
		compareIn=>sigValue,
		dataIn=>sigData,
		clk=>clk,
		compareCapture=>compareCapture,
		wr=>'1'
	);
end Behavioral;

