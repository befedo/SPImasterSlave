--------------------------------------------------------------------------------
-- Package Deklarationen zum SPI Slave
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;


package slavePackage is
	-- es existieren Vier mögliche Modi
	type clockPolarity is (idleLow, idleHigh);
	type clockPhase is (firstEdge, secondEdge);
	type mode is array(idleLow to idleHigh) of clockPhase;
	-- ergibt:
	-- MODE | CPOL 	| CPHA
	--	0	  |	0	    |	0
	--	1	  |	0	    |	1
	--	2	  |	1	    |	0
	--	3	  |	1	    |	1
	subtype dataLength	is natural range 1 to 8;
	-- Allgemeine Verzögerungszeit
	constant delay : time := 20 ns;
	-- Zustandcodierung	
    type states is (idle, init, read, write, lastEdge);
end package slavePackage;


--------------------------------------------------------------------------------
-- Package Deklarationen zur Testbench
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use WORK.slavePackage.all;


package testbenchPackage is
    subtype patternVector is std_logic_vector(dataLength'high-1 downto 0);
    subtype testVector    is std_logic_vector;
    constant response  : std_logic     := '1';
    constant useCount  : positive      := 16;
    constant usecase1  : patternVector := "00000001";
    constant usecase2  : patternVector := "00000010";
    constant usecase3  : patternVector := "00000100";
    constant usecase4  : patternVector := "00001000";
    constant usecase5  : patternVector := "00010000";
    constant usecase6  : patternVector := "00100000";
    constant usecase7  : patternVector := "01000000";
    constant usecase8  : patternVector := "10000000";
    constant usecase9  : patternVector := "01000000";
    constant usecase10 : patternVector := "00100000";
    constant usecase11 : patternVector := "00010000";
    constant usecase12 : patternVector := "00001000";
    constant usecase13 : patternVector := "00000100";
    constant usecase14 : patternVector := "00000010";
    constant usecase15 : patternVector := "00000001";
    constant usecase16 : patternVector := "00000000";
    constant usecase17 : patternVector := "11111111";
    constant testCase  : testVector    := usecase1 & usecase2  & usecase3  & usecase4  & usecase5  & usecase6  & usecase7  & usecase8  &
                                          usecase9 & usecase10 & usecase11 & usecase12 & usecase13 & usecase14 & usecase15 & usecase16 & usecase17;
end package testbenchPackage;