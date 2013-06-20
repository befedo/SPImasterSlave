
library ieee;
use ieee.std_logic_1164.all;

-- Leere Entity für die Testbench
entity SPIMasterAlgTest is 
end SPIMasterAlgTest;
 
architecture behavior of SPIMasterAlgTest is 
	-- Maximale Zeit ohne Aktion
	constant timeoutMax: time:= 5 us;
	constant spiTime: time:= 500 ns;
	
	-- Datentypen für die Test
	type useCaseArray1 is array (5 downto 0) of std_logic_vector(7 downto 0);
	type useCaseArray2 is array (1 downto 0) of std_logic_vector(7 downto 0);
	type useCaseArray3 is array (2 downto 0) of std_logic_vector(7 downto 0);
 
	-- Test Daten für UseCase 1
	constant useCase1 : useCaseArray1 :=("01011100", "01010101", "11110101","10101010","00000000","11111111");
	-- Test Daten für UseCase 2
	constant useCase2 : useCaseArray1 :=("01011100", "01010101", "11110101","10101010","00000000","11111111");
	-- Test Daten für UseCase 3
	constant useCase3Vec1: useCaseArray2 :=("01011100","01010101");
	constant useCase3Vec2: useCaseArray3 :=("11110000","11111111","00001111");
	-- Test Daten für UseCase 4
	constant useCase4Vec1: useCaseArray3 :=("01011100","00000000","11001100");
	constant useCase4Vec2: useCaseArray2 :=("01010101","11111111");
	-- Test Daten für UseCase 5
	constant useCase5Vec1Tx: useCaseArray3 :=("01011100","00000000","11001100");
	constant useCase5Vec2Tx: useCaseArray2 :=("01010101","11111111");
	constant useCase5Vec1Rx: useCaseArray3 :=("11100110","11001000","11111111");
	constant useCase5Vec2Rx: useCaseArray2 :=("01110101","11100100");

	
	
	-- DUT Komponenten Beschreibung
	component SPIMasterAlg
		generic(
			spiClkTime: time:= 100 ns
		);
		port(
			miso : in  std_logic;
			mosi : out  std_logic;
			sck : out  std_logic;
			ss : out  std_logic;
			tx : in  std_logic_vector(7 downto 0);
			rx : out  std_logic_vector(7 downto 0);
			enable : in  std_logic;
			cpha : in  std_logic;
			cpol : in  std_logic;
			ready: out std_logic;
			ssByte: in std_logic
		);
	end component;
    

   -- Eingangsdaten
   signal miso : std_logic := '0';
   signal tx : std_logic_vector(7 downto 0) := (others => '0');
   signal enable : std_logic := '0';
   signal cpha : std_logic := '0';
   signal cpol : std_logic := '1';
   signal ready: std_logic;
   signal ssByte: std_logic:= '0';

 	-- Ausgangsdaten
   signal mosi : std_logic;
   signal sck : std_logic;
   signal ss : std_logic;
   signal rx : std_logic_vector(7 downto 0);
	
	-- Interne Simulations Signale
	signal timeoutReset: bit;
	signal txTmp: std_logic_vector(7 downto 0);
 
begin
 
	-- Instanz des DUT anlegen
   dut: SPIMasterAlg generic map(
		spiClkTime=> spiTime
	) port map (
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

  
 

   -- Testbench
   testbench: process
   begin
		--------------------------------------------------------------------------------------------------------------------
		-- Einzelne Byte Lesen
		--------------------------------------------------------------------------------------------------------------------
      -- Configuration schreiben
		cpol<='0';
		cpha<='1';
		ssByte<='1';
		wait for 1000 ns;
		tx<="00000000";
		miso<='0';
		wait for 10 ns;
		
		report "Test Use Case 1 Polarity" severity note;
		assert sck='0' report  "Test Use Case 1 Polarity" severity failure;
		
		-- UseCase 1 starten
		for j in useCase1'length-1 downto 0 loop
			enable<='1';
			wait until ready='0';
			-- Slave Select Testen
			assert ss='0' report "Use Case 2 Error bei Byte " & integer'image(useCase2'length-1-j) & " Slave Select Error" severity failure;
			-- Transfer starten
			for i in 0 to 7 loop			
				wait until sck='1';
				miso<=useCase1(j)(7-i);			
				wait until sck='0';
				-- Timeout zurücksetzen
				timeoutReset<='1';		
			end loop;
			
			wait until ready='1';
			enable<='0';
			timeoutReset<='0';	
			wait for 5 us;
			timeoutReset<='1';
			--Byte überprüfen
			report "Test Use Case 1/Byte " & integer'image(useCase1'length-1-j) severity note;
			assert useCase1(j)=rx report "Use Case 1 Error bei Byte " & integer'image(useCase1'length-1-j) severity failure;
		end loop;
		-- timeout deaktivieren
		timeoutReset<='0';
		
		--------------------------------------------------------------------------------------------------------------------
		-- Einzelne Byte Schreiben
		--------------------------------------------------------------------------------------------------------------------
		wait for 1000 ns;
      -- Configuration schreiben
		cpol<='1';
		cpha<='0';
		ssByte<='0';
		miso<='0';
		wait for 10000 ns;
		enable<='1';
		
		-- timeout deaktivieren
		timeoutReset<='1';
		report "Test Use Case 2 Polarity" severity note;
		assert sck='1' report  "Test Use Case 2 Polarity" severity failure;
		
		-- UseCase 2 starten
		for j in useCase2'length-1 downto 0 loop
			tx<=useCase2(j);
			enable<='1';
			wait until ready='0';
			-- Slave Select Testen
			assert ss='0' report "Use Case 2 Error bei Byte " & integer'image(useCase2'length-1-j) & " Slave Select Error" severity failure;
			-- Transfer starten
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
			-- Slave Select Testen
			assert ss='1' report "Use Case 2 Error bei Byte " & integer'image(useCase2'length-1-j) & " Slave Select Error" severity failure;
		end loop;
		-- timeout deaktivieren
		timeoutReset<='0';
		
		--------------------------------------------------------------------------------------------------------------------
		-- Mahrere Bytes Lesen
		--------------------------------------------------------------------------------------------------------------------
		wait for 1000 ns;
      -- Configuration schreiben
		cpol<='0';
		cpha<='0';
		ssByte<='1';
		miso<='0';
		tx<="00000000";
		wait for 10000 ns;
		enable<='1';
		
		-- timeout deaktivieren
		timeoutReset<='1';
		report "Test Use Case 3 Polarity" severity note;
		assert sck='0' report  "Test Use Case 3 Polarity" severity failure;
		
		-- UseCase 3 Vector 1 starten
		for j in useCase3Vec1'length-1 downto 0 loop
			enable<='1';
			wait until ready='0';
			-- Slave Select Testen
			assert ss='0' report "Use Case 3 Error bei Byte " & integer'image(useCase3Vec1'length-1-j) & " Slave Select Error" severity failure;
			-- Transfer starten
			for i in 0 to 7 loop		
				miso<=useCase3Vec1(j)(7-i);		
				wait until sck='1';		
				wait until sck='0';
				--Reset Timeout
				timeoutReset<='1';		
			end loop;
			
			wait until ready='1';
			--gesendete Byte vergleichen
			report "Test Use Case 3/Byte " & integer'image(useCase3Vec1'length-1-j) severity note;
			assert useCase3Vec1(j)=rx report "Use Case 3 Error bei Byte " & integer'image(useCase3Vec1'length-1-j) severity failure;
		end loop;
		enable<='0';
		wait for 5 ns;
		-- Slave Select Testen
		assert ss='1' report "Use Case 3 Error Slave Select Error" severity failure;
		-- timeout deaktivieren
		timeoutReset<='0';
		
		-- nächster Testvector vorbereiten
		wait for 10000 ns;
		enable<='1';
		
		-- timeout deaktivieren
		timeoutReset<='1';
		report "Test Use Case 3 Polarity" severity note;
		assert sck='0' report  "Test Use Case 3 Polarity" severity failure;
		
		-- UseCase 3 Vector 2 starten
		for j in useCase3Vec2'length-1 downto 0 loop
			enable<='1';
			wait until ready='0';
			-- Slave Select Testen
			assert ss='0' report "Use Case 3 Error bei Byte " & integer'image(useCase3Vec2'length-1-j) & " Slave Select Error" severity failure;
			-- Transfer starten
			for i in 0 to 7 loop					
				miso<=useCase3Vec2(j)(7-i);		
				wait until sck='1';		
				wait until sck='0';

				--Reset Timeout
				timeoutReset<='1';		
			end loop;
			
			wait until ready='1';
			--gesendete Byte vergleichen
			report "Test Use Case 3/Byte " & integer'image(useCase3Vec2'length-1-j) severity note;
			assert useCase3Vec2(j)=rx report "Use Case 3 Error bei Byte " & integer'image(useCase3Vec2'length-1-j) severity failure;
		end loop;
		enable<='0';
		wait for 5 ns;
		-- Slave Select Testen
		assert ss='1' report "Use Case 3 Error Slave Select Error" severity failure;
		-- timeout deaktivieren
		timeoutReset<='0';
		
		
		--------------------------------------------------------------------------------------------------------------------
		-- Mehrere Bytes Schreiben
		--------------------------------------------------------------------------------------------------------------------
		wait for 1000 ns;
      -- Configuration schreiben
		cpol<='1';
		cpha<='1';
		ssByte<='0';
		miso<='0';
		wait for 10000 ns;
		enable<='1';
		
		-- timeout deaktivieren
		timeoutReset<='1';
		report "Test Use Case 4 Polarity" severity note;
		assert sck='1' report  "Test Use Case 4 Polarity" severity failure;
		
		-- UseCase 4 Vector 1 starten
		for j in useCase4Vec1'length-1 downto 0 loop
			tx<=useCase4Vec1(j);
			enable<='1';
			wait until ready='0';
			-- Slave Select Testen
			assert ss='0' report "Use Case 4 Error bei Byte " & integer'image(useCase4Vec1'length-1-j) & " Slave Select Error" severity failure;
			-- Transfer starten
			for i in 0 to 7 loop		
				wait until sck='0';
				txTmp(7-i)<=mosi;			
				wait until sck='1';
				--Reset Timeout
				timeoutReset<='1';		
			end loop;
			
			wait until ready='1';
			--gesendete Byte vergleichen
			report "Test Use Case 4/Byte " & integer'image(useCase4Vec1'length-1-j) severity note;
			assert useCase4Vec1(j)=txTmp report "Use Case 4 Error bei Byte " & integer'image(useCase4Vec1'length-1-j) severity failure;
		end loop;
		enable<='0';
		wait for spiTime+10 ns;
		-- Slave Select Testen
		assert ss='1' report "Use Case 4 Error Slave Select Error" severity failure;
		-- timeout deaktivieren
		timeoutReset<='0';
		
		-- nächster Testvector vorbereiten
		wait for 10000 ns;
		enable<='1';
		
		-- timeout deaktivieren
		timeoutReset<='1';
		report "Test Use Case 4 Polarity" severity note;
		assert sck='1' report  "Test Use Case 4 Polarity" severity failure;
		
		-- UseCase 3 Vector 2 starten
		for j in useCase4Vec2'length-1 downto 0 loop
			tx<=useCase4Vec2(j);
			enable<='1';
			wait until ready='0';
			-- Slave Select Testen
			assert ss='0' report "Use Case 4 Error bei Byte " & integer'image(useCase4Vec2'length-1-j) & " Slave Select Error" severity failure;
			-- Transfer starten
			for i in 0 to 7 loop			
				wait until sck='0';
				txTmp(7-i)<=mosi;			
				wait until sck='1';
				--Reset Timeout
				timeoutReset<='1';		
			end loop;
			
			wait until ready='1';
			--gesendete Byte vergleichen
			report "Test Use Case 4/Byte " & integer'image(useCase4Vec2'length-1-j) severity note;
			assert useCase4Vec2(j)=txTmp report "Use Case 4 Error bei Byte " & integer'image(useCase4Vec2'length-1-j) severity failure;
		end loop;
		enable<='0';
		wait for spiTime+10 ns;
		-- Slave Select Testen
		assert ss='1' report "Use Case 4 Error Slave Select Error" severity failure;
		-- timeout deaktivieren
		timeoutReset<='0';
		
		--------------------------------------------------------------------------------------------------------------------
		-- Senden und empfangen mehrere Bytes
		--------------------------------------------------------------------------------------------------------------------
		wait for 1000 ns;
      -- Configuration schreiben
		cpol<='1';
		cpha<='1';
		ssByte<='1';
		miso<='0';
		wait for 10000 ns;
		enable<='1';
		
		-- timeout aktiviren
		timeoutReset<='1';
		report "Test Use Case 5 Polarity" severity note;
		assert sck='1' report  "Test Use Case 5 Polarity" severity failure;
		
		-- UseCase 5 Vector 1 starten
		for j in useCase5Vec1Tx'length-1 downto 0 loop
			tx<=useCase5Vec1Tx(j);
			enable<='1';
			wait until ready='0';
			-- Slave Select Testen
			assert ss='0' report "Use Case 5 Error bei Byte " & integer'image(useCase5Vec1Tx'length-1-j) & " Slave Select Error" severity failure;
			-- Transfer starten
			for i in 0 to 7 loop		
				wait until sck='0';
				miso<=useCase5Vec1Rx(j)(7-i);	
				wait until sck='1';	
				txTmp(7-i)<=mosi;			
				--Reset Timeout
				timeoutReset<='1';		
			end loop;
			
			wait until ready='1';
			--gesendete Byte vergleichen
			report "Test Use Case 5/Byte " & integer'image(useCase5Vec1Tx'length-1-j) severity note;
			assert useCase5Vec1Tx(j)=txTmp report "Use Case 5 Error bei TX Byte " & integer'image(useCase5Vec1Tx'length-1-j) severity failure;
			assert useCase5Vec1Rx(j)=rx report "Use Case 5 Error bei RX Byte " & integer'image(useCase5Vec1Tx'length-1-j) severity failure;
		end loop;
		enable<='0';
		wait for spiTime+10 ns;
		-- Slave Select Testen
		assert ss='1' report "Use Case 5 Error Slave Select Error" severity failure;
		-- timeout deaktiviren
		timeoutReset<='0';
		
			-- nächster Testvector vorbereiten
		wait for 10000 ns;
		enable<='1';
		
		-- timeout deaktivieren
		timeoutReset<='1';
		report "Test Use Case 5 Polarity" severity note;
		assert sck='1' report  "Test Use Case 5 Polarity" severity failure;
		
		
		-- UseCase 5 Vector 2 starten
		for j in useCase5Vec2Tx'length-1 downto 0 loop
			tx<=useCase5Vec2Tx(j);
			enable<='1';
			wait until ready='0';
			-- Slave Select Testen
			assert ss='0' report "Use Case 5 Error bei Byte " & integer'image(useCase5Vec2Tx'length-1-j) & " Slave Select Error" severity failure;
			-- Transfer starten
			for i in 0 to 7 loop		
				wait until sck='0';
				miso<=useCase5Vec2Rx(j)(7-i);	
				wait until sck='1';	
				txTmp(7-i)<=mosi;			
				--Reset Timeout
				timeoutReset<='1';		
			end loop;
			
			wait until ready='1';
			--gesendete Byte vergleichen
			report "Test Use Case 5/Byte " & integer'image(useCase5Vec2Tx'length-1-j) severity note;
			assert useCase5Vec2Tx(j)=txTmp report "Use Case 5 Error bei TX Byte " & integer'image(useCase5Vec2Tx'length-1-j) severity failure;
			assert useCase5Vec2Rx(j)=rx report "Use Case 5 Error bei RX Byte " & integer'image(useCase5Vec2Tx'length-1-j) severity failure;
		end loop;
		enable<='0';
		wait for spiTime+10 ns;
		-- Slave Select Testen
		assert ss='1' report "Use Case 5 Error Slave Select Error" severity failure;
		-- timeout deaktiviren
		timeoutReset<='0';
		--------------------------------------------------------------------------------------------------------------------
		-- Test abgeschlossen
		--------------------------------------------------------------------------------------------------------------------
	
      report "Test abgeschlossen" severity failure;
		wait;
   end process;
	
	
	timeout:process
	begin
		if timeoutReset'last_active>timeoutMax and timeoutReset='1' then
			assert false report "Timeout Error "&time'image(timeoutReset'last_event) severity failure;
		end if;
		wait for timeoutMax/10;
	end process;
	

end;
