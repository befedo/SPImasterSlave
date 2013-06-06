----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:43:24 06/01/2013 
-- Design Name: 
-- Module Name:    Shift - Behavioral 
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

entity Shift is
	generic(
		size: positive:=8
	);
	port(
		reset: in std_logic;
		load: in std_logic;
		clk: in std_logic;
		loadValue: in std_logic_vector(size-1 downto 0);
		dataOut: out std_logic;
		dataIn: in std_logic;
		currentValue: out std_logic_vector(size-1 downto 0);
		outEnable: in std_logic;
		inEnable: in std_logic
	);
end Shift;

architecture Behavioral of Shift is
	signal sigValue: std_logic_vector(size-1 downto 0);
	signal sigDataOut: std_logic;
begin
	
	process(clk,reset,load)
	begin 
		if reset='1' then
			sigValue<=(others=>'0');
			sigDataOut<='0';
		elsif load='1' then
			sigValue<=loadValue;
		elsif clk'event and clk='1' then
		 if outEnable='1' then
			sigDataOut<=sigValue(size-1);
			sigValue(size-1 downto 1)<=sigValue(size-2 downto 0);
	    end if;
		 if inEnable='1' then
			sigValue(0)<=dataIn;
			end if;
		end if;
	end process;
	
	dataOut<=sigDataOut;
	currentValue<=sigValue;


end Behavioral;

