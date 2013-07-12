--------------------------------------------------------------------------------
-- Entity: rtl_tb
--------------------------------------------------------------------------------
-- Copyright         : 2013
-- Filename          : rtl_tb.vhd
-- Creation date     : 19.06.2013
-- Author(s)         : Marc Ludwig <marc.ludwig@stud.fh-jena.de>
-- Version           : 1.00
-- Description       : Testbench zum SPI-Slave auf Register Transfer Ebene
--------------------------------------------------------------------------------
-- File History:
-- Date                            | Version | Author    | Comment
-- Wed Jun 19 14:56:09 2013 +0200  | 1.00    | Ludwig    | Initial Commit
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
library work;
use work.slavePackage.all;
use work.testbenchPackage.all;
--------------------------------------------------------------------------------
entity regTest_tb is
  generic (
    periodeHalbe   : time     := 500 ns;
    used           : usecase  := eightBytes;
    bitsTransfered : positive := ucSize(eightBytes)
  );
end entity regTest_tb;
--------------------------------------------------------------------------------
architecture testbench of regTest_tb is 

component regTest is
  generic (
    portWidth          : dataLength := 8;
    cpol               : clockPolarity := idleLow;
    cpha               : clockPhase := firstEdge
  );      
  port (
    clk, sclk, ss, sdi, reset : in  std_logic;
    sdo, valid         : out std_logic;
    sdoReg             : in  std_logic_vector(portWidth-1 downto 0);
    sdiReg             : out std_logic_vector(portWidth-1 downto 0) 
  );
end component regTest;

signal sigClk, sigSclk, sigSs, sigSdi, sigReset : std_logic;
signal sigSdo, sigValid       : std_logic;
signal sigSdoReg              : std_logic_vector(dataLength'high-1 downto 0);
signal sigSdiReg              : std_logic_vector(dataLength'high-1 downto 0);

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
    sigSs <= '1'; wait for periodeHalbe/2;
    sigSs <= '0'; wait for 2*bitsTransfered*periodeHalbe;
  	sigSS <= '1'; wait;
  end process generateSlaveSelect;

	generateReset : process is
  begin
    sigReset <= '1'; wait for periodeHalbe/4;
    sigReset <= '0'; wait for 2*bitsTransfered*periodeHalbe + periodeHalbe;
  	sigReset <= '1'; wait;
  end process generateReset;

  generateSdi : process is
  begin 
    for index in 0 to ucSize(used)-1 loop
        sigSdi <= ucVector(used)(index); wait for 2*periodeHalbe;
    end loop;
    wait for 2*periodeHalbe;    
  	report "Simulation beendet!" severity failure;
  	wait;
  end process generateSdi;

  generateAndCheckSdo : process (sigSclk, sigSs, sigValid) is
    variable index : integer range 0 to ucSize(used)-1 := 0;
  begin
    if index = 0 then sigSdoReg <= ucVector(used)(dataLength'high-1 downto 0); end if;
    if (index mod 8) = 0 then
      sigSdoReg <= ucVector(used)(index+dataLength'high-1 downto index);
    end if;
    if sigSclk = '1' and sigSclk'event and sigSs = '0' then
        if sigSdo = sigSdoReg(index mod 8) then
            report "SDO Signal match!" severity note;
        else
            -- report "SDO Signal missmatch!" severity failure;
        end if;
        if index < ucSize(used)-1 then index := index+1; else index := 0; end if;
    end if;
  end process generateAndCheckSdo;

  checkValid : process (sigValid) is
    variable byteCount : natural range 0 to 2*dataLength'high+1 := 0;
    variable temp : std_logic_vector(dataLength'high-1 downto 0);
  begin
    temp := sigSdiReg;
    if sigValid = '1' and sigValid'event then
        if ucVector(used)(byteCount*8+dataLength'high-1 downto byteCount*8) = temp(dataLength'high-1 downto 0) then
            report "Pattern #" & integer'image(byteCount+1) & " matched." severity note;
        else
            -- report "Pattern #" & integer'image(byteCount+1) & "missmatch!" severity failure;            
        end if;
        byteCount := byteCount + 1;
    end if;
  end process checkValid;  

  dut:
  entity work.regTest(structure)
--  generic map(8, idleHigh, firstEdge)
  port map(sigClk, sigSclk, sigSs, sigSdi, sigReset, sigSdo, sigValid, sigSdoReg, sigSdiReg);

end architecture testbench;