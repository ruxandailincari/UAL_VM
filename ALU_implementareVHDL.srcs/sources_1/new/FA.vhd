library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FA is
  Port (x: in std_logic; 
        y: in std_logic; 
        c: in std_logic; 
        s: out std_logic 
        );
end FA;

architecture Behavioral of FA is

begin

process(x,y,c)
    begin
        s <= x xor y xor c; 
end process;

end Behavioral;
