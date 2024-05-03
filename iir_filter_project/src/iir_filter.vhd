library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- implemented difference equation: y[n]= (y[n-1] - 1/4 * x[n] + 1/4 * x[n-4])

entity iir_filter is
    generic (
      Nbit : positive := 16        -- dimension of x and y
    );
    port (
        clk      : in std_logic;
        resetn   : in std_logic;
        x        : in std_logic_vector(Nbit - 1 downto 0);
        x_valid  : in std_logic;
        y        : out std_logic_vector(Nbit - 1 downto 0);
        y_valid  : out std_logic
      );
end entity;

architecture beh of iir_filter is

  --------------------------------------------------------------
  -- Components declaration
  --------------------------------------------------------------
	
  component d_flip_flop_n is
    generic ( 
        NUM : Positive := 16
    );
    port (
        clk    : in  std_logic;
        resetn : in  std_logic;     -- reset active low
        en     : in  std_logic;
        di     : in  std_logic_vector(NUM - 1 downto 0);
        do     : out std_logic_vector(NUM - 1 downto 0)
    );
  end component;

  component d_flip_flop is
    port (
        clk    : in  std_logic;
        resetn : in  std_logic;      -- reset active low
        en     : in  std_logic;
        di     : in  std_logic;
        do     : out std_logic
    );
  end component;

	-- buffer FIFO is used to store the current and the four previous values of the input
	component buffer_fifo is
    generic (
      DEPTH      : natural := 5;
      DATA_WIDTH : natural := 16
    );
    port(
      clk      : in std_logic;
      resetn   : in std_logic;            -- reset active low
      en       : in std_logic;
      data_in  : in std_logic_vector(DATA_WIDTH - 1 downto 0);
      data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0);
      first_value : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
	end component;

 --------------------------------------------------------------
  -- Signals declaration
  -------------------------------------------------------------
  
	constant depth : natural := 5;          -- number of registers in the buffer
	constant data_width : natural := 16;    -- size of the result, the first and last registers of the buffer
  constant depth_counter : natural := 3;  -- size of the counter

  signal x_ff   : std_logic_vector(data_width - 1 downto 0);      -- output of the flip-flop of the input x
  signal y_ff   : std_logic_vector(data_width - 1 downto 0);      -- input of the flip-flop of the output y
  
  signal x_valid_ff  : std_logic;                                 -- output of the flip-flop of the input x_valid
  signal y_valid_ff  : std_logic;                                 -- input of the flip-flop of the output y_valid

  signal counter  : std_logic_vector(depth_counter - 1 downto 0);     -- count the values inside the buffer

	signal buffer_out : std_logic_vector(data_width - 1 downto 0);      -- last register of the buffer
  signal first_reg  : std_logic_vector(data_width - 1 downto 0);      -- first register of the buffer
  signal result     : std_logic_vector(data_width - 1 downto 0);      -- result of the difference equation

begin
	
  d_flip_flop_x: d_flip_flop_n
  generic map (NUM => Nbit)
  port map (
      clk    => clk,
      resetn => resetn,
      en     => '1',     -- always enabled for input
      di     => x,
      do     => x_ff
  );

  d_flip_flop_x_valid: d_flip_flop
  port map (
      clk    => clk,
      resetn => resetn,
      en     => '1',       -- always enabled for input
      di     => x_valid,
      do     => x_valid_ff
  );
 
  d_flip_flop_y: d_flip_flop_n
  generic map (NUM => Nbit)
  port map (
      clk => clk,
      resetn => resetn,
      en  => y_valid_ff,    -- enabled for input only if the output data is valid
      di  => result, 
      do  => y_ff
  );
 
  d_flip_flop_y_valid: d_flip_flop
  port map (
      clk    => clk,
      resetn => resetn,
      en     => '1',         -- always enabled for output
      di     => y_valid_ff,
      do     => y_valid
  );

	-- Shift register that stores the last 5 x[...] values (from x[k] to x[k-4]).
	buffer_f: buffer_fifo
    generic map (
      DEPTH       => depth,
      DATA_WIDTH  => data_width
    )
    port map (
      clk => clk,
      resetn => resetn,
      en => x_valid_ff,     -- enabled for input only if the x value is valid
      data_in => x_ff,
      data_out => buffer_out,
      first_value  => first_reg
      
    );

    p_filter: process(clk, resetn)
    begin
  
      if resetn = '0' then
        -- reset
        result <= (others => '0');
        y_valid_ff <= '0';
        counter <= "000";
          
      elsif rising_edge(clk) then
        -- check if the input is valid
        if x_valid_ff = '1' then
          
          -- check if the buffer is completey full, if it is full, the result can be computed, otherwise the result stays the same as before and the counter is incremented
          if counter < "101" then
            counter <= std_logic_vector (signed (counter) + 1);
            y_valid_ff <= '0'; -- still 0 because even when the updated counter turns 101, the value will be updated durig next clock cycle
            result <= result;
          else
            counter <= counter;

            -- check if there is overflow for the y output
            if (signed(result) > "0000000000000000" and ((signed(buffer_out)/4) - (signed(first_reg)/4)) > "0000000000000000" and  
            (signed(result) + ((signed(buffer_out)/4) - (signed(first_reg)/4))) <  "0000000000000000") or
            (signed(result) < "0000000000000000" and ((signed(buffer_out)/4) - (signed(first_reg)/4)) < "0000000000000000" and  
            (signed(result) + ((signed(buffer_out)/4) - (signed(first_reg)/4))) >  "0000000000000000") then

              y_valid_ff <= '0';    -- invalid output
              result <= result;

            else
              y_valid_ff <= '1';    -- valid output
              result <= std_logic_vector(signed(result) - (signed(first_reg)/4) + (signed(buffer_out)/4));

            end if;
             
          end if;

        else
          -- if the input is not valid, the output is not valid anymore, and it gets the same value as before, like the counter
          y_valid_ff <= '0';
          result <= result;
          counter <= counter;
        end if;

      end if;
  
    end process;
	-- Connect the output
  y <= y_ff;
	
end architecture beh;