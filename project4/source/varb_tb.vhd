-- virtual arbiter testbench

use work.common.all;
use work.common_tb.all;
use work.varb_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity varb_tb is
end;

architecture test of varb_tb is

   signal clk  : std_logic := '0';
   signal nrst : std_logic := '0';
   signal d    : varb_in_type;
   signal q    : varb_out_type;

   signal stop : std_logic := '1';

begin

   varb_b : varb_r port map (
      clk => clk, nrst => nrst, d => d, q => q
   );

   -- clock when stop isnt asserted
   clk <= not clk and not stop after clk_per/2;

   process
      variable rand_state : prng_state;
      variable rand  : word;
   begin

      prng_init(rand_state, to_dword(243));

      -- initial values
      d.addr <= to_word(0);
      d.ren <= '0';
      d.wen <= '0';
      d.wdat <= to_word(0);

      -- start the clock and reset
      stop <= '0';
      nrst <= '0';
      tick(clk, 1);
      nrst <= '1';

      d.ren <= '1';
      for i in 0 to 15 loop
         d.addr <= to_word(i*4);
         wait until q.done = '1';
         wait until falling_edge(clk);
         assert q.rdat = to_word(i*4);
         tick(clk, 1);
      end loop;
      d.ren <= '0';

      d.wen <= '1';
      for i in 0 to 15 loop
         d.addr <= to_word(i*4);
         d.wdat <= to_word(i);
         wait until q.done = '1';
         tick(clk, 1);
      end loop;
      d.wen <= '0';

      d.ren <= '1';
      for i in 0 to 15 loop
         d.addr <= to_word(i*4);
         wait until q.done = '1';
         wait until falling_edge(clk);
         assert q.rdat = to_word(i);
         tick(clk, 1);
      end loop;
      d.ren <= '0';
      
      -- stop the clock
      stop <= '1';
      tick(clk, 1);
      wait;

   end process;

end;

