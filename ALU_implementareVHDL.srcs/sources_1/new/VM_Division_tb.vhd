library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VM_Division_tb is
end VM_Division_tb;

architecture sim of VM_Division_tb is

 signal clk: std_logic := '0';
 signal resetare: std_logic := '1';
 signal gata: std_logic := '0';
 signal start: std_logic := '0';
 signal x, y, z: std_logic_vector(31 downto 0);

begin

clk <= not clk after 5 ns;
    
    test1: entity work.VM_Division
    port map (
            clk => clk,
            resetare => resetare,
            start => start,
            x => x,
            y => y,
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
    
    -- Test 1: (-3.0) / (6.0) 
    x <= x"C0400000";  -- -3.0
    y <= x"40C00000";  -- 6.0
        
    start <= '1';
    wait until clk'event and clk = '1';
    start <= '0';
        
    wait until gata = '1';
    wait for 10 ns;

    assert (z = x"BF000000")
    report "-3.0 / 6.0 failed!"
    severity error;
    
    report "Simulation finished." severity note;
    wait;

end process;


end sim;
