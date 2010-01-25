--library ieee,gold_lib;
library ieee;
use ieee.std_logic_1164.all;
--use gold_lib.all;

entity tb_debug4 is
end tb_debug4;

architecture TEST of tb_debug4 is

  function INT_TO_STD_LOGIC( X: INTEGER; NumBits: INTEGER )
     return STD_LOGIC_VECTOR is
    variable RES : STD_LOGIC_VECTOR(NumBits-1 downto 0);
    variable tmp : INTEGER;
  begin
    tmp := X;
    for i in 0 to NumBits-1 loop
      if (tmp mod 2)=1 then
        res(i) := '1';
      else
        res(i) := '0';
      end if;
      tmp := tmp/2;
    end loop;
    return res;
  end;

  component debug4
    PORT(
         reset : in STD_LOGIC 
    );
  end component;

-- Insert signals Declarations here
  signal reset : STD_LOGIC ;

-- signal <name> : <type>;

begin
  DUT: debug4 port map(
                reset => reset
                );

--   GOLD: <GOLD_NAME> port map(<put mappings here>);

process

  begin

-- Insert TEST BENCH Code Here

    reset <= '1';
    wait for 50 ns;
    reset <= '0';
    wait;    

  end process;
end TEST;
