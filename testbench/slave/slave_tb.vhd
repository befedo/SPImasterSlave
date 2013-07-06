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
signal sigSdoReg              : std_logic_vector(7 downto 0);
signal sigSdiReg              : std_logic_vector(7 downto 0);

begin

  sigSdoReg <= X"AB";

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
    variable bytesTransfered : positive := bitsTransfered/dataLength'high;
  begin 
    for index in 0 to testCase'length-1 loop 
            sigSdi <= testCase(index);
            wait for 2*periodeHalbe;
    end loop;
    wait for 2*periodeHalbe;    
  	assert false report "Simulation beendet!" severity failure;
  	wait;
  end process generateSdi;

  checkValid : process (sigValid) is
    variable byteCount : natural := 0;
  begin
    if sigValid = '1' and sigValid'event then
      assert testVector(byteCount*8+7 downto byteCount) = sigSdoReg(7 downto 0) report "F00B4R" severity failure;
    end if;
  end process checkValid;  

  dut:
  entity work.slave(abstract)
  generic map(8, idleHigh, firstEdge)
  port map(sigSclk, sigSs, sigSdi, sigSdo, sigValid, sigSdoReg, sigSdiReg);

end architecture testbench;