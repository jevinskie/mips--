-- dcache testbench

use work.common.all;
use work.common_tb.all;
use work.dcache_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dcache_tb is
end;

architecture test of dcache_tb is

   signal clk  : std_logic := '0';
   signal nrst : std_logic := '0';
   signal d    : dcache_in_type;
   signal q    : dcache_out_type;

   signal stop : std_logic := '1';

begin

   dcache_b : dcache_r port map (
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
      d.cpu.addr <= to_word(0);
      d.cpu.ren <= '1';
      d.mem.dat <= to_word(0);

      -- start the clock and reset
      stop <= '0';
      nrst <= '0';
      tick(clk, 1);
      nrst <= '1';

      for i in 0 to 15 loop
         d.mem.dat <= to_word(i);
         d.cpu.addr <= to_word(i*4);
         tick(clk, 1);
         assert q.cpu.hit = '1';
      end loop;

      for i in 0 to 15 loop
         d.mem.dat <= to_word(i);
         d.cpu.addr <= to_word(i*4);
         tick(clk, 1);
         assert q.cpu.hit = '1';
      end loop;

      for i in 16 to 31 loop
         d.mem.dat <= to_word(i);
         d.cpu.addr <= to_word(i*4);
         tick(clk, 1);
         assert q.cpu.hit = '1';
      end loop;

      d.cpu.ren <= '0';

      for i in 32 to 47 loop
         d.mem.dat <= to_word(i);
         d.cpu.addr <= to_word(i*4);
         tick(clk, 1);
      end loop;

      d.cpu.ren <= '1';

      for i in 32 to 47 loop
         d.mem.dat <= to_word(i);
         d.cpu.addr <= to_word(i*4);
         tick(clk, 1);
         assert q.cpu.hit = '1';
      end loop;


      -- stop the clock
      stop <= '1';
      tick(clk, 1);
      wait;

   end process;

end;

