--------------------------------------------------------------------------------
-- Package: slavePackage, testbenchPackage
--------------------------------------------------------------------------------
-- Copyright         : 2013
-- Filename          : package.vhd
-- Creation date     : 19.06.2013
-- Author(s)         : Marc Ludwig <marc.ludwig@stud.fh-jena.de>
-- Version           : 1.00
-- Description       : Packages zum SPI-Projekt
--------------------------------------------------------------------------------
-- File History:
-- Date                            | Version | Author    | Comment
-- Wed Jun 19 14:56:09 2013 +0200  | 0.10    | Ludwig    | Initial Commit
--                                 | 0.20    | Ludwig    | Testbenches weiter implementiert
--                                 | 1.00    | Ludwig    | Abgabeversion
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
--------------------------------------------------------------------------------
package slavePackage is    
	-- es existieren Vier mögliche Modi
	type clockPolarity is (idleLow, idleHigh);
	type clockPhase is (firstEdge, secondEdge);
	type mode is array(idleLow to idleHigh) of clockPhase;
	-- ergibt:
	-- MODE   | CPOL 	| CPHA
	--	0	  |	0	    |	0
	--	1	  |	0	    |	1
	--	2	  |	1	    |	0
	--	3	  |	1	    |	1
	subtype dataLength	is natural range 1 to 8; -- Wortlänge
	-- Allgemeine Verzögerungszeit
	constant delay : time := 20 ns;
	-- Zustandcodierung	
    type states is (idle, init, read, write, lastEdge);
end package slavePackage;
--------------------------------------------------------------------------------
-- Package Deklarationen zur Testbench
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.slavePackage.all;
--------------------------------------------------------------------------------
package testbenchPackage is    
    subtype patternVector is std_logic_vector(dataLength'high-1 downto 0);    
    subtype testVector    is std_logic_vector(17*dataLength'high-1 downto 0);
    subtype usecaseSize   is positive range 1 to 17*patternVector'length;      
    type    usecase       is (oneByte, eightBytes, faultByte);
    type    usecaseArray  is array (oneByte to faultByte) of testVector;
    type    sizeArray     is array (oneByte to faultByte) of usecaseSize;
    constant pattern1  : patternVector := X"e3";    -- http://www.random.org/bytes/
    constant pattern2  : patternVector := X"f3";
    constant pattern3  : patternVector := X"08";
    constant pattern4  : patternVector := X"84";
    constant pattern5  : patternVector := X"4e";
    constant pattern6  : patternVector := X"03";
    constant pattern7  : patternVector := X"e4";
    constant pattern8  : patternVector := X"07";
    constant pattern9  : patternVector := X"24";
    constant pattern10 : patternVector := X"16";
    constant pattern11 : patternVector := X"aa";
    constant pattern12 : patternVector := X"f2";
    constant pattern13 : patternVector := X"2b";
    constant pattern14 : patternVector := X"e2";
    constant pattern15 : patternVector := X"ff";
    constant pattern16 : patternVector := X"92";
    constant pattern17 : patternVector := X"2d";
    constant ucSize    : sizeArray     := ( patternVector'length, 17*patternVector'length, patternVector'length/2 );
    constant ucVector  : usecaseArray  := ( (7 | 5 | 3 | 1 => '1', 6 | 4 | 2 | 0 => '0', others=>'0'),
                                            (pattern1 & pattern2  & pattern3  & pattern4  & pattern5  & pattern6  & pattern7  & pattern8  & pattern9 & pattern10 & pattern11 & pattern12 & pattern13 & pattern14 & pattern15 & pattern16 & pattern17),
                                            (3 downto 0 => '1', others=>'0') );
end package testbenchPackage;