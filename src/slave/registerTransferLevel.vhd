--------------------------------------------------------------------------------
-- Entity            : registerTransferLVL
--------------------------------------------------------------------------------
-- Copyright         : 2013
-- Filename          : registerTransferLevel.vhd
-- Creation date     : 19.06.2013
-- Author(s)         : Marc Ludwig <marc.ludwig@stud.fh-jena.de>
-- Version           : 1.00
-- Description       : SPI-Slave auf Register-Transfer-Level.
--------------------------------------------------------------------------------
-- File History:
-- Date                            | Version | Author    | Comment
-- Wed Jun 19 14:56:09 2013 +0200  | 0.10    | Ludwig    | Initial Commit
--                                 | 0.20    | Ludwig    | weiter implementiert
--                                 | 1.00    | Ludwig    | Abgabeversion
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
library work;
use work.slavePackage.all;
--------------------------------------------------------------------------------
entity registerTransferLVL is
    generic (
        portWidth    : dataLength := 8;
        cpol         : clockPolarity := idleLow;
        cpha         : clockPhase := firstEdge
    );
    port (
        clk, sclk, ss, sdi : in  std_logic;
        sdo, valid         : out std_logic;
        sdoReg             : in  std_logic_vector(portWidth-1 downto 0);
        sdiReg             : out std_logic_vector(portWidth-1 downto 0)
    );
end entity registerTransferLVL;
--------------------------------------------------------------------------------
architecture mooreFSM of registerTransferLVL is
    signal currentState, nextState : states := idle;
    signal index : natural range 0 to portWidth := 0;
  -- interne Signale für's RTL-Design
    signal intSclk, intSclkActual, intSclkLast, intSsActual, intSsLast : std_logic;
    signal intSdoReg : std_logic_vector(portWidth-1 downto 0);
    signal intSdiReg : std_logic_vector(portWidth-1 downto 0);

begin
    clockPol : with cpol select intSclk <= sclk when idleLow, not sclk when idleHigh;

    clockGenerate : process(clk)
    begin
        if clk'event and clk = '1' then
            intSclkLast <= intSclkActual; intSclkActual <= intSclk;
            intSsLast <= intSsActual; intSsActual <= ss;
        end if;
    end process clockGenerate;

    stateClock : process(clk) is
    begin
        if clk'event and clk = '1' then
            if intSclkLast = '0' and intSclkActual = '1'  then      -- rising edge
                currentState <= nextState;
            elsif intSclkLast = '1' and intSclkActual = '0'  then   -- falling edge
                currentState <= nextState;
            end if;
            if intSsLast = '0' and intSsActual = '1'  then          -- rising edge
                currentState <= idle;
            elsif intSsLast = '1' and intSsActual = '0'  then       -- falling edge
                currentState <= init;
            end if;
        end if;
    end process stateClock;

    combinational : process(currentState) is
    begin
        case currentState is
            when init | write | lastEdge => nextState <= read;
            when read => if index < dataLength'high-1 then nextState <= write; else nextState <= lastEdge; end if;
            when idle => nextState <= currentState;
        end case;
    end process combinational;

    output : process(currentState) is
    begin
    valid <= '0';
    sdiReg(portWidth-1 downto 0) <= (others=>'Z');
    -- default Zuweisungen
    case currentState is
        when init => sdo <= sdoReg(index); intSdoReg <= sdoReg;
        when read => intSdiReg(index) <= sdi; index <= index+1;
        when write => sdo <= intSdoReg(index);
        when lastEdge => valid <= '1'; index <= 0; sdo <= sdoReg(0); sdiReg <= intSdiReg; intSdoReg <= sdoReg;
        when idle => index <= 0; sdo <= 'Z'; valid <= '0';
    end case;
    end process output;

end architecture mooreFSM;