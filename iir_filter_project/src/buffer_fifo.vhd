library ieee;
  use ieee.std_logic_1164.all;

entity buffer_fifo is
  generic (
    DEPTH      : natural := 5;
    DATA_WIDTH : natural := 16
  );
  port(
    clk      : in std_logic;
    resetn   : in std_logic;
    en       : in std_logic;
    data_in  : in std_logic_vector(DATA_WIDTH - 1 downto 0);       -- input data of the buffer
    data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0);      -- content of the last register in the buffer
    first_value : out std_logic_vector(DATA_WIDTH - 1 downto 0)    -- content of the first register in the buffer
  );
end entity;

architecture struct of buffer_fifo is
  
  --------------------------------------------------------------
  -- Components declaration
  --------------------------------------------------------------
  component d_flip_flop_n is
    generic ( NUM : natural := 16 );
    port (
      clk     : in std_logic;
      resetn  : in std_logic;
      en      : in std_logic;
      di      : in std_logic_vector(NUM - 1 downto 0);
      do       : out std_logic_vector(NUM - 1 downto 0)
    );
  end component;

  --------------------------------------------------------------
  -- Signals declaration
  --------------------------------------------------------------
  type internal_fifo_signal is array (0 to DEPTH - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal int_fifo : internal_fifo_signal;       --signal which represents a 5 elements array of std_logic_vector

begin

  GEN: for i in 0 to DEPTH - 1 generate
    --map of the first register
    FIRST: if i = 0 generate
    d_flip_flop_n_1: d_flip_flop_n
        generic map ( NUM  => DATA_WIDTH )
        port map (
          clk     => clk,
          resetn  => resetn,
          en      => en,
          di       => data_in,
          do       => int_fifo(i)
        );
    end generate;
    
    --map of the other regesters
    SECONDS: if i > 0 and i < DEPTH generate
    d_flip_flop_n_2: d_flip_flop_n
        generic map ( NUM  => DATA_WIDTH )
        port map (
          clk     => clk,
          resetn  => resetn,
          en      => en,
          di       => int_fifo(i-1),
          do       => int_fifo(i)
        );
    end generate;

  end generate;

  -- Connect the output
  first_value <= int_fifo(0);
  data_out <= int_fifo(DEPTH-1);
  
end architecture;