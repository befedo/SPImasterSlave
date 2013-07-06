----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:41:57 06/01/2013 
-- Design Name: 
-- Module Name:    SPIMaster - Behavioral 
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

entity SPIMaster is
	port(
		--spi
		miso: in std_logic;
		mosi: out std_logic;
		sck: out std_logic;
		ss: out std_logic;
		
		--intern
		clk: in std_logic;
		ready: out std_logic;
		enable: in std_logic;
		tx: in std_logic_vector(7 downto 0);
		rx: out std_logic_vector(7 downto 0);
		txWr: in std_logic
	);
end SPIMaster;

architecture Behavioral of SPIMaster is
	component SPIFsm 
		port(
			clk: in std_logic;
			countCompare: in std_logic;
			countUp: out std_logic;
			countReset: out std_logic;
			spiClk: in std_logic;
			spiClkVisible: out std_logic;
			spiClkReset: out std_logic;
			spiClkEnable: out std_logic;
			ss: out std_logic;
			rxWrite: out std_logic;
			txWrite: out std_logic;
			bitWrite: out std_logic;
			bitRead: out std_logic;
			cpha: in std_logic;
			rxo: in std_logic;
			enable: in std_logic;
			ready: out std_logic;
			txSet: in std_logic;
			ssByte: in std_logic;
			reset: out std_logic;
			shiftReset: out std_logic
		);
	end component;

	component Reg 
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
	end component;
	
	component Shift is
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
	end component;

	component SPISck
		port(
			spiClkOut: out std_logic;
			spiClkVisible: in std_logic;
			spiClkReset: in std_logic;
			spiClkEnable: in std_logic;
			clk: in std_logic;
			cpol: in std_logic;
			sck: out std_logic
		);
	end component;
	
	component ByteCounter 
		port(
			enable: in std_logic;
			compareCapture: out std_logic;
			clk: in std_logic;
			reset: in std_logic
		);
	end component;
	
	--Signal
	signal countCompare: std_logic;
	signal countUp: std_logic;
	signal countReset: std_logic;
			
	signal spiClk: std_logic;
	signal spiClkVisible: std_logic;
	signal spiClkReset: std_logic;
	signal spiClkEnable: std_logic;
			
	signal rxWrite: std_logic;
	signal txWrite: std_logic;
			
	signal bitWrite: std_logic;
	signal bitRead: std_logic;
	
	--TODO dont fix
	signal cpha: std_logic:='1';
	signal rxo: std_logic:='0';
--	signal enable: std_logic:='1';
--	signal ready: std_logic;
	signal txSet: std_logic;
	signal ssByte: std_logic:='1';
	signal cpol: std_logic:='1';
		
	signal reset: std_logic;
	signal shiftReset: std_logic;
	
	--FIFO
	signal txValue: std_logic_vector(7 downto 0);
	signal rxValue: std_logic_vector(7 downto 0);
begin

	fsmInst: SPIFsm port map (
		clk=>clk,
		countCompare=>countCompare,
		countUp=>countUp,
		countReset=>countReset,
		spiClk=>spiClk,
		spiClkVisible=>spiClkVisible,
		spiClkReset=>spiClkReset,
		spiClkEnable=>spiClkEnable,
		ss=>ss,
		rxWrite=>rxWrite,
		txWrite=>txWrite,
		bitWrite=>bitWrite,
		bitRead=>bitRead,
		cpha=>cpha,
		rxo=>rxo,
		enable=>enable,
		ready=>ready,
		txSet=>txSet,
		ssByte=>ssByte,
		reset=>reset,
		shiftReset=>shiftReset
	);
	
	sckInst: SPISck port map (
		spiClkOut=>spiClk,
		spiClkVisible=>spiClkVisible,
		spiClkReset=>spiClkReset,
		spiClkEnable=>spiClkEnable,
		clk=>clk,
		cpol=>cpol,
		sck=>sck
	);
	
	byteCounterInst: ByteCounter port map (
		enable=>countUp,
		compareCapture=>countCompare,
		clk=>clk,
		reset=>countReset
	);

	
	txRegInst: Reg port map (
		wr => txWr,
		clk => clk,
		reset => reset,
		dataIn => tx,
		currentValue => txValue,
		dataChange=> txSet
	);

	rxRegInst: Reg port map(
		wr => rxWrite,
		clk => clk,
		reset => reset,
		dataIn => rxValue,
		currentValue => rx
	);
	
	shiftInst: Shift port map(
		reset => shiftReset,
		load => txWrite,
		clk => clk,
		loadValue => txValue,
		dataOut => mosi,
		dataIn => miso,
		currentValue => rxValue,
		outEnable => bitWrite,
		inEnable => bitRead
	);

end Behavioral;

