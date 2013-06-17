library IEEE;
use IEEE.std_logic_1164.all; 
library WORK;
use WORK.slavePackage.all;

entity slaveAlgorithmic is
    generic (portWidth : dataLength := 8
    );
	port ( sdi, ss : in  boolean;
	       sdo     : out boolean;
	       sdoPort : in  IOport;
	       sdiPort : out IOport
	);
end entity slaveAlgorithmic;

architecture algorithmic of slaveAlgorithmic is 

begin
    process is
        variable index : natural range IOport'range := 0;
    begin
        wait until ss'event and ss = false;
            for index in IOport'range loop
                sdiPort(index) <= sdi;
                sdo <= sdoPort(index);
                wait for delay;
            end loop;
    end process;
end architecture algorithmic;