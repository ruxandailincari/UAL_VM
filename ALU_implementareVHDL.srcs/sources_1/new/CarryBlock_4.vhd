library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CarryBlock_4 is
  Port ( 
        cin  : in std_logic;
        pin  : in std_logic;
        gin  : in std_logic;  
        cout : out std_logic
  );
end CarryBlock_4;

architecture Behavioral of CarryBlock_4 is

begin

cout <= gin or (pin and cin);

end Behavioral;
