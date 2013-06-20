library ieee;
use ieee.std_logic_1164.all;
library work;
use work.slavePackage.all;

entity transactionLVL is
    generic (portWidth : dataLength := 8
    );
    port (  sdi, ss : in  bit;
            sdo     : out bit;
            valid   : inout bit;
            sdoPort : in  bit_vector(portWidth-1 downto 0);
            sdiPort : out bit_vector(portWidth-1 downto 0)
    );
end entity transactionLVL;

architecture timedFunction of transactionLVL is

begin
    process is
    begin
        wait until ss'event and ss = '0';   -- Event zum start des Algotithmus ist die fallende flanke von SlaveSelect
        while ss = '0' loop                 -- und er wird solange ausgeführt, wie SlaveSelect Null bleibt (siehe Spec).
            for index in 0 to sdiPort'length-1 loop
                wait for delay/2;           -- Solange Daten in eine Portbreite passen
                sdiPort(index) <= sdi;      -- werden diese eingelesen und
                sdo <= sdoPort(index);      -- analog welche ausgegeben (Vollduplex Betrieb).
                wait for delay/2;             -- Modellierung der Latenzzeit nach timed-function-model
            end loop;
            valid <= not valid;             -- nach Abschluß des Einlese-/Schreibvorgangs
            wait for delay;                 -- wird das Valid Signal getoggelt
            valid <= not valid;
        end loop;
    end process;
end architecture timedFunction;