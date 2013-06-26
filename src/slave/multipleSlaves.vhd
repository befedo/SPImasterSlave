--------------------------------------------------------------------------------
-- Entity            : fourSlaves
--------------------------------------------------------------------------------
-- Copyright         : 2013
-- Filename          : multipleSlaves.vhd
-- Creation date     : 24.06.2013
-- Author(s)         : Marc Ludwig <marc.ludwig@stud.fh-jena.de>
-- Version           : 1.00
-- Description       : Top Entity zum SPI-Slave Projekt, mit vier Slaves.
--------------------------------------------------------------------------------
-- File History:
-- Date                            | Version | Author    | Comment
-- Wed Jun 19 14:56:09 2013 +0200  | 1.00    | Ludwig    | Initial Commit
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all; 
library work;
use work.slavePackage.all;
--------------------------------------------------------------------------------
entity multipleSlaves is
    generic( count          : integer := 4 );
    port(    clk, sclk, sdi : in  std_logic;
             sdo            : out std_logic;
             slaveSelect    : in std_logic_vector(count-1 downto 0);
             sdoPort        : in std_logic_vector(dataLength'high-1 downto 0);
             HEX0       : out std_logic_vector(6 downto 0);
             HEX1       : out std_logic_vector(6 downto 0);
             HEX2       : out std_logic_vector(6 downto 0);
             HEX3       : out std_logic_vector(6 downto 0);
             HEX4       : out std_logic_vector(6 downto 0);
             HEX5       : out std_logic_vector(6 downto 0);
             HEX6       : out std_logic_vector(6 downto 0);
             HEX7       : out std_logic_vector(6 downto 0)
    );
end entity multipleSlaves;
--------------------------------------------------------------------------------
architecture  bcdDataOut of multipleSlaves is 
---------------------------- Slave als RTL-Component ---------------------------
component registerTransferLVL is
  generic (portWidth         : dataLength := 8;
           cpol              : clockPolarity := idleLow;
           cpha              : clockPhase := firstEdge
    );      
    port (clk, sclk, ss, sdi : in  std_logic;
          sdo, valid         : out std_logic;
          sdoReg             : in  std_logic_vector(portWidth-1 downto 0);
          sdiReg             : out std_logic_vector(portWidth-1 downto 0) 
    );
end component registerTransferLVL;
---------------------------- Siebensegmentanzeige ------------------------------
component sevenseg is
    port (
        clk, reset : in  std_logic;
        datain     : in  std_logic_vector(3 downto 0);
        dataout    : out std_logic_vector(6 downto 0)
    );
end component sevenseg;
---------------------------- Signal-/ Typdefinitionen --------------------------------
type   dataArray is array (count-1 downto 0) of std_logic_vector(dataLength'high-1 downto 0);
type   bcdArray is array (dataLength'high-1 downto 0) of std_logic_vector(6 downto 0);
signal sigClk, sigSclk, sigSdi, sigSdo  : std_logic;
signal sigSlaveSelect, sigValid : std_logic_vector(count-1 downto 0);
signal sigSdoPort               : std_logic_vector(dataLength'high-1 downto 0);
signal sigData                  : dataArray;
signal sigBCD                   : bcdArray;
--------------------------------------------------------------------------------
begin
    sigSclk        <= sclk;
    sigClk         <= clk;
    sigSdi         <= sdi;
    sdo            <= sigSdo;
    sigSlaveSelect <= slaveSelect;
    sigSdoPort     <= sdoPort;
    HEX0       <= sigBCD(0);
    HEX1       <= sigBCD(1);
    HEX2       <= sigBCD(2);
    HEX3       <= sigBCD(3);
    HEX4       <= sigBCD(4);
    HEX5       <= sigBCD(5);
    HEX6       <= sigBCD(6);
    HEX7       <= sigBCD(7);
    
    genSlaves : for index in 0 to count-1 generate
        slave : entity work.registerTransferLVL
            generic map(
                dataLength'high, idleLow, firstEdge
            )
            port map(
                sigClk, sigSclk, sigSlaveSelect(index), sigSdi, sigSdo, sigValid(index), sigSdoPort, sigData(index)(dataLength'high-1 downto 0)
            );
    end generate genSlaves;
    
    genSevenseg : for index in 0 to dataLength'high-1 generate
        sevenseg : entity work.sevenseg
            port map(
                sigValid(index/2), '0', sigData(index/2)((index mod 2)*4+3 downto (index mod 2)*4), sigBCD(index)(6 downto 0)
            );
    end generate genSevenseg;
    
end architecture  bcdDataOut;
--------------------------------------------------------------------------------
--configuration config of fourSlaves is
--    for bcdDataOut
--        for all : sevenseg 
--            use entity work.sevenseg(verhalten);
--        end for;
--        for all : registerTransferLVL 
--            use entity work.registerTransferLVL(mooreFSM);
--        end for;
--    end for;
--end configuration config;