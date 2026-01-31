library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CLA_8 is
  Port (
        cin  : in std_logic;
        x    : in std_logic_vector(7 downto 0);
        y    : in std_logic_vector(7 downto 0);
        sum  : out std_logic_vector(7 downto 0);
        cout : out std_logic 
     );
end CLA_8;

architecture Behavioral of CLA_8 is

component CLA_4 is
      Port (
           cin  : in std_logic;
           x    : in std_logic_vector(3 downto 0);
           y    : in std_logic_vector(3 downto 0);
           sum  : out std_logic_vector(3 downto 0);
           pout : out std_logic;
           gout : out std_logic
     );
end component;

component CarryBlock_4 is
  Port ( 
        cin  : in std_logic;
        pin  : in std_logic;
        gin  : in std_logic;  
        cout : out std_logic
  );
end component;

signal s: std_logic_vector(7 downto 0);

signal p1, p2 : std_logic;
signal g1, g2 : std_logic;
signal c1, c2  :std_logic;

begin
carry1: CarryBlock_4 port map(cin, p1, g1, c1);
carry2: CarryBlock_4 port map(c1, p2, g2, c2);

add1: CLA_4 port map(cin, x(3 downto 0), y(3 downto 0), s(3 downto 0), p1, g1);
add2: CLA_4 port map(c1, x(7 downto 4), y(7 downto 4), s(7 downto 4), p2, g2);

sum  <= s;
cout <= c2;

end Behavioral;
