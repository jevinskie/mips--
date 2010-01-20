-- adder/subtractor testbench

use work.common.all;
use work.common_tb.all;
use work.addsub_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity addsub_tb is
end;

architecture test of addsub_tb is

   signal clk        : std_logic := '0';
   signal addsub_in  : addsub_in_type;
   signal addsub_out : addsub_out_type;
   signal stop       : std_logic := '1';


   type addsub_tb_vector is record
      d : addsub_in_type;
      q : addsub_out_type;
   end record;

   type vector_table is array (natural range <>) of addsub_tb_vector;

   constant vecs : vector_table := (
      -- 2 + 2 = 4 (not 5?)
      (d => (a => to_word(2), b => to_word(2), sub => '0'),
       q => (r => to_word(4), v => '0')),

      -- test overflow
      (d => (a => x"7FFFFFFF", b => to_word(1), sub => '0'),
       q => (r => x"80000000", v => '1')),

      -- 0 + 0 = 0
      (d => (a => to_word(0), b => to_word(0), sub => '0'),
       q => (r => to_word(0), v => '0')),

      -- -1 + 1 = 0
      (d => (a => to_word(-1), b => to_word(1), sub => '0'),
       q => (r => to_word(0), v => '0')),

      -- -1 + -1 = -2
      (d => (a => to_word(-1), b => to_word(-1), sub => '0'),
       q => (r => to_word(-2), v => '0')),

      -- -1 - 1 = -2
      (d => (a => to_word(-1), b => to_word(1), sub => '1'),
       q => (r => to_word(-2), v => '0')),

      -- 243 - -1337 = 1580
      (d => (a => to_word(243), b => to_word(-1337), sub => '1'),
       q => (r => to_word(1580), v => '0'))
    );


begin

   addsub_b : addsub_r port map (
      d => addsub_in, q => addsub_out
   );


   -- clock when stop isnt asserted
   clk <= not clk and not stop after clk_per/2;

   process
      variable rand_state : prng_state;
      variable rand  : word;
   begin

      prng_init(rand_state, to_dword(243));

      -- start the clock and reset
      stop <= '0';


      -- go through the test vectors for the adder/subtractor
      for i in vecs'range loop
         addsub_in <= vecs(i).d;
         tick(clk, 1);
         assert addsub_out = vecs(i).q;
      end loop;


      -- stop the clock
      stop <= '1';
      tick(clk, 1);
      wait;

   end process;

end;

