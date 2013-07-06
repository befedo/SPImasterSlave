----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:43:43 06/02/2013 
-- Design Name: 
-- Module Name:    Register - Behavioral 
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

entity Reg is
	generic(
		size: positive:= 8
	);
	port(
		wr: in std_logic;
		clk: in std_logic;
		reset: in std_logic;
		dataIn: in std_logic_vector(size-1 downto 0);
		currentValue: out std_logic_vector(size-1 downto 0);
		dataChange: out std_logic
	);
end Reg;

architecture Behavioral of Reg is
	signal sigValue: std_logic_vector(size-1 downto 0);
begin
	process(clk,reset)
	begin
		if reset ='1' then 
			sigValue<=(others=>'0');
		elsif clk'event and clk='1' then
			if wr='1' then
				sigValue<=dataIn;
				dataChange<='1';
			else
				dataChange<='0';
			end if;
			
		end if;
	end process;
	
	currentValue<= sigValue;
end Behavioral;

