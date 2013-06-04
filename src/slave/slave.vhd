library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 
library WORK;
use WORK.slavePKG.all;

entity slave is
  generic (portWidth  : dataLength := 8;
           cpol       : clockPolarity := idleLow;
           cpha       : clockPhase := firstEdge
	);  	
	port (sclk, ss, sdi       : in  std_logic;
				sdo, valid    : out std_logic;
				sdoReg	      : in  std_logic_vector(portWidth-1 downto 0);
				sdiReg        : out std_logic_vector(portWidth-1 downto 0) 
	);
end entity slave;

architecture abstract of slave is 

  type states is (idle, init, Z0, Z1, Z2, Z3, Z4, Z5, Z6, Z7, Z8, Z9, Z10, Z11, Z12, Z13, Z14, Z15);
  signal currentState, nextState : states := idle;
  signal index : integer range 0 to portWidth := 0;
  -- interne Signale für's RTL-Design
  signal intClk : std_logic;
  signal intSdoReg : std_logic_vector(portWidth-1 downto 0);
  signal intSdiReg : std_logic_vector(portWidth-1 downto 0);

begin
  clockPol : with cpol select intClk <= sclk xor '0' when idleLow, sclk xor '1' when idleHigh;  

  stateMemory : process(intClk, ss) is
  begin
  	if ss = '0' and ss'event then
  	  currentState <= init after delay;
  	elsif ss = '1' and ss'event then
      currentState <= idle after delay;
    end if;
    
   if intClk'event then
  	  currentState <= nextState after delay;
  	end if;
  end process stateMemory;

  combinational : process(currentState) is    
  begin
  	case currentState is  
  		when init => nextState <= Z0;
  		when Z0   => nextState <= Z1;
  		when Z1   => nextState <= Z2;
  		when Z2   => nextState <= Z3;
  		when Z3   => nextState <= Z4;
  		when Z4   => nextState <= Z5;
  		when Z5   => nextState <= Z6;
  		when Z6   => nextState <= Z7;
  		when Z7   => nextState <= Z8;
  		when Z8   => nextState <= Z9;
  		when Z9   => nextState <= Z10;
  		when Z10  => nextState <= Z11;
  		when Z11  => nextState <= Z12;
  		when Z12  => nextState <= Z13;
  		when Z13  => nextState <= Z14;
  		when Z14  => nextState <= Z15;
  		when Z15  => nextState <= Z0;
  		when idle => nextState <= idle;
  	end case;
  end process combinational;

  output : process(currentState) is
  begin
    case currentState is
      when init                  => sdo <= sdoReg(index);
                                    intSdoReg <= sdoReg;
      when Z0 | Z2  | Z4  | Z6 |
           Z8 | Z10 | Z12 | Z14  => intSdiReg(index) <= sdi;
                                    index <= index+1;
      when Z1 | Z3  | Z5  | Z7 |
           Z9 | Z11 | Z13        => sdo <= intSdoReg(index);                                    
      when Z15                   => valid <= '1';
                                    index <= 0;
                                    sdo <= 'Z'; -- Spezifikation etwas schwammig
                                    sdiReg <= intSdiReg;
      when idle                  => index <= 0;
                                    sdo <= 'Z';
                                    valid <= '0';
                                    sdiReg(portWidth-1 downto 0) <= (others=>'Z');
    end case;
  end process output;

end architecture abstract;