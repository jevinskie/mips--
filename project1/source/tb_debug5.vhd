--library ieee,gold_lib;
library ieee;
use ieee.std_logic_1164.all;
--use gold_lib.all;

entity tb_debug5 is
  generic (Period : Time := 100 ns);
end tb_debug5;

architecture TEST of tb_debug5 is

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

  component debug5
    PORT(
         clk : in std_logic;
         nReset : in std_logic;
         output0 : out std_logic;
         output1 : out std_logic;
         output2 : out std_logic
    );
  end component;

-- Insert signals Declarations here
  signal clk : std_logic;
  signal nReset : std_logic;
  signal output0 : std_logic;
  signal output1 : std_logic;
  signal output2 : std_logic;

begin
  DUT: debug5 port map(
                clk => clk,
                nReset => nReset,
                output0 => output0,
                output1 => output1,
                output2 => output2
                );

  CLKGEN: process
    variable CLK_tmp: std_logic := '0';
  begin
    CLK_tmp := not CLK_tmp;
    clk <= CLK_tmp;
    wait for Period/2;
  end process;



process

  begin

-- Insert TEST BENCH Code Here


    nReset <= '0';
    wait for 100 ns;
    nReset <= '1';

    wait for 10000 ns;

  end process;
end TEST;
