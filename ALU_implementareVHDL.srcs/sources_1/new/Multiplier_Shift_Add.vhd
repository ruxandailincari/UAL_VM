library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Multiplier_Shift_Add is
    generic(N:integer:=24);
    port(
        clk: in std_logic;
        resetare: in std_logic;
        start: in std_logic;
        a: in std_logic_vector(N-1 downto 0);
        b: in std_logic_vector(N-1 downto 0);
        rezultat: out std_logic_vector(2*N downto 0); -- Rezultatul final, extins la 2*N+1 biți fiindca include si bitul de carry
        gata: out std_logic
    );
end Multiplier_Shift_Add;


architecture Behavioral of Multiplier_Shift_Add is

type stare_t is (ASTEPTARE, CALCUL, FINALIZARE); -- Definirea stărilor FSM
signal stare: stare_t; -- Starea curentă a FSM

signal produs: unsigned(2*N downto 0);
signal multiplicand: unsigned(2*N downto 0);  -- Deinmultitul extins la 2*N+1 biți
signal multiplicator: unsigned(N-1 downto 0);

signal contor: integer range 0 to N; -- Contor pentru iterații


begin

process(clk, resetare)
    begin
        if resetare = '1' then
            stare <= ASTEPTARE;
            produs <= (others => '0');
            multiplicand <= (others => '0');
            multiplicator <= (others => '0');
            contor <= 0;
            gata <= '0';
        elsif rising_edge(clk) then
            case stare is
                when ASTEPTARE =>
                    if start = '1' then
                        stare <= CALCUL;
                        produs <= (others => '0');
                        multiplicator <= unsigned(b); -- convertim multiplicatorul la formatul unsigned
                        contor <= 0;
                        gata <= '0'; -- resetam semnalul de finalizare
                        multiplicand <= '0' & resize(unsigned(a), 2*N); -- Extindem multiplicandul la 2*N+1 biți și adăugăm un bit de carry
                    end if;
                    
                when CALCUL =>
                    if (multiplicator(0) = '1') then
                        produs <= ('0' & produs(2*N-1 downto 0)) + multiplicand;
                    end if;
                    
                    multiplicand <= shift_left(multiplicand, 1);
                    multiplicator <= shift_right(multiplicator, 1);
                    
                    contor <= contor+1;
                    
                    if contor = N-1 then
                        stare <= FINALIZARE;
                    end if;
                    
                when FINALIZARE =>
                    rezultat <= std_logic_vector(produs);
                    gata <= '1';
                    stare <= ASTEPTARE;
            end case;
        end if;
end process;

end Behavioral;