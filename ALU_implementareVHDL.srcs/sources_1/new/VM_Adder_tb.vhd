library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VM_Adder_tb is
end VM_Adder_tb;

architecture sim of VM_Adder_tb is
    signal a, b, sum : std_logic_vector(31 downto 0);

begin

    test1: entity work.VM_Adder
        port map (
            a   => a,
            b   => b,
            sum => sum
        );

    process
    begin
        -- Test 1: 1.5 + 2.5 
        a <= x"3FC00000";  -- 1.5
        b <= x"40200000";  -- 2.5
        wait for 10 ns;

        assert (sum = x"40800000")
        report "1.5 + 2.5 failed!"
        severity error;
        
        
        -- Test 2: -5 + 10
        a <= x"C0A00000";  -- -5.0
        b <= x"41200000";  -- 10.0
        wait for 10 ns;
        
        assert (sum = x"40A00000")
        report "-5.0 + 10.0 failed!"
        severity error;

        -- Test 3: +inf + -inf
        a <= x"7F800000";  -- +inf
        b <= x"FF800000";  -- -inf
        wait for 10 ns;
        
        assert (sum = x"7F800201")
        report "-inf + inf failed!"
        severity error;
        
        -- Test 4: +inf + inf
        a <= x"7F800000";  -- +inf
        b <= x"7F800000";  -- +inf
        wait for 10 ns;
        assert (sum = x"7F800000")
        report "inf + inf failed!"
        severity error;
        
        -- Test 5: 1.2 + - 1.2
        a <= x"3F99999A"; -- 1.2
        b <= x"BF99999A"; -- -1.2
        wait for 10 ns;
        assert (sum = x"00000000")
        report "1.2 + -1.2 failed!"
        severity error;
        
        -- Test 6: -2.1 + -6.7
        a <= x"C0066666"; -- -2.1
        b <= x"C0D66666"; -- -6.7
        wait for 10 ns;
        assert (sum = x"C10CCCCD")
        report "-2.1 + -6.7 failed!"
        severity error;
        

        report "Simulation finished." severity note;
        wait;
    end process;
end architecture;
