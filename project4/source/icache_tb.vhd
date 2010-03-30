-- icache testbench

use work.common.all;
use work.common_tb.all;
use work.icache_pkg.all;
use work.varb_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity icache_tb is
end;

architecture test of icache_tb is

   signal clk        : std_logic := '0';
   signal nrst       : std_logic := '0';

   signal icache_in  : icache_in_type;
   signal icache_out : icache_out_type;

   signal varb_in    : varb_in_type;
   signal varb_out   : varb_out_type;

   signal stop       : std_logic := '1';

   signal test_num   : integer := 0;


begin

   icache_b : icache_r port map (
      clk => clk, nrst => nrst, d => icache_in, q => icache_out
   );

   varb_b : varb_r port map (
      clk => clk, nrst => nrst, d => varb_in, q => varb_out
   );

   -- clock when stop isnt asserted
   clk <= not clk and not stop after clk_per/2;


   varb_in.addr <= icache_out.mem.addr;
   varb_in.ren <= icache_out.mem.ren;
   varb_in.wen <= '0';
   varb_in.wdat <= to_word(0);

   icache_in.mem.dat <= varb_out.rdat;
   icache_in.mem.done <= varb_out.done;

   process
      variable rand_state : prng_state;
      variable rand  : word;
   begin

      prng_init(rand_state, to_dword(243));

      -- initial values
      icache_in.cpu.addr <= to_word(0);
      icache_in.cpu.ren <= '1';

      -- start the clock and reset
      stop <= '0';
      nrst <= '0';
      tick(clk, 1);
      nrst <= '1';


      -- try reading the first 16 words
      -- each is a miss

      test_num <= test_num + 1;

      for i in 0 to 15 loop
         icache_in.cpu.addr <= to_word(i*4);
         -- wait a cycle
         wait until falling_edge(clk);
         -- see if we have a hit
         if icache_out.cpu.hit = '0' then
            -- we didnt, so wait for the hit
            wait until icache_out.cpu.hit = '1';
            -- and advance to the falling edge
            wait until falling_edge(clk);
         end if;
         assert icache_out.cpu.dat = to_word(i*4);
         tick(clk, 1);
      end loop;


      -- try reading the first 16 words
      -- each is a hit

      test_num <= test_num + 1;

      for i in 0 to 15 loop
         icache_in.cpu.addr <= to_word(i*4);
         -- wait a cycle
         wait until falling_edge(clk);
         -- see if we have a hit
         if icache_out.cpu.hit = '0' then
            -- we didnt, so wait for the hit
            wait until icache_out.cpu.hit = '1';
            -- and advance to the falling edge
            wait until falling_edge(clk);
         end if;
         assert icache_out.cpu.dat = to_word(i*4);
         tick(clk, 1);
      end loop;

      -- try reading the second 16 words
      -- each is a miss

      test_num <= test_num + 1;

      for i in 16 to 31 loop
         icache_in.cpu.addr <= to_word(i*4);
         -- wait a cycle
         wait until falling_edge(clk);
         -- see if we have a hit
         if icache_out.cpu.hit = '0' then
            -- we didnt, so wait for the hit
            wait until icache_out.cpu.hit = '1';
            -- and advance to the falling edge
            wait until falling_edge(clk);
         end if;
         assert icache_out.cpu.dat = to_word(i*4);
         tick(clk, 1);
      end loop;


      -- stop the clock
      stop <= '1';
      tick(clk, 1);
      wait;

   end process;

end;

