library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VM_Multiplication is
  Port ( 
         clk      : in std_logic;
         resetare : in std_logic;
         start    : in std_logic;
         x        : in std_logic_vector(31 downto 0);
         y        : in std_logic_vector(31 downto 0);
         z        : out std_logic_vector(31 downto 0);
         gata     : out std_logic 
       );
end VM_Multiplication;

architecture Behavioral of VM_Multiplication is

component Decompose_Float_Number is
  Port (
            a        : in std_logic_vector(31 downto 0);
            semn     : out std_logic;
            mantisa  : out std_logic_vector(23 downto 0);
            exponent : out std_logic_vector(7 downto 0)
        );
end component;

component Multiplier_Shift_Add is
  generic (N: integer := 24);  
      port(
        clk       : in std_logic;
        resetare  : in std_logic;
        start     : in std_logic;
        a         : in std_logic_vector(N-1 downto 0);
        b         : in std_logic_vector(N-1 downto 0);
        rezultat  : out std_logic_vector(2*N downto 0);
        gata      : out std_logic
    );
end component;

component CLA_8 is
 Port (
        cin  : in std_logic;
        x    : in std_logic_vector(7 downto 0);
        y    : in std_logic_vector(7 downto 0);
        sum  : out std_logic_vector(7 downto 0);
        cout : out std_logic 
     );
end component;

signal semn_X     : std_logic;
signal semn_Y     : std_logic;
signal mantisa_X  : std_logic_vector(23 downto 0);
signal mantisa_Y  : std_logic_vector(23 downto 0);
signal exponent_X : std_logic_vector(7 downto 0);
signal exponent_Y : std_logic_vector(7 downto 0);

signal operanzi_infinit   : std_logic := '0';
signal operand_nan        : std_logic := '0';
signal op_infinit_op_zero : std_logic := '0';
signal operand_zero       : std_logic:='0';

signal exponenti_adunati     : std_logic_vector(7 downto 0) := (others =>'0');
signal exponenti_adunati_aux : std_logic_vector(7 downto 0) := (others =>'0');
signal mantise_inmultite     : std_logic_vector(48 downto 0);

signal gata_aux  : std_logic := '0';
signal start_aux : std_logic := '0';

signal mantisa_produs        : std_logic_vector(23 downto 0);
signal suma_exponenti        : std_logic_vector(7 downto 0);
signal caracteristica_produs : std_logic_vector(7 downto 0);
signal deplasare             : std_logic_vector(7 downto 0) := "01111111";
signal semn_produs           : std_logic := '0';

signal select_z : std_logic_vector(31 downto 0);

signal overflow  : std_logic := '0';
signal underflow : std_logic := '0';

begin

d1: Decompose_Float_Number port map (x, semn_X, mantisa_X, exponent_X);
d2: Decompose_Float_Number port map (y, semn_Y, mantisa_Y, exponent_Y);

process (exponent_X, exponent_Y, mantisa_X, mantisa_Y, x, y) is
    begin
        operanzi_infinit   <= '0';
        operand_nan        <= '0';
        op_infinit_op_zero <= '0';
        
        if (exponent_X= x"80" and mantisa_X= x"800000") or (exponent_Y= x"80" and mantisa_Y= x"800000") then
            operanzi_infinit <= '1';
        end if;
        
        if (exponent_X = x"80" and mantisa_X /= x"800000") or (exponent_Y = x"80" and mantisa_Y /= x"800000") then
            operand_nan <= '1';
        end if;  
        
        if (exponent_X= x"80" and mantisa_X= x"800000" and (y=x"00000000" or y=x"80000000")) or (exponent_Y= x"80" and mantisa_Y= x"800000" and (x=x"00000000" or x=x"80000000")) then
            op_infinit_op_zero <= '1';
        end if;
end process;

process (x, y) is
    begin
        operand_zero <= '0';
        if x = x"00000000" or y = x"00000000" or x=x"80000000" or y=x"80000000" then
            operand_zero <= '1';
        end if;
end process;

start_aux <= start;
Shift_add: Multiplier_Shift_Add 
    generic map (24)
    port map(clk, resetare, start_aux, mantisa_X, mantisa_Y, mantise_inmultite, gata_aux);


add_exp: CLA_8 port map ('0', exponent_X, exponent_Y, exponenti_adunati);   
exponenti_adunati_aux <= exponenti_adunati; 

process (mantise_inmultite, exponenti_adunati_aux, gata_aux) is
    variable exponent_aux               : unsigned(7 downto 0);
    variable register_a                 : unsigned(23 downto 0);
    variable register_q                 : unsigned(23 downto 0);
    variable register_q_aux             : unsigned(23 downto 0);
    
    variable g_aux              : std_logic;
    variable r_aux              : std_logic;
    variable s_aux              : std_logic;
    variable var_round          : std_logic;
    variable var_mantisa_produs : unsigned(24 downto 0);
    
    begin
        var_mantisa_produs         := (others => '0');
        register_q                 := unsigned(mantise_inmultite(23 downto 0));
        register_q_aux             := register_q;
        register_a                 := unsigned(mantise_inmultite(47 downto 24));
        exponent_aux               := unsigned(exponenti_adunati_aux);
        g_aux                      := register_q(23);
        r_aux                      := register_q(22);
        s_aux                      := '0';
        var_round                  := '0';
        
        for i in 0 to 21 loop
            s_aux          := s_aux or register_q_aux(0);
            register_q_aux := shift_right(register_q_aux, 1);
        end loop;
        
        if gata_aux = '1' then 
            if register_a(23) = '0' then
                register_a    := shift_left(register_a, 1);
                register_a(0) := register_q(23);
                
                g_aux := r_aux;
                r_aux := register_q(21);
            else
                exponent_aux := exponent_aux + 1;
                s_aux        := s_aux or r_aux;
                r_aux        := g_aux;
                g_aux        := register_a(0);
            end if;
            
            var_mantisa_produs := '0' & register_a;
            if g_aux = '1' and r_aux = '1' then
            	var_round := '1';
            elsif g_aux = '1' and r_aux = '0' and s_aux = '1' then 
            	var_round := '1';
            elsif g_aux = '1' and r_aux = '0' and s_aux = '0' and var_mantisa_produs(0) = '1' then 
            	var_round := '1';
            else
            	var_round := '0';
            end if;
            
            if var_round = '1' then
                var_mantisa_produs := var_mantisa_produs + 1;
                if var_mantisa_produs(24) = '1' then
                    var_mantisa_produs := shift_right(var_mantisa_produs, 1);
                    exponent_aux := exponent_aux + 1;
                end if;
            end if;
            
            mantisa_produs <= std_logic_vector(var_mantisa_produs(23 downto 0));
            suma_exponenti <= std_logic_vector(exponent_aux);
            gata <= gata_aux;
        end if;
end process;

add_caracterist: CLA_8 port map('0', suma_exponenti, deplasare, caracteristica_produs);
overflow  <= '1' when unsigned(caracteristica_produs) > 254 else '0';
underflow <= '1' when unsigned(caracteristica_produs) < 1 else '0';

process (semn_X, semn_Y) is
    begin
        semn_produs <= '0';
        if semn_X = semn_Y then
            semn_produs <= '0';
        else
            semn_produs <= '1';
        end if;
end process;

process (operand_zero, operanzi_infinit, op_infinit_op_zero, operand_nan, semn_produs, caracteristica_produs, mantisa_produs, overflow, underflow) is
    begin
        if overflow = '1' then
            select_z <= semn_produs & "111" & x"F800000";
        elsif underflow = '1' then
            select_z <= semn_produs & "000" & x"0000000";
        elsif operand_nan = '1' or op_infinit_op_zero = '1' then
            select_z <= x"7F800201"; -- Nan    
        elsif operand_zero = '1' and op_infinit_op_zero = '0' and operand_nan = '0' then
            select_z <= semn_produs & "000" & x"0000000";
        elsif operanzi_infinit = '1' and op_infinit_op_zero = '0' and operand_nan = '0' then
            if semn_produs = '0' then
                select_z <= x"7F800000";
            else
                select_z <= x"FF800000";
            end if;       
        else  
            select_z <= semn_produs & caracteristica_produs & mantisa_produs(22 downto 0);
        end if;
end process;

z <= select_z;

end Behavioral;
