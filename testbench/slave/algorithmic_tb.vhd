library ieee;
use ieee.std_logic_1164.all;
library work;
use work.slavePackage.all;
use work.testbenchPackage.all;
--
-- commit  : b5a41713157f1231450373acfc3aabb57556601c
-- Author  : Marc Ludwig <s0maludw@stud.fh-jena.de>
-- Date    : Wed Jun 19 14:56:09 2013 +0200
-- Version : 0.1 - Initial
--           0.2 - Testbenches weiter implementiert
--           1.0 - Abgabeversion
--
entity algorithmic_tb is
    generic (used : usecase := eightBytes);
end entity algorithmic_tb;


architecture testbench of algorithmic_tb is
    component transactionLVL is
        generic ( portWidth : dataLength := 8
        );
        port (    sdi, ss   : in  bit;
                  sdo       : out bit;
                  valid     : inout bit;
                  sdoPort   : in  bit_vector(portWidth-1 downto 0);
                  sdiPort   : out bit_vector(portWidth-1 downto 0)
        );
    end component transactionLVL;

    signal sigSdi, sigSdo, sigSs, sigValid : bit;
    signal sigSdiPort, sigSdoPort : bit_vector(dataLength'high-1 downto 0);

begin
    algorithmic : process is
        constant testcase : bit_vector(ucVector(used)'range) := to_bitvector(ucVector(used));
    begin
        sigSdoPort <= X"AB";
        -- erzeugen der SlaveSelect Belegung für die Länge eines use-cases (siehe Package)
        sigSs      <= '1', '0' after delay, '1' after (ucSize(used)+1)*delay;
        wait for delay;
        -- Iterationen über den gesamten Use-Case Vector und Zuweisen an SDI
        for index in 0 to ucSize(used)-1 loop
            sigSdi <= testcase(index);
            wait for delay;
        end loop;
        wait for delay;
        report "Simulation beendet!" severity failure;
        wait;
    end process algorithmic;

     checkValid : process (sigValid) is
        variable byteCount : natural range 0 to 2*dataLength'high+1 := 0; -- Zählvariable
      begin
        if sigValid = '1' and sigValid'event then
            -- überprüfen des Slices aus dem Use-Case-Vektor mit den eingelesenen Signalen
            if to_bitvector(ucVector(used)(byteCount*8+dataLength'high-1 downto byteCount*8)) = sigSdiPort(dataLength'high-1 downto 0) then
                report "Pattern #" & integer'image(byteCount+1) & " matched." severity note;
            else
                --report "Pattern #" & integer'image(byteCount+1) & " missmatch!" severity failure;            
            end if;
            byteCount := byteCount + 1;
        end if;
      end process checkValid;
    -- Componenteninstanziierung
    dut :
    entity work.transactionLVL(timedFunction)
    generic map (dataLength'high)
    port map (sigSdi, sigSs, sigSdo, sigValid, sigSdoPort, sigSdiPort);

end architecture testbench;