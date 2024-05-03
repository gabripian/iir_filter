library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.math_real.all;

entity iir_filter_tb is
end entity;

architecture beh of iir_filter_tb is
    constant CLK_PERIOD : time := 100 ns; -- clock period duration
    constant NUM : positive := 16; -- number of bits of the input x and output y

    component iir_filter is
        generic (
            Nbit : positive := NUM
        );
        port (
            clk      : in std_logic;
            resetn   : in std_logic;
            x        : in  std_logic_vector(Nbit - 1 downto 0);
            x_valid  : in std_logic;
            y        : out std_logic_vector(Nbit - 1 downto 0);
            y_valid  : out std_logic
        );
    end component;

    signal clk : std_logic := '0'; -- initialized to 0.
    signal resetn_signal : std_logic := '0'; -- initialized to 0.
    signal input_x : std_logic_vector (NUM - 1 downto 0) := (others => '0'); -- initialized to 0.
    signal input_x_valid : std_logic := '0';  -- initialized to 0.
    signal output_y : std_logic_vector (NUM - 1 downto 0); -- not initialized.
    signal output_y_valid : std_logic;  -- not initialized.
    signal testing : boolean := true; -- initialized to true

begin

    clk <= (not clk) after CLK_PERIOD/2 when testing else
        '0'; -- after half Clock Period, negate the clock variable

    filter : iir_filter port map(
        clk => clk,
        resetn => resetn_signal,
        x => input_x,
        x_valid => input_x_valid,
        y => output_y,
        y_valid => output_y_valid
    );

    STIMULUS : process begin

        -- Start of the safety period.
        -- Default condition
        input_x <= std_logic_vector(to_signed(0, input_x'length)); -- Initialized to 0
        resetn_signal <= '0'; -- reset initialized at 0.
        input_x_valid <= '0';

         -- Wait for 2 clock cycles.
        wait until rising_edge(clk);
        wait until rising_edge(clk);

        resetn_signal <= '1';
        wait until rising_edge(clk);
        -- End of the safety period.

        --Test case: full buffer validity after reset
        input_x_valid <= '1';
       
        input_x <= "0000000000000101";     -- 5
        
        wait until rising_edge(clk);

        input_x_valid <= '1';

        input_x <= "0000000000000100";     -- 4

        wait until rising_edge(clk);

        input_x_valid <= '1';

        input_x <= "0000000000000011";      -- 3
        
        wait until rising_edge(clk);

        input_x_valid <= '1';

        input_x <= "0000000000000010";      -- 2
        
        wait until rising_edge(clk);

        input_x_valid <= '1';
        
        input_x <= "0000000000000001";      -- 1 
       
        wait until rising_edge(clk);
        -- end Test case


        --Test case: poitive overflow
        input_x_valid <= '1';
       
        input_x <= "0111111111111111";    -- 32767
        
        wait until rising_edge(clk);

        input_x_valid <= '1';
       
        input_x <= "0111111111111111";     -- 32767
        
        wait until rising_edge(clk);

        input_x_valid <= '1';

        input_x <= "0111111111111111";     -- 32767

        wait until rising_edge(clk);

        input_x_valid <= '1';

        input_x <= "0111111111111111";     -- 32767
        
        wait until rising_edge(clk);


        input_x_valid <= '1';
        
        input_x <= "1000000000000000";     -- -32768
       
        wait until rising_edge(clk);

        input_x_valid <= '1';
        
        input_x <= "1000000000000000";     -- -32768
       
        wait until rising_edge(clk);

        input_x_valid <= '1';
        
        input_x <= "1000000000000000";     -- -32768
       
        wait until rising_edge(clk);

        input_x_valid <= '1';
        
        input_x <= "1000000000000000";     -- -32768
       
        wait until rising_edge(clk);

        input_x_valid <= '1';
        
        input_x <= "1000000000000000";     -- -32768
       
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        -- end Test case

        --reset
        resetn_signal <= '0'; 

        wait until rising_edge(clk);

        resetn_signal <= '1';
        --end reset

        --Test case: negative overflow
        input_x_valid <= '1';
       
        input_x <= "1000000000000000";     -- -32768
         
        wait until rising_edge(clk);
 
        input_x_valid <= '1';
 
        input_x <= "1000000000000000";     -- -32768
 
        wait until rising_edge(clk);
 
        input_x_valid <= '1';
 
        input_x <= "1000000000000000";     -- -32768
         
        wait until rising_edge(clk);
 
        input_x_valid <= '1';
 
        input_x <= "1000000000000000";     -- -32768
         
        wait until rising_edge(clk);
 
        input_x_valid <= '1';
         
        input_x <= "0111111111111111";     -- 32767
        
        wait until rising_edge(clk);
 
        input_x_valid <= '1';
         
        input_x <= "0111111111111111";     -- 32767
        
        wait until rising_edge(clk);
 
        input_x_valid <= '1';
         
        input_x <= "0111111111111111";     -- 32767
        
        wait until rising_edge(clk);
 
        input_x_valid <= '1';
         
        input_x <= "0111111111111111";     -- 32767
        
        wait until rising_edge(clk);
 
        input_x_valid <= '1';
         
        input_x <= "0111111111111111";     -- 32767
        
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        -- end Test case
 
        --reset
        resetn_signal <= '0'; 
         
        wait until rising_edge(clk);
 
        resetn_signal <= '1';
        --end reset
       
       
        -- Test case: normal input values
        input_x_valid <= '1';

        input_x <= "0111111111111111";    -- 32767
        
        wait until rising_edge(clk);

        input_x <= "0000000000000001";     -- 1 this input is not valid, so it is never iserted in the filter

        input_x_valid <= '0';

        wait until rising_edge(clk);

        input_x_valid <= '1';

        input_x <= "0000101000101010";     -- 2602
        
        wait until rising_edge(clk);

        input_x_valid <= '1';

        input_x <= "0010101010101010";      -- 10922
        
        wait until rising_edge(clk);
    
        input_x_valid <= '1';
        
        input_x <= "0000110011001100";       -- 3276
       
        wait until rising_edge(clk);

        input_x_valid <= '1';
       
        input_x <= "0010110001000110";       -- 11334
        
        wait until rising_edge(clk);

        input_x_valid <= '1';
       
        input_x <= "0010110001000111";       -- 11335
        
        wait until rising_edge(clk);

        input_x_valid <= '1';
       
        input_x <= "0000000000001010";        -- 10
        
        wait until rising_edge(clk);

        input_x_valid <= '1';
       
        input_x <= "0000000000100000";         -- 32
        
        wait until rising_edge(clk);

        input_x <= "0000000000000010";       -- 2 this input is not valid, so it is never iserted in the filter

        input_x_valid <= '0';
 
        wait until rising_edge(clk);

        input_x <= "0000000000000011";       -- 3 this input is not valid, so it is never iserted in the filter

        input_x_valid <= '0';
 
        wait until rising_edge(clk);

        input_x_valid <= '1';
       
        input_x <= "0000000001000110";      -- 70
        
        wait until rising_edge(clk);

        input_x_valid <= '1';
       
        input_x <= "0000000000001100";      -- 10
        
        wait until rising_edge(clk);

        input_x_valid <= '1';
       
        input_x <= "0000000000000100";      -- 4
        
        wait until rising_edge(clk);
        -- end test case

        -- Reset test
        wait for 200 ns;
        wait until rising_edge(clk);
        resetn_signal <= '0';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        resetn_signal <= '1';
        -- end of the reset test.

        wait for 300 ns;

        -- testing go false
        testing <= false;
        wait until rising_edge(clk);
    end process;

end architecture;