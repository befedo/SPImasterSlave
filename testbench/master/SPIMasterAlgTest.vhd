--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:02:35 06/10/2013
-- Design Name:   
-- Module Name:   /home/bhaallord/xilinx/Mojo-Base/SPIMasterAlgTest.vhd
-- Project Name:  Mojo-Base
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: SPIMasterAlg
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY SPIMasterAlgTest IS
END SPIMasterAlgTest;
 
ARCHITECTURE behavior OF SPIMasterAlgTest IS 
	constant timeoutMax: time:= 5000 ns;
	type useCase1Array is array (5 downto 0) of std_logic_vector(7 downto 0);
	type useCase3Array1 is array (1 downto 0) of std_logic_vector(7 downto 0);
	type useCase3Array2 is array (2 downto 0) of std_logic_vector(7 downto 0);
 
	constant useCase1 : useCase1Array :=("01011100", "01010101", "11110101","10101010","00000000","11111111");
	constant useCase2 : useCase1Array :=("01011100", "01010101", "11110101","10101010","00000000","11111111");
    -- Component Declaration for the Unit Under Test (UUT)
 
	COMPONENT SPIMasterAlg
		generic(
			spiClkTime: time:= 100 ns
		);

		port(
			miso : IN  std_logic;
			mosi : OUT  std_logic;
			sck : OUT  std_logic;
			ss : OUT  std_logic;
			tx : IN  std_logic_vector(7 downto 0);
			rx : OUT  std_logic_vector(7 downto 0);
			enable : IN  std_logic;
			cpha : IN  std_logic;
			cpol : IN  std_logic;
			ready: out std_logic;
			ssByte: in std_logic
		);
	END COMPONENT;
    

   --Inputs
   signal miso : std_logic := '0';
   signal tx : std_logic_vector(7 downto 0) := (others => '0');
   signal enable : std_logic := '0';
   signal cpha : std_logic := '0';
   signal cpol : std_logic := '1';
   signal ready: std_logic;
   signal ssByte: std_logic:= '0';

 	--Outputs
   signal mosi : std_logic;
   signal sck : std_logic;
   signal ss : std_logic;
   signal rx : std_logic_vector(7 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
	signal timeoutReset: bit;
	signal txTmp: std_logic_vector(7 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: SPIMasterAlg generic map(
		spiClkTime=>500 ns
	)
	PORT MAP (
          miso => miso,
          mosi => mosi,
          sck => sck,
          ss => ss,
          tx => tx,
          rx => rx,
          enable => enable,
          cpha => cpha,
          cpol => cpol,
			 ready => ready,
			 ssByte => ssByte
        );

  
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- write config
		cpol<='0';
		cpha<='1';
		ssByte<='1';
		wait for 1000 ns;
		tx<="00000000";
		miso<='0';
		wait for 10 ns;
		enable<='1';
		
		wait until ready='0';
		
		report "Test Use Case 1 Polarity" severity note;
		assert sck='0' report  "Test Use Case 1 Polarity" severity failure;
		
		-- useCase 1
		for j in useCase1'length-1 downto 0 loop
			enable<='1';
			for i in 0 to 7 loop			
				wait until sck='1';
				miso<=useCase1(j)(7-i);			
				wait until sck='0';
				--Reset Timeout
				timeoutReset<='1';		
			end loop;
			
			wait until ready='1';
			enable<='0';
			timeoutReset<='0';	
			wait for 5 us;
			timeoutReset<='1';
			report "Test Use Case 1/Byte " & integer'image(useCase1'length-1-j) severity note;
			assert useCase1(j)=rx report "Use Case 1 Error bei Byte " & integer'image(useCase1'length-1-j) severity failure;
		end loop;
		-- timeout deaktiviren
		timeoutReset<='0';
		
		wait for 1000 ns;
		-- write new config
		cpol<='1';
		cpha<='0';
		ssByte<='0';
		miso<='0';
		wait for 10000 ns;
		enable<='1';
		
		-- timeout deaktiviren
		timeoutReset<='1';
		report "Test Use Case 2 Polarity" severity note;
		assert sck='1' report  "Test Use Case 2 Polarity" severity failure;
		
		-- useCase 1
		for j in useCase2'length-1 downto 0 loop
			tx<=useCase2(j);
			enable<='1';
			wait until ready='0';
			for i in 0 to 7 loop			
				wait until sck='0';
				txTmp(7-i)<=mosi;			
				wait until sck='1';
				--Reset Timeout
				timeoutReset<='1';		
			end loop;
			
			wait until ready='1';
			enable<='0';
			timeoutReset<='0';	
			wait for 5 us;
			timeoutReset<='1';	
			--gesendete Byte vergleichen
			report "Test Use Case 2/Byte " & integer'image(useCase2'length-1-j) severity note;
			assert tx=txTmp report "Use Case 2 Error bei Byte " & integer'image(useCase2'length-1-j) severity failure;
		end loop;
		
		-- useCase 2
		
      wait;
   end process;
	
	
	timeout:process
	begin
		if timeoutReset'last_active>timeoutMax and timeoutReset='1' then
			assert false report "Timeout Error "&time'image(timeoutReset'last_event) severity failure;
		end if;
		wait for timeoutMax/10;
	end process;
	

END;
