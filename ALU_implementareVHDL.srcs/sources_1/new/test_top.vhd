
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_top is
--  Port ( );
end test_top;

architecture Behavioral of test_top is

    signal clk: std_logic := '0';
    signal gata: std_logic := '0';
    signal start: std_logic := '0';
    signal x, y, z: std_logic_vector(31 downto 0);
    signal op: std_logic_vector(1 downto 0);
    signal resetare : std_logic:='0';

begin

clk <= not clk after 5 ns;
    
    test1: entity work.top_module
        port map (
            clk => clk,
            resetare => resetare,
            start => start,
            x => x,
            y => y,
            op => op,
            z => z,
            gata => gata
        );

process 
    begin
    resetare <= '1';
    start <= '0';
    wait for 20 ns;

    resetare <= '0';
    wait for 20 ns;
    
        -- Test 1: -2.0, 9.0
        x <= x"C0000000";  -- 6.0
        y <= x"41100000";  -- -3.0
        op <= "00";
        
        start <= '1';
        wait until clk'event and clk = '1';
        start <= '0';
        
        wait until gata = '1';
        wait for 10 ns;

        assert (z = x"40E00000")
        report "-2.0 + 9.0 failed!"
        severity error;
        
        report "Simulation finished successfully."
        severity note;
end process;

end Behavioral;
