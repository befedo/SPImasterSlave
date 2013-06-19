----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:06:53 06/02/2013 
-- Design Name: 
-- Module Name:    SPIFsm - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPIFsm is
	port(
		--CLK
		clk: in std_logic;
		
		--Byte Zähler
		countCompare: in std_logic;
		countUp: out std_logic;
		countReset: out std_logic;
		
		--SPI
		spiClk: in std_logic;
		spiClkVisible: out std_logic;
		spiClkReset: out std_logic;
		spiClkEnable: out std_logic;
		
		--slave select
		ss: out std_logic;
		
		--Reg set
		rxWrite: out std_logic;
		txWrite: out std_logic;
		
		--Shift set
		bitWrite: out std_logic;
		bitRead: out std_logic;
		
		--Flags
		cpha: in std_logic;
		rxo: in std_logic;
		enable: in std_logic;
		ready: out std_logic;
		txEmpty: out std_logic;
		txSet: in std_logic;
		ssByte: in std_logic;
		
		-- Reset
		reset: out std_logic;
		shiftReset: out std_logic
		
	);
end SPIFsm;

architecture Behavioral of SPIFsm is
	type states is (s0,s1,s2,s3,s4,s5,s6,s7,s8, s9, s10, s11); 
	signal state : states:= s0;
begin
	process(clk)
	begin
		if clk'event and clk='1' then
			case state is 
				when s0=>
					state<=s1;
				when s1 => 
					if enable='1' and rxo='0' then
						state<=s2;
					elsif enable='1' and rxo='1' then
						state<=s3;
					end if;
				when  s2 =>
					if txSet='1' then
						state<=s3;
					end if;
				when s3 =>
					if cpha='0' or (cpha='1' and spiClk='1') then
						state<=s4;
					end if;
				when s4 =>
					state<= s5;
				when s5=>
					if (cpha='0' and spiClk='1') or (cpha='1' and spiClk='0') then
						state<=s6;
					end if;
					
				when s6=>
					state<=s7;
				when s7 =>
					if countCompare='0' then
						if (cpha='1' and spiClk='1') or (cpha='0' and spiClk='0') then
							state<=s4;
						end if;
					else 
						if cpha='1' then
							state<=s8;
						elsif spiClk='0' then
							if ssByte='1' then
								state<=s9;
							else
								state<=s10;
							end if;
						end if;
					end if;
				when s8=>
					if spiClk='1' then
						if ssByte='1' then
							state<=s9;
						else
							state<=s10;
						end if;
					end if;
				when s9=>
					if (cpha='0' and spiClk='1') or (cpha='1' and spiClk='0') then
						state<=s10;
					end if;
				when s10=>
					state<=s11;
				when s11 =>
					if enable='0' then
						state<=s1;
					elsif rxo='1' then
						state<=s3;
					elsif rxo='0' then
						state<=s2;
					end if;
			end case;
		end if;
	end process;
	
	process(state)
	begin 
		case state is
			when s0=>
				reset<='1';
			when s1=>
				countUp<='0';
				spiClkVisible<='0';
				spiClkReset<='1';
				spiClkEnable<='0';
				rxWrite<='0';
				txWrite<='0';
				ready<='1';
				bitWrite<='0';
				bitRead<='0';
				shiftReset<='1';
				countReset<='1';
				reset<='0';
				ss<='1';
				txEmpty<='0';
			when s2=>
				shiftReset<='0';
				ready<='1';
				txWrite<='1';
				countReset<='0';
				txEmpty<='1';
			when s3 =>
				spiClkEnable<='1';
				spiClkVisible<='1';
				spiClkReset<='0';
				txWrite<='0';
				ready<='0';
				shiftReset<='0';
				countReset<='0';
				ss<='0';
				txEmpty<='0';
			when s4 =>
				countUp<='1';
				bitWrite<='1';
			when s5 => 
				countUp<='0';
				bitWrite<='0';
			when s6 =>
				bitRead<='1';
			when s7 =>
				bitRead<='0';
			when s8=>
				spiClkVisible<='0';
			when s9=>
				ss<='1';
				spiClkVisible<='0';
			when s10=>
				rxWrite<='1';
				spiClkReset<='1';
			when s11=>
				rxWrite<='0';
				ready<='1';
				spiClkEnable<='0';
				spiClkVisible<='0';
				spiClkReset<='0';
				countReset<='1';
				shiftReset<='1';
		end case;
	end process;

end Behavioral;

