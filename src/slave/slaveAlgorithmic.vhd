library IEEE;
use IEEE.std_logic_1164.all; 
library WORK;
use WORK.slavePackage.all;

entity slaveAlgorithmic is
    generic (portWidth : dataLength := 8
    );
	port ( sdi, ss     : in  bit;
	       sdo         : out bit;
	       valid       : inout bit;
	       sdoPort     : in  bit_vector(portWidth-1 downto 0);
	       sdiPort     : out bit_vector(portWidth-1 downto 0)
	);
end entity slaveAlgorithmic;

architecture algorithmic of slaveAlgorithmic is 

begin
    process is
        variable index : natural range sdiPort'range := 0;
    begin
        wait until ss'event and ss = '0';
            while ss = '0' loop
                for index in sdiPort'range loop
                    sdiPort(index) <= sdi;
                    sdo <= sdoPort(index);
                    wait for delay;
                end loop;
            valid <= not valid;
            wait for delay;
            valid <= not valid;
            end loop;
    end process;
end architecture algorithmic;