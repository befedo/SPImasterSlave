library IEEE;
use IEEE.std_logic_1164.all;
library WORK;
use WORK.slavePackage.all;
use WORK.testbenchPackage.all;

entity slaveAlgorithmic_tb is
    generic (used         : usecase  := eightBytes);
end entity slaveAlgorithmic_tb;

architecture testbench of slaveAlgorithmic_tb is
    component slaveAlgorithmic is
	    generic (portWidth : dataLength := 8
	    );
	    port ( sdi, ss     : in  bit;
	           sdo         : out bit;
               valid       : inout bit;
	           sdoPort     : in  bit_vector(portWidth-1 downto 0);
	           sdiPort     : out bit_vector(portWidth-1 downto 0)
	    );
    end component slaveAlgorithmic;

    signal sigSdi, sigSdo, sigSs, sigValid : bit;
    signal sigSdiPort, sigSdoPort : bit_vector(dataLength'high-1 downto 0);

begin
    foobar : process is
        variable testcase : bit_vector(ucVector(used)'range) := to_bitvector(ucVector(used));
    begin
    	sigSdoPort <= X"AB";
    	sigSs      <= '1', '0' after delay, '1' after (ucSize(used)+1)*delay;
    	wait for delay;
    	for index in 0 to ucSize(used)-1 loop
    	   sigSdi <= testcase(index);
    	   wait for delay;
    	end loop;
    	wait for delay;
        report "Simulation beendet!" severity failure;
    	wait;
    end process foobar;

  dut:
  entity work.slaveAlgorithmic(algorithmic)
  generic map (dataLength'high)
  port map (sigSdi, sigSs, sigSdo, sigValid, sigSdoPort, sigSdiPort);

end architecture testbench;