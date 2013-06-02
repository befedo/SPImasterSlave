--------------------------------------------------------------------------------
-- Package Deklarationen zum SPI Slave
--------------------------------------------------------------------------------
package slavePKG is
	-- es existieren Vier mögliche Modi
	type clockPoalrity	is (idleLow, idleHigh);
	type clockPhase 	is (firstEdge, secondEdge);
	type mode 			is array ( idleLow to idleHigh) of clockPhase;
	-- ergibt:
	-- MODE | CPOL 	| CPHA
	--	0	|	0	|	0
	--	1	|	0	|	1
	--	2	|	1	|	0
	--	3	|	1	|	1
	subtype dataLength	is positive range 1 to 8;	
end package slavePKG;