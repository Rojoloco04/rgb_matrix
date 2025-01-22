library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hub75 is
    Port ( r1, g1, b1: out STD_LOGIC;
           r2, g2, b2: out STD_LOGIC;
           oe : out STD_LOGIC;
           sw: in STD_LOGIC_VECTOR(15 downto 0);
           address : out STD_LOGIC_VECTOR(3 downto 0);
           clk_in : in STD_LOGIC;
           SCLK : out STD_LOGIC;
           lat : out STD_LOGIC);
end hub75;

architecture Behavioral of hub75 is

component clk_wiz_0
port ( clk_out1: out std_logic;
       clk_in1: in std_logic);
end component;

signal clk: std_logic;
signal row1: integer range 0 to 15 := 0;
signal row2: integer range 16 to 31 := 16;
signal state: integer range 0 to 37 := 0;
signal rgb1: std_logic_vector(2 downto 0);
signal rgb2: std_logic_vector(2 downto 0);
signal x, y: integer range 0 to 37 := 0;
signal increment: integer range 5 to 100 := 50;

begin

clock_divider : clk_wiz_0
   port map (clk_out1 => clk, clk_in1 => clk_in);
   
(r1, g1, b1) <= rgb1;
(r2, g2, b2) <= rgb2;

process(clk)
variable cnt : integer range 4000000 downto 0 := 0;
variable term : integer range 0 to 3276800;
begin
    if rising_edge(clk) then
        term := to_integer(unsigned(sw))*100;
        cnt := cnt + 1;
        if cnt >= term then
            cnt := 0;
            x <= x + 1;
            if x = 31 then
                x <= 0;
                y <= y + 1;
                if y = 31 then
                    y <= 0;
                end if;
            end if;
        end if;
    end if;
end process;

row2 <= row1 + 16;

process(clk)
begin

if state < 32 then
    SCLK <= clk;
end if;

if rising_edge(clk) then
state <= state + 1;
if state = 32 then
    oe <= '1';
elsif state = 33 then
    lat <= '1';
elsif state = 34 then
    lat <= '0';
elsif state = 35 then
    oe <= '0';
elsif state = 36 then
    if row1 = 15 then
        row1 <= 0;
    else
        row1 <= row1 + 1;
    end if;

    address <= std_logic_vector(to_unsigned(row1,4));
    state <= 0;
end if;
end if;

if state < 32 and falling_edge(clk) then
    if row1 = y and x = state and y <= 15 then
        rgb1 <= "001";
    else
        rgb1 <= "000";
    end if;
    if row2 = y and x = state and y >= 16 and y <= 31 then
        rgb2 <= "001";
    else
        rgb2 <= "000";
    end if;
end if;
    
end process;
end Behavioral;
