library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CLA_4 is
  Port (
           cin  : in std_logic;
           x    : in std_logic_vector(3 downto 0);
           y    : in std_logic_vector(3 downto 0);
           sum  : out std_logic_vector(3 downto 0);
           pout : out std_logic;
           gout : out std_logic
     );
end CLA_4;

architecture Behavioral of CLA_4 is

component FA is
Port(
    x: in std_logic; 
    y: in std_logic; 
    c: in std_logic;
    s: out std_logic 
);
end component;

component CarryBlock is
Generic(data_width:integer:=4);
  Port (
        c0 : in std_logic; 
        x  : in std_logic_vector(data_width-1 downto 0); 
        y  : in std_logic_vector(data_width-1 downto 0); 
        c  : out std_logic 
        );
end component;

signal c1,c2,c3,c4 : std_logic := '0';
signal s1,s2,s3,s0 : std_logic := '0';

begin

bit0FA: FA port map(x(0), y(0), cin, s0); 
bit1FA: FA port map(x(1), y(1), c1, s1);  
bit2FA: FA port map(x(2), y(2), c2, s2); 
bit3FA: FA port map(x(3), y(3), c3, s3); 


bit0CarryBlock: CarryBlock generic map(1) port map(cin, x(0 downto 0), y(0 downto 0), c1);
bit1CarryBlock: CarryBlock generic map(2) port map(c1, x(1 downto 0), y(1 downto 0), c2);
bit2CarryBlock: CarryBlock generic map(3) port map(c2, x(2 downto 0), y(2 downto 0), c3);
bit3CarryBlock: CarryBlock generic map(4) port map(c3, x(3 downto 0), y(3 downto 0), c4);


sum(0) <= s0;
sum(1) <= s1;
sum(2) <= s2;
sum(3) <= s3;

pout <= (x(3) xor y(3)) and (x(2) xor y(2)) and (x(1) xor y(1)) and (x(0) xor y(0));
gout <= (x(3) and y(3)) or ((x(3) xor y(3)) and (x(2) and y(2))) or ((x(3) xor y(3)) and (x(2) xor y(2)) and (x(1) and y(1))) or ((x(3) xor y(3)) and (x(2) xor y(2)) and (x(1) xor y(1)) and (x(0) and y(0)));
end Behavioral;
