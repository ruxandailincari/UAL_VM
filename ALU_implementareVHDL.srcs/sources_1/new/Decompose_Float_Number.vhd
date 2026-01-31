library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Decompose_Float_Number is
  Port (
            a        : in std_logic_vector(31 downto 0);
            semn     : out std_logic;
            mantisa  : out std_logic_vector(23 downto 0);
            exponent : out std_logic_vector(7 downto 0);
            cout     : out std_logic
        );
end Decompose_Float_Number;

architecture Behavioral of Decompose_Float_Number is

component CLA_8 is
     Port (
        cin  : in std_logic;
        x    : in std_logic_vector(7 downto 0);
        y    : in std_logic_vector(7 downto 0);
        sum  : out std_logic_vector(7 downto 0);
        cout : out std_logic 
     );
end component;

signal caracteristica : std_logic_vector(7 downto 0) := (others=>'0');
signal deplasare      : std_logic_vector(7 downto 0) := "01111111";
signal deplasare_neg  : std_logic_vector(7 downto 0);
signal cout_sig           : std_logic;

signal exp_raw : std_logic_vector(7 downto 0);
constant bias  : signed(7 downto 0) := to_signed(127, 8);

begin

semn <= a(31);
caracteristica <= a(30 downto 23);
mantisa <= '1' & a(22 downto 0);
deplasare_neg <= not deplasare;

calc_exp: CLA_8 port map ('1', caracteristica, deplasare_neg, exp_raw, cout_sig);

exponent <= exp_raw;
cout <= cout_sig;

end Behavioral;
