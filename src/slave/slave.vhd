library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 
library WORK;
use WORK.slavePKG.all;

entity slave is
	generic (	portWidth 	: dataLength := 8
	);  	
	port ( 		sclk 		: in bit;
				ss			: in bit;
				sdi			: in bit;				
				sdo			: out bit_vector(portWidth-1 downto 0) 
	);
end entity slave;

architecture abstract of slave is 

begin
  
end architecture abstract;