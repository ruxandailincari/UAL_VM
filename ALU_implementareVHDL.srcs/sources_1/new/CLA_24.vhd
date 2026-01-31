library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CLA_24 is
  Port (
        cin  : in std_logic;
        x    : in std_logic_vector(23 downto 0);
        y    : in std_logic_vector(23 downto 0);
        sum  : out std_logic_vector(23 downto 0);
        cout : out std_logic 
     );
end CLA_24;

architecture Behavioral of CLA_24 is

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

signal s: std_logic_vector(23 downto 0);

signal p1,p2,p3,p4,p5, p6     : std_logic;
signal g1, g2, g3, g4, g5, g6 : std_logic;
signal c1, c2, c3, c4, c5, c6 : std_logic;

begin
carry1: CarryBlock_4 port map(cin, p1, g1, c1);
carry2: CarryBlock_4 port map(c1, p2, g2, c2);
carry3: CarryBlock_4 port map(c2, p3, g3, c3);
carry4: CarryBlock_4 port map(c3, p4, g4, c4);
carry5: CarryBlock_4 port map(c4, p5, g5, c5);
carry6: CarryBlock_4 port map(c5, p6, g6, c6);


add1: CLA_4 port map (cin, x(3 downto 0), y(3 downto 0), s(3 downto 0), p1, g1);
add2: CLA_4 port map (c1, x(7 downto 4), y(7 downto 4), s(7 downto 4), p2, g2);
add3: CLA_4 port map (c2, x(11 downto 8), y(11 downto 8), s(11 downto 8), p3, g3);
add4: CLA_4 port map (c3, x(15 downto 12), y(15 downto 12), s(15 downto 12), p4, g4);
add5: CLA_4 port map (c4, x(19 downto 16), y(19 downto 16), s(19 downto 16), p5, g5);
add6: CLA_4 port map (c5, x(23 downto 20), y(23 downto 20), s(23 downto 20), p6, g6);

sum  <= s;
cout <= c6;

end Behavioral;
