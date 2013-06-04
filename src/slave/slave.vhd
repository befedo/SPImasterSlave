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
  signal currentState, nextState : states;
  signal index : integer range 0 to portWidth-1 := 0;

begin

  stateMemory : process(sclk, ss) is
  begin
  	if ss = '0' and ss'event then
  	  currentState <= init after delay;
  	elsif ss = '1' and ss'event then
      currentState <= idle after delay;
    end if;
    
   if sclk'event then
  	  currentState <= nextState after delay;
  	end if;
  end process stateMemory;

  combinational : process(currentState) is    
  begin
  	case currentState is  
  		when init    => nextState <= Z0;   index <= 0;
  		when Z0      => nextState <= Z1;
  		when Z1      => nextState <= Z2;   index <= 1;
  		when Z2      => nextState <= Z3;
  		when Z3      => nextState <= Z4;   index <= 2;
  		when Z4      => nextState <= Z5;
  		when Z5      => nextState <= Z6;   index <= 3;
  		when Z6      => nextState <= Z7;
  		when Z7      => nextState <= Z8;   index <= 4;
  		when Z8      => nextState <= Z9;
  		when Z9      => nextState <= Z10;  index <= 5;
  		when Z10     => nextState <= Z11;
  		when Z11     => nextState <= Z12;  index <= 6;
  		when Z12     => nextState <= Z13;
  		when Z13     => nextState <= Z14;  index <= 7;
  		when Z14     => nextState <= Z15;
  		when Z15     => nextState <= Z0;
  		when idle    => nextState <= idle; index <= 0;
  	end case;
  end process combinational;

  output : process(currentState) is
  begin
    case currentState is
      when Z0 | Z2  | Z4  | Z6 |
           Z8 | Z10 | Z12 | Z14  => sdiReg(index) <= sdi after delay;
      when Z1 | Z3  | Z5  | Z7 |
           Z9 | Z11 | Z13 | init => sdo <= sdoReg(index) after delay;
      when Z15                   => valid <= '1' after delay;
      when idle                  => sdo <= 'Z' after delay;
                                    valid <= '0' after delay;
                                    sdiReg(portWidth-1 downto 0) <= (others=>'Z') after delay;
    end case;
  end process output;

end architecture abstract;