library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 
library WORK;
use WORK.slavePKG.all;


entity slave_tb is
  generic(periodeHalbe : time := 500 ns);
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

  sigSdoReg <= "01010011";

  clock : process is
  begin
  	sigSclk <= '1'; wait for periodeHalbe;
  	sigSclk <= '0'; wait for periodeHalbe;
  end process clock;
  
  generateSlaveSelect : process is
  begin
  	sigSs <= '1'; wait for periodeHalbe/2;
  	sigSs <= '0'; wait for 16*periodeHalbe;
  	sigSS <= '1'; wait;
  end process generateSlaveSelect;

  generateSdi : process is
  begin
  	sigSdi <= '0', '1' after periodeHalbe/2, '0' after 2*periodeHalbe, '1' after 4*periodeHalbe
  	             , '0' after 6*periodeHalbe, '1' after 8*periodeHalbe, '0' after 10*periodeHalbe
  	             , '1' after 12*periodeHalbe, '0' after 14*periodeHalbe, '1' after 16*periodeHalbe
  	             , '0' after 18*periodeHalbe;
  	wait for 18*periodeHalbe;
  	assert false report "Simulation beendet!" severity failure;  	
  	wait;
  end process generateSdi;

  dut:
  entity work.slave(abstract)
  generic map(8, idleHigh, firstEdge)
  port map(sigSclk, sigSs, sigSdi, sigSdo, sigValid, sigSdoReg, sigSdiReg);

end architecture testbench;