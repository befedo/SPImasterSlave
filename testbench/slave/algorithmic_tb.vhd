library IEEE;
use IEEE.std_logic_1164.all;
library WORK;
use WORK.slavePackage.all;
use WORK.testbenchPackage.all;


entity algorithmic_tb is
    generic (used : usecase := eightBytes);
end entity algorithmic_tb;


architecture testbench of algorithmic_tb is
    component transactionLVL is
        generic (portWidth : dataLength := 8
        );
        port ( sdi, ss  : in  bit;
            sdo         : out bit;
            valid       : inout bit;
            sdoPort     : in  bit_vector(portWidth-1 downto 0);
            sdiPort     : out bit_vector(portWidth-1 downto 0)
        );
    end component transactionLVL;

    signal sigSdi, sigSdo, sigSs, sigValid : bit;
    signal sigSdiPort, sigSdoPort : bit_vector(dataLength'high-1 downto 0);

begin
    foobar : process is
        constant testcase : bit_vector(ucVector(used)'range) := to_bitvector(ucVector(used));
    begin
        sigSdoPort <= X"AB";
        -- erzeugen der SlaveSelect Belegung für die Länge eines use-cases (siehe Package)
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

    dut :
    entity work.transactionLVL(timedFunction)
    generic map (dataLength'high)
    port map (sigSdi, sigSs, sigSdo, sigValid, sigSdoPort, sigSdiPort);

end architecture testbench;