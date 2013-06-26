--------------------------------------------------------------------------------
-- Entity            : transactionLVL
--------------------------------------------------------------------------------
-- Copyright         : 2013
-- Filename          : transactionLevel.vhd
-- Creation date     : 24.06.2013
-- Author(s)         : Marc Ludwig <marc.ludwig@stud.fh-jena.de>
-- Version           : 1.00
-- Description       : Transaction Level entity auf algorithmischer Ebene.
--------------------------------------------------------------------------------
-- File History:
-- Date                            | Version | Author    | Comment
-- Wed Jun 19 14:56:09 2013 +0200  | 1.00    | Ludwig    | Initial Commit
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.slavePackage.all;
--------------------------------------------------------------------------------
entity transactionLVL is
    generic( portWidth : dataLength := 8
    );
    port(    sdi, ss   : in  bit;
             sdo       : out bit;
             valid     : inout bit;
             sdoPort   : in  bit_vector(portWidth-1 downto 0);
             sdiPort   : out bit_vector(portWidth-1 downto 0)
    );
end entity transactionLVL;
--------------------------------------------------------------------------------
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