library IEEE;
use IEEE.std_logic_1164.all; 
library WORK;
use WORK.slavePackage.all;

entity slaveAlgorithmic_tb is end entity slaveAlgorithmic_tb;

architecture testbench of slaveAlgorithmic_tb is
    component slaveAlgorithmic is
	    generic (portWidth : dataLength := 8
	    );
	    port ( sdi, ss : in  boolean;
	           sdo     : out boolean;
	           sdoPort : in  IOport;
	           sdiPort : out IOport
	    );
    end component slaveAlgorithmic;

    signal sigSdi, sigSdo, sigSs : boolean;
    signal sigSdiPort, sigSdoPort : IOport;

begin
    foobar : process is
        variable testcase : IOport := (true,true,false,false,true,false,true,true);
    begin
    	sigSdoPort <= (true,false,true,false,true,false,true,false);
    	sigSs      <= true, false after delay, true after 19*delay;
    	for index in IOport'range loop
    	   sigSdi <= testcase(index) after 2*delay;
    	end loop;
    	wait for 20*delay; report "Simulation beendet!" severity failure;
    	wait;
    end process foobar;

  dut:
  entity work.slaveAlgorithmic(algorithmic)
  port map(sigSdi, sigSs, sigSdo, sigSdoPort, sigSdiPort);

end architecture testbench;