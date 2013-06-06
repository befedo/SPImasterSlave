----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:40:05 06/04/2013 
-- Design Name: 
-- Module Name:    Compare - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Compare is
	generic(
		size: positive:= 8
	);
	port(
		compareIn: in std_logic_vector(size-1 downto 0);
		dataIn: in std_logic_vector(size-1 downto 0);
		clk: in std_logic;
		compareCapture: out std_logic;
		wr: in std_logic
	);
end Compare;

architecture Behavioral of Compare is
	signal sigValue: std_logic_vector(size-1 downto 0);
begin
	process(clk,wr)
	begin
		if clk'event and clk='1' then
			if wr='1' then
				sigValue<=dataIn;
			end if;
			if compareIn=sigValue then
				compareCapture<='1';
			else
				compareCapture<='0';
			end if;
		end if;
	end process;

	
end Behavioral;

