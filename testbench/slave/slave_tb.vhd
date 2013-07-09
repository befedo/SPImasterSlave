library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 
library WORK;
use WORK.slavePackage.all;
use WORK.testbenchPackage.all;


entity slave_tb is
  generic(periodeHalbe : time := 500 ns; bitsTransfered : positive := 128);
end entity slave_tb;


architecture testbench of slave_tb is 

component slave is
  generic (portWidth          : dataLength := 8;
           cpol               : clockPolarity := idleLow;
           cpha               : clockPhase := firstEdge
    );      
    port (sclk, ss, sdi       : in  std_logic;
                sdo, valid    : out std_logic;
                sdoReg        : in  std_logic_vector(portWidth-1 downto 0);
                sdiReg        : out std_logic_vector(portWidth-1 downto 0) 
    );
end component slave;

signal sigSclk, sigSs, sigSdi : std_logic;
signal sigSdo, sigValid       : std_logic;
signal sigSdoReg              : std_logic_vector(dataLength'high-1 downto 0);
signal sigSdiReg              : std_logic_vector(dataLength'high-1 downto 0);

begin

  clock : process is
  begin
  	sigSclk <= '0'; wait for periodeHalbe;
  	sigSclk <= '1'; wait for periodeHalbe;
  end process clock;
  
  generateSlaveSelect : process is
  begin
    sigSs <= '1'; wait for periodeHalbe/2;
    sigSs <= '0'; wait for 2*bitsTransfered*periodeHalbe + periodeHalbe/2;        	
  	sigSS <= '1'; wait;
  end process generateSlaveSelect;

  generateSdi : process is
  begin 
    for index in 0 to bitsTransfered-1 loop 
        sigSdi <= testCase(index); wait for 2*periodeHalbe;
    end loop;
    wait for 2*periodeHalbe;    
  	report "Simulation beendet!" severity failure;
  	wait;
  end process generateSdi;

  generateAndCheckSdo : process (sigSclk, sigSs, sigValid) is
    variable index : integer range 0 to testCase'length-1 := 0;
  begin
    if index = 0 then sigSdoReg <= testCase(0 to dataLength'high-1); end if;
    if (index mod 8) = 0 then
      sigSdoReg <= testCase(index to index+dataLength'high-1);
    end if;
    if sigSclk = '1' and sigSclk'event then
        if sigSdo = sigSdoReg(index mod 8) then
            report "SDO Signal match!" severity note;
        else
            report "SDO Signal missmatch!" severity failure;
        end if;
        index := index+1;
    end if;
  end process generateAndCheckSdo;

  checkValid : process (sigValid) is
    variable byteCount : natural range 0 to 2*dataLength'high := 0;
    variable temp : std_logic_vector(dataLength'high-1 downto 0);
  begin
    temp := sigSdiReg;
    if sigValid = '1' and sigValid'event then
        -- little endianess zu big endianess Konvertierung
        for index in 0 to temp'length/2-1 loop
            temp(index) := sigSdiReg(dataLength'high-1-index);
            temp(dataLength'high-1-index) := sigSdiReg(index);
        end loop;
        if testCase(byteCount*8 to byteCount*8+dataLength'high-1) = temp(dataLength'high-1 downto 0) then
            report "Pattern #" & integer'image(byteCount+1) & " matched." severity note;
        else
            report "Pattern #" & integer'image(byteCount+1) & "missmatch!" severity failure;            
        end if;
        byteCount := byteCount + 1;
    end if;
  end process checkValid;  

  dut:
  entity work.slave(abstract)
  generic map(8, idleHigh, firstEdge)
  port map(sigSclk, sigSs, sigSdi, sigSdo, sigValid, sigSdoReg, sigSdiReg);

end architecture testbench;