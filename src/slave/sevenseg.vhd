--------------------------------------------------------------------------------
-- Entity            : sevensegcounter
--------------------------------------------------------------------------------
-- Copyright         : 2012
-- Filename          : sevensegcounter.vhd
-- Creation date     : 2012-04-24
-- Author(s)         : Befedo
-- Version           : 1.00
-- Description       : Ein Zaehler, der den Takt Zaehlt und 7-Segment kodiert
--                     ausgibt ein Ueberlauf kann festgelegt werden (generic)
--                     welcher zur Verkettung von mehreren Zählern dient. 
--------------------------------------------------------------------------------
-- File History:
-- Date        | Version | Author    | Comment
-- 2012-04-24  | 1.00    | Ludwig    | Datei erstellt
-- 2012-04-25  | 1.01    | Ludwig    | Temp variable in natural realisiert und
--             |         |           | Mehrfachzuweisung (Treiber) behoben.
-- 2012-05-02  | 1.02    | Ludwig    | IF-THEN-ELSE Konstrukt reorganisiert,
--                                     um Ausgangskonflikte zu beheben.
--                                     Bei einem Overflow wird nun die Anzeige
--                                     einen ganzen Takt auf NULL gesetzt. 
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--------------------------------------------------------------------------------
entity sevenseg is
	port (
		clk 			 : in  std_logic;
		datain     : in  std_logic_vector(3 downto 0);
		dataout    : out std_logic_vector(6 downto 0)
	);
end sevenseg;
--------------------------------------------------------------------------------
architecture verhalten of sevenseg is

signal temp : natural range 0 to 15 := 0;

begin


count:process(clk)
begin
	if (clk = '1' and clk'event) then
  	temp <= conv_integer(unsigned(datain));
  end if;
end process count;


convert:process(temp)

variable sevenseg : std_logic_vector(7 downto 0);

begin

    case temp is
        when 0  =>  sevenseg     := X"3F";           
        when 1  =>  sevenseg     := X"06";        
        when 2  =>  sevenseg     := X"5B";        
        when 3  =>  sevenseg     := X"4F";        
        when 4  =>  sevenseg     := X"66";        
        when 5  =>  sevenseg     := X"6D";        
        when 6  =>  sevenseg     := X"7D";        
        when 7  =>  sevenseg     := X"07";        
        when 8  =>  sevenseg     := X"7F";        
        when 9  =>  sevenseg     := X"6F";        
        when 10 =>  sevenseg     := X"77";              -- ab hier Pseudotetraden
        when 11 =>  sevenseg     := X"7C";              -- in HEX kodiert A...F
        when 12 =>  sevenseg     := X"39";        
        when 13 =>  sevenseg     := X"5E";        
        when 14 =>  sevenseg     := X"79";        
        when 15 =>  sevenseg     := X"71";            
        when others => sevenseg  := (others => 'Z');    -- FEHLER! Sollte nie auftreten        
    end case;

dataout <= not sevenseg(6 downto 0);                    -- negierte Logik, da Segmente LOW aktiv
        
end process convert;


end verhalten;