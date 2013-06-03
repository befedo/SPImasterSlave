library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 
library WORK;
use WORK.slavePKG.all;

entity slave is
  generic (portWidth 	: dataLength := 8;
           cpol       : clockPolarity := idleLow;
           cpha       : clockPhase := firstEdge
	);  	
	port (sclk, ss, sdi : in  bit;
				sdo, valid    : out std_logic;
				sdoReg	      : in  bit_vector(portWidth-1 downto 0);
				sdiReg        : out std_logic_vector(portWidth-1 downto 0) 
	);
end entity slave;

architecture abstract of slave is 

  type states is (idle, working);
  signal currentState, nextState : states;
  signal stateCount : integer range 0 to portWidth-1 := 0;
  signal tempSdoReg : std_logic_vector(portWidth-1 downto 0);
  signal tempSdi : bit_vector(0 downto 0);

begin

  stateMemory : process(sclk, ss) is
  begin
  	if ss = '1' then
  	  currentState <= idle after delay;
  	elsif sclk = '1' and sclk'event then
  	  currentState <= nextState after delay;
  	end if;
  end process stateMemory;

  combinational : process(sdi, ss, currentState) is    
  begin
  	case currentState is  
  		when idle    => if ss = '0' then
  		                    nextState <= working after delay;
  		                else
  		                    nextState <= idle after delay;
  		                end if;  		                
  		when working => if stateCount > 0 then
  		                    nextState <= working after delay;
  		                else
  		                    nextState <= idle after delay;
  		                end if;  		                
  	end case;
  end process combinational;

  output : process(sclk, currentState) is
  begin
	  if sclk = '1' and sclk'event then	   
	    case currentState is
        when idle    => sdo <= 'Z' after delay;
                        valid <= '0' after delay;
                        stateCount <= portWidth-1 after delay;
        when working => tempSdoReg <= To_StdLogicVector(sdoReg);
                        sdo <= tempSdoReg(stateCount) after delay;
                        tempSdi(0) <= sdi;
                        sdiReg(stateCount) <= To_StdLogicVector(tempSdi)(0) after delay;                        
                        stateCount <= stateCount - 1;
                        if stateCount = 0 then
                          valid <= '1' after delay;                                                    
                        end if;
      end case;
	  end if;
  end process output;

end architecture abstract;