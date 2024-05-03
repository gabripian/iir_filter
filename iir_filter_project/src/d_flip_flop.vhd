library IEEE;
use IEEE.std_logic_1164.all;

entity d_flip_flop is
    
	port (
		clk : in std_logic;
        resetn : in std_logic;
        en : in std_logic;
        di : in std_logic;
        do : out std_logic
	);

end entity;

architecture rtl of d_flip_flop is

    signal di_s : std_logic;
    signal do_s : std_logic;

begin
    p_DFF: process(clk , resetn)
	
    begin
        if resetn = '0' then
            do_s <= '0';             --reset
        elsif rising_edge(clk) then
            do_s <= di_s;            -- read the current input
        end if;
    end process;

    -- multiplexer implementation
    -- so it is the implementation of tne enable condition
    di_s <= di when en ='1' else do_s; 

    do <= do_s; -- do_s is equals to the output

end architecture;