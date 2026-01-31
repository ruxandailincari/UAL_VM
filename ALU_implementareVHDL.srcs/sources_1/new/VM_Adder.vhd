library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VM_Adder is
  Port (
        a   : in std_logic_vector(31 downto 0);
        b   : in std_logic_vector(31 downto 0);
        sum : out std_logic_vector(31 downto 0)
         );
end VM_Adder;

architecture Behavioral of VM_Adder is

component Decompose_Float_Number is
  Port (
            a        : in std_logic_vector(31 downto 0);
            semn     : out std_logic;
            mantisa  : out std_logic_vector(23 downto 0);
            exponent : out std_logic_vector(7 downto 0);
            cout     : out std_logic
        );
end component;

component CLA_24 is
      Port (
        cin  : in std_logic;
        x    : in std_logic_vector(23 downto 0);
        y    : in std_logic_vector(23 downto 0);
        sum  : out std_logic_vector(23 downto 0);
        cout : out std_logic 
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

signal semn_A       : std_logic;
signal semn_B       : std_logic;
signal mantisa_A    : std_logic_vector(23 downto 0);
signal mantisa_B    : std_logic_vector(23 downto 0);
signal exponent_A   : std_logic_vector(7 downto 0);
signal exponent_B   : std_logic_vector(7 downto 0);
signal exponent_Max : std_logic_vector(8 downto 0);

signal mantisa_A_shifted : std_logic_vector(23 downto 0);
signal mantisa_B_shifted : std_logic_vector(23 downto 0);
signal mantisa_A_modif   : std_logic_vector(23 downto 0);
signal mantisa_B_modif   : std_logic_vector(23 downto 0);

signal mantise_adunate      : std_logic_vector(23 downto 0);
signal cout                 : std_logic;
signal mantise_adunate_cout : std_logic_vector(24 downto 0);

signal suma_normalizata        : std_logic_vector(23 downto 0);
signal exponent_normalizat     : std_logic_vector(8 downto 0);
signal caracteristica_rezultat : std_logic_vector(7 downto 0);
signal semn_rezultat           : std_logic;

signal exponent_A_extins       : std_logic_vector(8 downto 0);
signal exponent_B_extins       : std_logic_vector(8 downto 0);
signal cout_exp_A              : std_logic; 
signal cout_exp_B              : std_logic; 

signal deplasare : std_logic_vector(7 downto 0) := "01111111";
signal cin_CLA   : std_logic := '0';

signal sum_select       : std_logic_vector(31 downto 0);
signal operand_A_inf    : std_logic := '0';
signal operand_B_inf    : std_logic := '0';
signal operanzi_nan     : std_logic := '0';
signal operanzi_0       : std_logic := '0';
signal a_0              : std_logic := '0';
signal b_0              : std_logic := '0';

signal mantise_adunate_zero : std_logic := '0';

signal g  : std_logic := '0';
signal r  : std_logic := '0';
signal s  : std_logic := '0';
signal g1 : std_logic := '0';
signal r1 : std_logic := '0';
signal s1 : std_logic := '0';

signal mantisa_finala : std_logic_vector(23 downto 0);
signal exponent_final : std_logic_vector(8 downto 0);

signal overflow1  : std_logic := '0';
signal overflow2  : std_logic := '0';
signal underflow  : std_logic := '0';

begin

d1: Decompose_Float_Number port map (a, semn_A, mantisa_A, exponent_A, cout_exp_A);
d2: Decompose_Float_Number port map (b, semn_B, mantisa_B, exponent_B, cout_exp_B);
exponent_A_extins <= cout_exp_A & exponent_A;
exponent_B_extins <= cout_exp_B & exponent_B;

process(exponent_A, exponent_B, mantisa_A, mantisa_B, a, b) is
    variable mantisa_A_fractionara : unsigned(22 downto 0);
    variable mantisa_B_fractionara : unsigned (22 downto 0);
    begin
        operand_A_inf <= '0';
        operand_B_inf <= '0';
        operanzi_nan <= '0';
        operanzi_0  <= '0';
        a_0         <= '0';
        b_0         <= '0';
        mantisa_A_fractionara := unsigned(mantisa_A(22 downto 0));
        mantisa_B_fractionara := unsigned(mantisa_B(22 downto 0));
        if exponent_A = x"80" and mantisa_A_fractionara = 0 then
                operand_A_inf <= '1';
        end if;
        
        if exponent_B = x"80" and mantisa_B_fractionara = 0 then
            operand_B_inf <= '1';
        end if;
        
        if ((exponent_A = x"80") and mantisa_A_fractionara /= 0) or ((exponent_B = x"80") and mantisa_B_fractionara /= 0) then
            operanzi_nan <= '1';
        end if;
        
        if a=x"00000000" or a=x"80000000" then
            if b=x"00000000" or b=x"80000000" then
                operanzi_0 <= '1';
            else 
                a_0 <= '1';
            end if;
        else 
            if b=x"00000000" or b=x"80000000" then
                b_0 <= '1';
            end if;
        end if; 
        
end process;

process (exponent_A_extins, exponent_B_extins, mantisa_A, mantisa_B, exponent_A, exponent_B, a_0, b_0) is 
    variable diff_local    : integer; 
    variable mantisa_B_aux : unsigned(23 downto 0);
    variable mantisa_A_aux : unsigned(23 downto 0);
    variable var_g         : std_logic;
    variable var_r         : std_logic;
    variable var_s         : std_logic;
    begin
        g <= '0';
        r <= '0';
        s <= '0';
        var_g := '0';
        var_r := '0';
        var_s := '0';
        
        if(exponent_B_extins < exponent_A_extins) then
            if a_0 /= '1' and b_0 /= '1' and exponent_A /= x"80" then
                diff_local := to_integer(unsigned(exponent_A_extins) - unsigned(exponent_B_extins)); 
                if diff_local < 25 then 
                    mantisa_B_aux := shift_right(unsigned(mantisa_B), diff_local); 
                    mantisa_A_shifted <= mantisa_A;
                    exponent_Max <= exponent_A_extins;
                    mantisa_B_shifted <= std_logic_vector(mantisa_B_aux);
                    
                    if diff_local = 1 then
                        var_g := mantisa_B(0);
                    end if;
                    if diff_local = 2 then
                        var_g := mantisa_B(1);
                        var_r := mantisa_B(0);
                     end if;
                     if diff_local > 2 then
                        var_g := mantisa_B(diff_local - 1);
                        var_r := mantisa_B(diff_local - 2);
                        for i in 0 to 23 loop
                            if i < diff_local - 2 then
                                var_s := var_s or mantisa_B(i);
                            end if;
                        end loop;
                     end if;
                 else 
                    exponent_Max <= exponent_B_extins;
                    mantisa_B_shifted <= mantisa_B;
                    mantisa_A_shifted <= mantisa_A;
                 end if;
              else
                mantisa_B_shifted <= (others => '0'); 
                mantisa_A_shifted <= mantisa_A;
                exponent_Max <= exponent_A_extins; 
                var_g := '0'; 
                var_r := '0'; 
                var_s := '0'; 
                for i in 0 to 23 loop 
                    var_s := var_s or mantisa_B(i); 
                end loop;
              end if;
        else
            if a_0 /= '1' and b_0 /= '1' and exponent_B /= x"80" then
                diff_local := to_integer(unsigned(exponent_B_extins) - unsigned(exponent_A_extins)); 
                if diff_local < 25 then 
                    mantisa_A_aux := shift_right(unsigned(mantisa_A), diff_local);
                    mantisa_B_shifted <= mantisa_B;
                    mantisa_A_shifted <= std_logic_vector(mantisa_A_aux);
                    exponent_Max <= exponent_B_extins;
                    
                    if diff_local = 1 then
                        var_g := mantisa_A(0);
                    end if;
                    if diff_local = 2 then
                        var_g := mantisa_A(1);
                        var_r := mantisa_A(0);
                     end if;
                     if diff_local > 2 then
                        var_g := mantisa_A(diff_local - 1);
                        var_r := mantisa_A(diff_local - 2);
                        for i in 0 to 23 loop
                            if i < diff_local - 2 then
                                var_s := var_s or mantisa_A(i);
                            end if;
                        end loop;
                     end if;
                 else 
                    exponent_Max <= exponent_A_extins;
                    mantisa_B_shifted <= mantisa_B;
                    mantisa_A_shifted <= mantisa_A;
                 end if;
              else
                mantisa_A_shifted <= (others => '0'); 
                mantisa_B_shifted <= mantisa_B;
                exponent_Max <= exponent_B_extins; 
                var_g := '0'; 
                var_r := '0'; 
                var_s := '0'; 
                for i in 0 to 23 loop 
                    var_s := var_s or mantisa_B(i); 
                end loop;
              end if;
             
        end if;
        
        g <= var_g;
        r <= var_r;
        s <= var_s;
end process;

process(semn_A, semn_B, mantisa_A_shifted, mantisa_B_shifted) is
    variable mantisa_A_aux: unsigned(23 downto 0);
    variable mantisa_B_aux: unsigned(23 downto 0);
begin
    mantisa_A_aux := unsigned(mantisa_A_shifted);
    mantisa_B_aux := unsigned(mantisa_B_shifted);

    if semn_A = semn_B then
        cin_CLA <= '0';
        mantisa_A_modif <= std_logic_vector(mantisa_A_aux);
        mantisa_B_modif <= std_logic_vector(mantisa_B_aux);
        semn_rezultat   <= semn_A;

    else
        if mantisa_A_aux >= mantisa_B_aux then
            cin_CLA <= '1'; 
            mantisa_A_modif <= std_logic_vector(mantisa_A_aux);
            mantisa_B_modif <= std_logic_vector(not mantisa_B_aux);
            semn_rezultat   <= semn_A;
        else
            cin_CLA <= '1';
            mantisa_A_modif <= std_logic_vector(mantisa_B_aux);
            mantisa_B_modif <= std_logic_vector(not mantisa_A_aux);
            semn_rezultat   <= semn_B;
        end if;
    end if;
end process;


add_mantise: CLA_24 port map (cin_CLA, mantisa_A_modif, mantisa_B_modif, mantise_adunate, cout);
mantise_adunate_cout <= cout & mantise_adunate;


process (mantise_adunate_cout, exponent_Max, semn_A, semn_B, g, r, s) is
    variable mantisa_aux  : unsigned(24 downto 0);
    variable exponent_aux : unsigned(8 downto 0);
    variable var_g        : std_logic;
    variable var_r        : std_logic;
    variable var_s        : std_logic;
    begin
        mantisa_aux  := unsigned(mantise_adunate_cout);
        exponent_aux := unsigned(exponent_Max);
        mantise_adunate_zero <= '0';
        overflow1  <= '0';
        underflow <= '0';
        r1 <= r;
        s1 <= s;
        g1 <= g;
        var_r := r;
        var_s := s;
        var_g := g;
        
        if mantisa_aux(23 downto 0) = 0 and semn_A /= semn_B then
            mantise_adunate_zero <= '1';
         end if;
        
        if (mantisa_aux(24)='1' and semn_A = semn_B) then
            var_g := mantisa_aux(0);
            var_r := g;
            var_s := r or s;
            mantisa_aux  := shift_right(mantisa_aux, 1);
            exponent_aux := exponent_aux + 1;
            if exponent_aux = "110000000" then
                overflow1 <= '1';
            end if;
        end if;
            
        if mantisa_aux(23)='0' then
           for i in 0 to 23 loop
            if mantisa_aux(23) = '0' then
                        mantisa_aux  := shift_left(mantisa_aux, 1);
                        exponent_aux := exponent_aux - 1;
                        var_g := var_r;
                        var_r := var_s;
                        var_s := '0';
                        if exponent_aux = "010000001" then
                            underflow <= '1';
                        end if;
            else
                exit;
             end if;
        end loop;
       end if;
        
        suma_normalizata    <= std_logic_vector(mantisa_aux(23 downto 0));
        exponent_normalizat <= std_logic_vector(exponent_aux);
        g1 <= var_g;
        r1 <= var_r;
        s1 <= var_s;
end process;

process (g1, r1, s1, suma_normalizata, exponent_normalizat) is
    variable var_round          : std_logic;
    variable var_mantisa_round  : unsigned(24 downto 0);
    variable var_exponent_round : unsigned(8 downto 0);
    begin
        mantisa_finala <= suma_normalizata;
        exponent_final <= exponent_normalizat;
        overflow2 <= '0';
        var_round := '0';
        var_exponent_round := unsigned(exponent_normalizat);
        var_mantisa_round  := unsigned('0' & suma_normalizata);
        
        if g1 = '1' and r1 = '1' then
            var_round := '1';
        elsif g1 = '1' and r1 = '0' and s1 = '1' then 
            var_round := '1';
        elsif g1 = '1' and r1 = '0' and s1 = '0' and suma_normalizata(0) = '1' then 
            var_round := '1';
        else
            var_round := '0';
        end if;
        
        if var_round = '1' then
            var_mantisa_round := var_mantisa_round + 1;
            if var_mantisa_round(24) = '1' then
                var_mantisa_round := shift_right(var_mantisa_round, 1);
                var_exponent_round := var_exponent_round + 1;
                if var_exponent_round = "110000000" then
                    overflow2 <= '1';
                end if;
            end if;
        end if;
            
        exponent_final <= std_logic_vector(var_exponent_round);
        mantisa_finala <= std_logic_vector(var_mantisa_round(23 downto 0));
end process;

add_caracterist: CLA_8 port map('0', exponent_final(7 downto 0), deplasare, caracteristica_rezultat);

process(mantise_adunate_zero, semn_A, semn_B, operand_A_inf, operand_B_inf, semn_rezultat, caracteristica_rezultat, mantisa_finala, operanzi_0, a_0, b_0, operanzi_nan, overflow1, overflow2, underflow, a, b) is
    begin
        if overflow1 = '1' or overflow2 = '1' then
            sum_select <= semn_rezultat & "111" & x"F800000";
        elsif underflow = '1' then
            sum_select <= semn_rezultat & "000" & x"0000000";
        elsif operanzi_nan = '1' then
            sum_select <= x"7F800201";
        elsif operanzi_0 = '1' then
            sum_select <= x"00000000";
        elsif a_0 = '1' then
            sum_select <= b;
        elsif b_0 = '1' then
            sum_select <= a;
        elsif operand_A_inf = '1' then
            if operand_B_inf = '1' then
                if semn_A = semn_B then
                    sum_select <= a;
                else       
                    sum_select <= x"7F800201";
                end if;
            else 
                sum_select <= a;
            end if;
         elsif operand_B_inf = '1' then
            if operand_A_inf /= '1' then
                sum_select <= b;
            end if;
         elsif mantise_adunate_zero = '1' then
            sum_select <= x"00000000";
         else
            sum_select <= semn_rezultat & caracteristica_rezultat(7 downto 0) & mantisa_finala(22 downto 0);
         end if;
end process;

sum <= sum_select;
     
end Behavioral;
