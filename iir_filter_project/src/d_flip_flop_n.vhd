library IEEE;
use IEEE.std_logic_1164.all;

entity d_flip_flop_n is
    generic ( 
		NUM : Positive := 16
	);
	port (
		clk : in std_logic;
        resetn : in std_logic;
        en : in std_logic;
        di : in std_logic_vector(NUM - 1 downto 0);
        do : out std_logic_vector(NUM - 1 downto 0)
	);

end entity;

architecture rtl of d_flip_flop_n is

    signal di_s : std_logic_vector(NUM - 1 downto 0);
    signal do_s : std_logic_vector(NUM - 1 downto 0);

begin
    p_DFF: process(clk , resetn)
	
    begin
        if resetn = '0' then
            do_s <= (others => '0');  --reset
        elsif rising_edge(clk) then
            do_s <= di_s;             -- read the current input
        end if;
    end process;

    -- multiplexer implementation
    -- so it is the implementation of tne enable condition
    di_s <= di when en ='1' else do_s; 

    do <= do_s; -- do_s is equals to the output

end architecture;