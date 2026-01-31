----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/19/2025 12:39:08 AM
-- Design Name: 
-- Module Name: VM_Multiplication_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VM_Multiplication_tb is
end VM_Multiplication_tb;

architecture sim of VM_Multiplication_tb is
    signal clk: std_logic := '0';
    signal resetare: std_logic := '1';
    signal gata: std_logic := '0';
    signal start: std_logic := '0';
    signal x, y, z: std_logic_vector(31 downto 0);

begin

    clk <= not clk after 5 ns;
    
    test1: entity work.VM_Multiplication 
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
    
    -- Test 1: 0 * 2.5 
        x <= x"00000000";  -- 0
        y <= x"40200000";  -- 2.5
        
        start <= '1';
        wait until clk'event and clk = '1';
        start <= '0';
        
        wait until gata = '1';
        wait for 10 ns;

        assert (z = x"00000000")
        report "0 * 2.5 failed!"
        severity error;
        
        
       -- Test 2: -5.0 * 10.0
        x <= x"C0A00000";  -- -5.0
        y <= x"41200000";  -- 10.0
    
        start <= '1';
        wait until clk'event and clk = '1';
        start <= '0';
    
        wait until gata = '1';
        wait for 10 ns;
    
        assert (z = x"C2480000")
        report "-5.0 * 10.0 failed!"
        severity error;
        
        -- Test 3: +inf * 1.5
        x <= x"7F800000"; -- +inf
        y <= x"3FC00000";  -- 1.5
        
        start <= '1';
        wait until clk'event and clk = '1';
        start <= '0';
        
        wait until gata = '1';
        wait for 10 ns;

        assert (z = x"7F800000") -- +inf
        report "+inf * 1.5 failed!"
        severity error; 
        
        
    report "Simulation finished." severity note;
    wait;
   end process;
end architecture;
