library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.slavePackage.all;
use work.testbenchPackage.all;


entity coupledRTL is
    generic (periodeHalbe : time := 20 ns; used : usecase := eightBytes);
end entity coupledRTL;


architecture  testbench of coupledRTL is
    -----------------------------------------------------------------------------------------------
    -- Der Slave als Register Transfer Modell
    -----------------------------------------------------------------------------------------------
    component registerTransferLVL is
        generic (portWidth  : dataLength := 8;
            cpol            : clockPolarity := idleLow;
            cpha            : clockPhase := firstEdge
        );
        port (sclk, ss, sdi : in  std_logic;
            sdo, valid      : out std_logic;
            sdoReg          : in  std_logic_vector(portWidth-1 downto 0);
            sdiReg          : out std_logic_vector(portWidth-1 downto 0)
        );
    end component registerTransferLVL;
    -----------------------------------------------------------------------------------------------
    -- Sowie der Master als RTL Modell
    -----------------------------------------------------------------------------------------------
    component SPIMaster is
        port(miso           : in std_logic;
             mosi           : out std_logic;
             sck            : out std_logic;
             ss             : out std_logic;
             clk            : in std_logic;
             tx             : in std_logic_vector(7 downto 0);
             rx             : out std_logic_vector(7 downto 0);
             txWr           : in std_logic;
             sr             : out std_logic_vector(7 downto 0);
             ccr            : in std_logic_vector(15 downto 0);
             ccrWr          : in std_logic;
             cr             : in std_logic_vector(7 downto 0);
             crWr           : in std_logic
        );
    end component SPIMaster;
    -----------------------------------------------------------------------------------------------
    -- interne Signale der Testbench
    -----------------------------------------------------------------------------------------------
    signal sigMiso, sigMosi, sigSck, sigSs, sigClk, sigTxWr, sigCcrWr, sigCrWr, sigValid : std_logic;
    signal sigTx, sigRx, sigSr, sigCr, sigSdiReg : std_logic_vector(dataLength'high-1 downto 0);
    signal sigCcr : std_logic_vector(2*dataLength'high-1 downto 0);
    
begin
    clock : process is
    begin
        sigClk <= '0'; wait for periodeHalbe;
        sigClk <= '1'; wait for periodeHalbe;
    end process clock;
    
    config : process
    begin
        sigCcr <= std_logic_vector(to_unsigned(23, 16));
        sigCcrWr <= '1';
        sigCr <= (0 => '1', others => '0');
        sigCrWr <= '1';
        wait until sigClk = '1' and sigClk'event;
        sigCcrWr <= '0';
        sigCrWr <= '0';
        wait until sigSr(1) = '1';
        sigTx <= X"AB";
        sigTxWr <= '1';
    end process config;
    
    
    -----------------------------------------------------------------------------------------------
    -- Instanzierung der verwendeten Komponente
    -----------------------------------------------------------------------------------------------
    slave:
    entity work.registerTransferLVL(mooreFSM)
    generic map(8, idleHigh, firstEdge)
    port map(sigSck, sigSs, sigMosi, sigMiso, sigValid, sigTx, sigSdiReg);

    master:
    entity work.SPImaster(behavioral)
    port map (sigMiso, sigMosi, sigSck, sigSs, sigClk, sigTx, sigRx, sigTxWr, sigSr, sigCcr, sigCcrWr, sigCr, sigCrWr);

end architecture  testbench;
