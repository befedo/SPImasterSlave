--------------------------------------------------------------------------------
-- Entity: multipleSlaves_tb
--------------------------------------------------------------------------------
-- Copyright         : 2013
-- Filename          : multipleSlaves_tb.vhd
-- Creation date     : 24.06.2013
-- Author(s)         : Marc Ludwig <marc.ludwig@stud.fh-jena.de>
-- Version           : 1.00
-- Description       : Testbench zum SPI-Slave, mit vier unterschiedlichen Slaves.
--------------------------------------------------------------------------------
-- File History:
-- Date                            | Version | Author    | Comment
-- Wed Jun 19 14:56:09 2013 +0200  | 0.10    | Ludwig    | Initial Commit
-- Mon Jun 24 -------- 2013 +0200  | 1.00    | Ludwig    | Abgabeversion
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all; 
library work;
use work.slavePackage.all;
use work.testbenchPackage.all;
--------------------------------------------------------------------------------
entity multipleSlaves_tb is
  generic (
    periodeHalbe   : time     := 500 ns;
    used           : usecase  := eightBytes;
    bitsTransfered : positive := ucSize(eightBytes)
  );
end entity multipleSlaves_tb;
--------------------------------------------------------------------------------
architecture testbench of multipleSlaves_tb is 

component fourSlaves is
    generic( count          : integer := 4 );
    port(    clk, sclk, sdi : in  std_logic; 
             sdo            : out std_logic;
             slaveSelect    : in std_logic_vector(count-1 downto 0);
             sdoPort        : in std_logic_vector(dataLength'high-1 downto 0);
             bcdPort0       : out std_logic_vector(6 downto 0);
             bcdPort1       : out std_logic_vector(6 downto 0);
             bcdPort2       : out std_logic_vector(6 downto 0);
             bcdPort3       : out std_logic_vector(6 downto 0);
             bcdPort4       : out std_logic_vector(6 downto 0);
             bcdPort5       : out std_logic_vector(6 downto 0);
             bcdPort6       : out std_logic_vector(6 downto 0);
             bcdPort7       : out std_logic_vector(6 downto 0)
    );
end component fourSlaves;

signal sigClk, sigSclk, sigSdi, sigSdo : std_logic := 'Z';
signal sigSs                   : std_logic_vector(3 downto 0) := "ZZZZ";
signal sigSdoPort              : std_logic_vector(dataLength'high-1 downto 0) := "ZZZZZZZZ";

begin

  mainClock : process is
  begin
    sigClk <= '0'; wait for periodeHalbe/100;
    sigClk <= '1'; wait for periodeHalbe/100;
  end process mainClock;

  dataClock : process is
  begin
    sigSclk <= '0'; wait for periodeHalbe;
    sigSclk <= '1'; wait for periodeHalbe;
  end process dataClock;
  
  generateSlaveSelect : process is
  begin
    sigSs <= "1111"; wait for periodeHalbe/2;
    sigSs <= "0111"; wait for 2*(bitsTransfered-8)*periodeHalbe/4;
    sigSs <= "1011"; wait for 2*(bitsTransfered-8)*periodeHalbe/4;
    sigSs <= "1101"; wait for 2*(bitsTransfered-8)*periodeHalbe/4;
    sigSs <= "1110"; wait for 2*(bitsTransfered-8)*periodeHalbe/4;
    sigSs <= "1111"; wait for periodeHalbe/2;
    report "Simulation beendet!" severity failure; wait;
  end process generateSlaveSelect;

  generateSdi : process is
  begin 
    for index in 0 to ucSize(used)-1 loop
        sigSdi <= ucVector(used)(index); wait for 2*periodeHalbe;
    end loop;
    wait;
  end process generateSdi;

  generateAndCheckSdo : process (sigSclk, sigSs) is
    variable index : integer range 0 to ucSize(used)-1 := 0;
  begin
    if index = 0 then sigSdoPort <= ucVector(used)(dataLength'high-1 downto 0); end if;
    if (index mod 8) = 0 then
      sigSdoPort <= ucVector(used)(index+dataLength'high-1 downto index);
    end if;
    if sigSclk = '1' and sigSclk'event and sigSs /= "1111" then
        if sigSdo = sigSdoPort(index mod 8) then
            report "SDO Signal match!" severity note;
        else
            report "SDO Signal missmatch!" severity failure;
        end if;
        if index < ucSize(used)-1 then index := index+1; else index := 0; end if;
    end if;
  end process generateAndCheckSdo;

--  checkValid : process (sigValid) is
--    variable byteCount : natural range 0 to 2*dataLength'high+1 := 0;
--    variable temp : std_logic_vector(dataLength'high-1 downto 0);
--  begin
--    temp := sigSdiReg;
--    if sigValid = '1' and sigValid'event then
--        if ucVector(used)(byteCount*8+dataLength'high-1 downto byteCount*8) = temp(dataLength'high-1 downto 0) then
--            report "Pattern #" & integer'image(byteCount+1) & " matched." severity note;
--        else
--            report "Pattern #" & integer'image(byteCount+1) & "missmatch!" severity failure;            
--        end if;
--        byteCount := byteCount + 1;
--    end if;
--  end process checkValid;  

  dut:
  entity work.fourSlaves(bcdDataOut)
  generic map(4)
  port map(sigClk, sigSclk, sigSdi, sigSdo, sigSs, sigSdoPort, open, open, open, open, open, open, open, open);

end architecture testbench;