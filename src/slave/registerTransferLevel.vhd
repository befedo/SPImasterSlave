library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all; 
library WORK;
use WORK.slavePackage.all;

entity registerTransferLVL is
  generic (portWidth  : dataLength := 8;
           cpol       : clockPolarity := idleLow;
           cpha       : clockPhase := firstEdge
	);  	
	port (sclk, ss, sdi : in  std_logic;
		  sdo, valid    : out std_logic;
		  sdoReg	    : in  std_logic_vector(portWidth-1 downto 0);
		  sdiReg        : out std_logic_vector(portWidth-1 downto 0) 
	);
end entity registerTransferLVL;

architecture mooreFSM of registerTransferLVL is    
  signal currentState, nextState : states := idle;
  signal index : natural range 0 to portWidth := 0;
  -- interne Signale für's RTL-Design
  signal intClk : std_logic;
  signal intSdoReg : std_logic_vector(portWidth-1 downto 0);
  signal intSdiReg : std_logic_vector(portWidth-1 downto 0);

begin
  clockPol : with cpol select intClk <= sclk when idleLow, not sclk when idleHigh;  

  stateMemory : process(intClk, ss) is
  begin
  	if ss = '0' and ss'event then
  	  currentState <= init;
  	elsif ss = '1' and ss'event then
      currentState <= idle;
    end if;

    if intClk'event and ss = '0' then
      currentState <= nextState;
    end if;
  end process stateMemory;

  combinational : process(currentState) is    
  begin
  	case currentState is
        when init | write | lastEdge => nextState <= read;
        when read => if index<dataLength'high-1 then nextState <= write; else nextState <= lastEdge; end if;
        when idle => nextState <= currentState;
  	end case;
  end process combinational;

  output : process(currentState) is
  begin
    valid <= '0';
    sdiReg(portWidth-1 downto 0) <= (others=>'Z');
    -- default Zuweisungen
    case currentState is
      when init     => sdo <= sdoReg(index); intSdoReg <= sdoReg; 
      when read     => intSdiReg(index) <= sdi; index <= index+1;
      when write    => sdo <= intSdoReg(index);
      when lastEdge => valid <= '1'; index <= 0; sdo <= sdoReg(0); sdiReg <= intSdiReg; intSdoReg <= sdoReg;
      when idle     => index <= 0; sdo <= 'Z'; valid <= '0';                                    
    end case;
  end process output;

end architecture mooreFSM;