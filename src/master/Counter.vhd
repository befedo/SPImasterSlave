----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:44:20 06/01/2013 
-- Design Name: 
-- Module Name:    Counter - Behavioral 
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

entity Counter is
	generic(
		size: positive:= 16
	);
	port(
		enable: in std_logic;
		reset: in std_logic;
		clk: in std_logic;
		count: out std_logic_vector(size-1 downto 0)
	);
end Counter;

architecture Behavioral of Counter is
	signal sigCount: std_logic_vector(size-1 downto 0):=(others=>'0');
	
begin
	process(clk,reset)
	begin
		if reset='1' then
			sigCount<=(others=>'0');
		elsif clk'event and clk='1' then
			if enable='1' then
				sigCount<=std_logic_vector(unsigned(sigCount)+1);
			end if;
		end if;
	end process;
	
	count<=sigCount;

end Behavioral;

