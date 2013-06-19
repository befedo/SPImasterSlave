----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:44:02 06/10/2013 
-- Design Name: 
-- Module Name:    SPIMasterAlg - Behavioral 
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

entity SPIMasterAlg is
	generic(
		spiClkTime: time:= 100 ns;
		spiTimeout: time:= 1 ns
	);
	port(
	-- Hardware Pin
		miso: in std_logic;
		mosi: out std_logic;
		sck: out std_logic;
		ss: out std_logic;
	
	-- Datenspeicher
		tx: in std_logic_vector(7 downto 0);
		rx: out std_logic_vector(7 downto 0);
	-- Pin
		enable: in std_logic;
		cpha: in std_logic;
		cpol: in std_logic;
		ready: out std_logic;
		ssByte: in std_logic
	);
end SPIMasterAlg;

architecture Behavioral of SPIMasterAlg is

begin
	process
	begin
		if enable='0' then
			mosi<='0';
			sck<=cpol;
			ss<='1';
			ready<='1';
			wait for spiTimeout;
		elsif enable='1' then
			ss<='0';
			ready<='0';

			if cpha='1' then
				for i in 0 to 7 loop
					wait for spiClkTime;
					mosi<=tx(7-i);
					sck<= not cpol;
					wait for spiClkTime;
					rx(7-i)<=miso;
					sck<= cpol;
				end loop;
				wait for spiClkTime;
			else
				for i in 0 to 7 loop
					mosi<=tx(7-i);					
					wait for spiClkTime;
					sck<= not cpol;
					rx(7-i)<=miso;
					wait for spiClkTime;
					sck<= cpol;
				end loop;
				wait for spiClkTime;
			end if;
			ready<='1';
			if ssByte='1' then
				ss<='1';
			end if;
		end if;
		wait for spiClkTime;
	end process;

end Behavioral;

