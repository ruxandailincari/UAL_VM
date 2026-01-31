----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/07/2025 10:47:01 PM
-- Design Name: 
-- Module Name: top_module - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_module is
  Port (
        clk   : in std_logic;
        resetare : in std_logic;
        start : in std_logic;
        x     : in std_logic_vector(31 downto 0);
        y     : in std_logic_vector(31 downto 0);
        op    : in std_logic_vector(1 downto 0);
        z     : out std_logic_vector(31 downto 0);
        gata  : out std_logic
   );
end top_module;

architecture Behavioral of top_module is

component VM_Adder is
  Port (
        a   : in std_logic_vector(31 downto 0);
        b   : in std_logic_vector(31 downto 0);
        sum : out std_logic_vector(31 downto 0)
        );
end component;

component VM_Substract is
Port (
        a   : in std_logic_vector(31 downto 0);
        b   : in std_logic_vector(31 downto 0);
        sum : out std_logic_vector(31 downto 0)
         );
end component;

component VM_Multiplication is
  Port ( 
         clk   : in std_logic;
         resetare : in std_logic;
         start : in std_logic;
         x     : in std_logic_vector(31 downto 0);
         y     : in std_logic_vector(31 downto 0);
         z     : out std_logic_vector(31 downto 0);
         gata  : out std_logic 
       );
end component;

component VM_Division is
  Port (
         clk   : in std_logic;
         resetare : in std_logic;
         start : in std_logic;
         x     : in std_logic_vector(31 downto 0);
         y     : in std_logic_vector(31 downto 0);
         z     : out std_logic_vector(31 downto 0);
         gata  : out std_logic 
   );
end component;

signal z_sum, z_sub, z_mul, z_div : std_logic_vector(31 downto 0);
signal gata_mul, gata_div : std_logic;

begin

adder       : VM_Adder port map(x, y, z_sum);
substracter : VM_Substract port map(x, y, z_sub);
divider     : VM_Division port map (clk, resetare, start, x, y, z_div, gata_div);
multiplier  : VM_Multiplication port map (clk, resetare, start, x, y, z_mul, gata_mul);

process(op, z_sum, z_sub, z_mul, z_div, gata_mul, gata_div) is
    begin
        case op is
            when "00" => 
                z <= z_sum;
                gata <= '1';
            when "01" =>
                z <= z_sub;
                gata <= '1';
            when "10" =>
                z <= z_mul;
                gata <= gata_mul;
            when others =>
                z <= z_div;
                gata <= gata_div;
        end case;
end process;


end Behavioral;
