library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VM_Division is
  Port (
         clk      : in std_logic;
         resetare : in std_logic;
         start    : in std_logic;
         x        : in std_logic_vector(31 downto 0);
         y        : in std_logic_vector(31 downto 0);
         z        : out std_logic_vector(31 downto 0);
         gata     : out std_logic 
   );
end VM_Division;

architecture Behavioral of VM_Division is

component Decompose_Float_Number is
  Port (
            a        : in std_logic_vector(31 downto 0);
            semn     : out std_logic;
            mantisa  : out std_logic_vector(23 downto 0);
            exponent : out std_logic_vector(7 downto 0)
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

component Restoring_Division is
    generic (
        N : integer := 55
    );
    port (
        clk        : in  std_logic;
        resetare   : in  std_logic;
        start      : in  std_logic;
        dividend   : in  std_logic_vector(N-1 downto 0);
        divisor    : in  std_logic_vector(N-1 downto 0);
        quotient   : out std_logic_vector(N-1 downto 0);
        remainder  : out std_logic_vector(N downto 0);
        gata       : out std_logic
   );
end component;

signal semn_X         : std_logic;
signal semn_Y         : std_logic;
signal mantisa_X      : std_logic_vector(23 downto 0);
signal mantisa_Y      : std_logic_vector(23 downto 0);
signal exponent_X     : std_logic_vector(7 downto 0);
signal exponent_Y     : std_logic_vector(7 downto 0);
signal exponent_Y_aux : std_logic_vector(7 downto 0);

signal dif_exponenti     : std_logic_vector(7 downto 0) := (others =>'0');
signal dif_exponenti_aux : std_logic_vector(7 downto 0) := (others => '0'); 

signal deimpartit_zero   : std_logic:='0';
signal impartitor_zero   : std_logic:='0';
signal impartire_0_la_0  : std_logic:='0';
signal deimp_0_imp_inf   : std_logic:='0';
signal deimp_inf_imp_inf : std_logic:='0';
signal deimp_n_imp_inf   : std_logic:='0';
signal operanzi_nan      : std_logic:='0';
signal deimp_inf_imp_n   : std_logic:='0';

signal mantise_impartite_cat  : std_logic_vector(54 downto 0);
signal mantise_impartite_rest : std_logic_vector(55 downto 0);
signal gata_aux               : std_logic := '0';
signal start_aux              : std_logic := '0';

signal exponent_z          : std_logic_vector(7 downto 0) := (others => '0');
signal mantisa_normalizata : std_logic_vector(22 downto 0);
signal caracteristica_z    : std_logic_vector(7 downto 0);
signal deplasare           : std_logic_vector(7 downto 0) := "01111111";

signal select_z : std_logic_vector(31 downto 0);

signal mantisa_X_extinsa      : std_logic_vector(54 downto 0);
signal mantisa_Y_extinsa      : std_logic_vector(54 downto 0);

signal overflow  : std_logic := '0';
signal underflow : std_logic := '0';

begin

process (x, y) is
    begin
        deimpartit_zero  <= '0';
        impartitor_zero  <= '0';
        impartire_0_la_0 <= '0';
        if x = x"00000000" or x = x"80000000" then
            if y = x"00000000" or y = x"80000000" then
                impartire_0_la_0 <= '1';
            else 
                deimpartit_zero  <= '1';
            end if;
        end if;
        
        if y = x"00000000" or y = x"80000000"then
            impartitor_zero <= '1';
        end if;  
end process;

d1: Decompose_Float_Number port map (x, semn_X, mantisa_X, exponent_X);
d2: Decompose_Float_Number port map (y, semn_Y, mantisa_Y, exponent_Y);

process(x, y, mantisa_X, mantisa_Y, exponent_X, exponent_Y) is
    begin
        deimp_0_imp_inf   <= '0';
        deimp_inf_imp_inf <= '0';
        deimp_n_imp_inf   <= '0';
        operanzi_nan      <= '0';
        deimp_inf_imp_n   <= '0';
        if exponent_Y = x"80" and mantisa_Y = x"800000" then
            if x = x"00000000" or x = x"80000000" then
                deimp_0_imp_inf   <= '1';
            elsif exponent_X = x"80" and mantisa_X = x"800000" then
                deimp_inf_imp_inf <= '1';
            else
                deimp_n_imp_inf   <= '1';
            end if;
        end if;
        
        if exponent_X = x"80" and mantisa_X = x"800000" then
            if  y = x"00000000" or y = x"80000000" then 
                operanzi_nan <= '1';
            elsif exponent_Y = x"80" and mantisa_Y = x"800000" then
            else
                deimp_inf_imp_n   <= '1';
            end if;
        end if;
        
        if (exponent_X = x"80" and mantisa_X /= x"800000") or (exponent_Y = x"80" and mantisa_Y /= x"800000") then
            operanzi_nan <= '1';
        end if;
end process;

exponent_Y_aux <= not exponent_Y;
sub_exp: CLA_8 port map ('1', exponent_X, exponent_Y_aux, dif_exponenti);   
dif_exponenti_aux <= dif_exponenti; 

start_aux <= start;
mantisa_X_extinsa <= mantisa_X & (30 downto 0 => '0');
mantisa_Y_extinsa <= (54 downto 24 => '0') & mantisa_Y;
impartire_mantise: Restoring_Division 
    generic map(55)
    port map(clk, resetare, start_aux, mantisa_X_extinsa, mantisa_Y_extinsa, mantise_impartite_cat, mantise_impartite_rest, gata_aux);
    
process(mantise_impartite_cat, dif_exponenti_aux, gata_aux) is
    variable mantisa_aux  : unsigned(24 downto 0);
    variable exponent_aux : unsigned(7 downto 0);
    variable var_g : std_logic;
    variable var_r : std_logic;
    variable var_s : std_logic;
    variable var_round : std_logic;
    begin
        mantisa_aux  := unsigned('0' & mantise_impartite_cat(31 downto 8));
        exponent_aux := unsigned(dif_exponenti_aux);
        var_round := '0';
        var_g := mantise_impartite_cat(7);
        var_r := mantise_impartite_cat(6);
        var_s := '0';
        for i in 0 to 5 loop
            var_s := var_s or mantise_impartite_cat(i);
        end loop;
        
        if gata_aux = '1' then
           if mantisa_aux(23)='0' then
            for i in 0 to 23 loop
                if mantisa_aux(23) = '0' then
                        mantisa_aux  := shift_left(mantisa_aux, 1);
                        exponent_aux := exponent_aux - 1;
                        var_g := var_r;
                        var_r := var_s;
                        var_s := '0';
                else
                    exit;
                end if;
            end loop;
           end if;
           
           if var_g = '1' and var_r = '1' then
                var_round := '1';
           elsif var_g = '1' and var_r = '0' and var_s = '1' then 
                var_round := '1';
           elsif var_g = '1' and var_r = '0' and var_s = '0' and mantisa_aux(0) = '1' then 
            var_round := '1';
           else
            var_round := '0';
           end if;
           
           if var_round = '1' then
            mantisa_aux := mantisa_aux + 1;
            if mantisa_aux(24) = '1' then
                mantisa_aux := shift_right(mantisa_aux, 1);
                exponent_aux := exponent_aux + 1;
            end if;
            end if;
       
           exponent_z <= std_logic_vector(exponent_aux);
           gata <= gata_aux;
           mantisa_normalizata <= std_logic_vector(mantisa_aux(22 downto 0));
       end if;
end process;

add_caracterist: CLA_8 port map('0', exponent_z, deplasare, caracteristica_z);
overflow  <= '1' when unsigned(caracteristica_z) > 254 else '0';
underflow <= '1' when unsigned(caracteristica_z) < 1 else '0';

process (deimpartit_zero, impartitor_zero, impartire_0_la_0, deimp_0_imp_inf, deimp_inf_imp_inf, deimp_n_imp_inf, semn_X, semn_Y, caracteristica_z, mantisa_normalizata, operanzi_nan, deimp_inf_imp_n, overflow, underflow) is
    begin
        if overflow = '1' then
            select_z <= (semn_X xor semn_Y) & "111" & x"F800000";
        elsif underflow = '1' then
            select_z <= (semn_X xor semn_Y) & "000" & x"0000000";
        elsif impartire_0_la_0 = '1' or deimp_0_imp_inf = '1' or deimp_inf_imp_inf = '1' or operanzi_nan = '1' then
            select_z <= x"7F800201"; -- Nan
        elsif (deimpartit_zero = '1' or deimp_n_imp_inf = '1') and deimp_0_imp_inf = '0' then
            select_z <= (semn_X xor semn_Y) & "000" & x"0000000";
        elsif impartitor_zero = '1' then
            if semn_X = '0' then
                select_z <= x"7F800000";        
            else 
                 select_z <= x"FF800000";
            end if;    
        elsif deimp_inf_imp_n = '1' then
            select_z <= (semn_X xor semn_Y) &"111" & x"F800000";
        else  
            select_z <= (semn_X xor semn_Y) & caracteristica_z & mantisa_normalizata(22 downto 0);
        end if;
end process;

z <= select_z;

end Behavioral;
