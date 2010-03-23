-- dcache testbench

use work.common.all;
use work.common_tb.all;
use work.dcache_pkg.all;
use work.varb_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dcache_tb is
end;

architecture test of dcache_tb is

   signal clk        : std_logic := '0';
   signal nrst       : std_logic := '0';
   
   signal dcache_in  : dcache_in_type;
   signal dcache_out : dcache_out_type;

   signal varb_in    : varb_in_type;
   signal varb_out   : varb_out_type;

   signal stop       : std_logic := '1';

begin

   dcache_b : dcache_r port map (
      clk => clk, nrst => nrst, d => dcache_in, q => dcache_out
   );

   varb_b : varb_r port map (
      clk => clk, nrst => nrst, d => varb_in, q => varb_out
   );

   -- clock when stop isnt asserted
   clk <= not clk and not stop after clk_per/2;

   varb_in.addr <= dcache_out.mem.addr;
   varb_in.ren <= dcache_out.mem.ren;
   varb_in.wen <= dcache_out.mem.wen;
   varb_in.wdat <= dcache_out.mem.wdat;

   dcache_in.mem.rdat <= varb_out.rdat;
   dcache_in.mem.done <= varb_out.done;

   process
      variable rand_state : prng_state;
      variable rand  : word;
   begin

      prng_init(rand_state, to_dword(243));

      -- initial values
      dcache_in.cpu.addr <= to_word(0);
      dcache_in.cpu.wdat <= x"BAADCAFE";
      dcache_in.cpu.ren <= '0';
      dcache_in.cpu.wen <= '0';
      dcache_in.cpu.halt <= '0';

      -- start the clock and reset
      stop <= '0';
      nrst <= '0';
      tick(clk, 1);
      nrst <= '1';

      --dcache_in.cpu.ren <= '1';
      --for i in 0 to 63 loop
      --   dcache_in.cpu.addr <= to_word(i*4);
      --   -- wait a cycle
      --   wait until falling_edge(clk);
      --   -- see if we have a hit
      --   if dcache_out.cpu.hit = '0' then
      --      -- we didnt, so wait for the hit
      --      wait until dcache_out.cpu.hit = '1';
      --      -- and advance to the falling edge
      --      wait until falling_edge(clk);
      --   end if;
      --   assert dcache_out.cpu.rdat = to_word(i*4);
      --   tick(clk, 1);
      --end loop;
      --dcache_in.cpu.ren <= '0';

      -- fill the first 32 words with 0-31
      dcache_in.cpu.wen <= '1';
      for i in 0 to 31 loop
         dcache_in.cpu.addr <= to_word(i*4);
         dcache_in.cpu.wdat <= to_word(i);
         -- wait a cycle
         wait until falling_edge(clk);
         -- see if we have a hit
         if dcache_out.cpu.hit = '0' then
            -- we didnt, so wait for the hit
            wait until dcache_out.cpu.hit = '1';
            -- and advance to the falling edge
            wait until falling_edge(clk);
         end if;
         tick(clk, 1);
      end loop;
      dcache_in.cpu.wen <= '0';

      -- read out the first 32 words and make sure 0-31 were written
      -- there should be no cache misses
      dcache_in.cpu.ren <= '1';
      for i in 0 to 31 loop
         dcache_in.cpu.addr <= to_word(i*4);
         -- wait a cycle
         wait until falling_edge(clk);
         -- see if we have a hit
         if dcache_out.cpu.hit = '0' then
            -- we didnt, so wait for the hit
            wait until dcache_out.cpu.hit = '1';
            -- and advance to the falling edge
            wait until falling_edge(clk);
         end if;
         assert dcache_out.cpu.rdat = to_word(i);
         tick(clk, 1);
      end loop;
      dcache_in.cpu.ren <= '0';

      
      -- read out the second set of 32 words
      -- every entry in the cache should be written back before being replaced
      dcache_in.cpu.ren <= '1';
      for i in 32 to 63 loop
         dcache_in.cpu.addr <= to_word(i*4);
         -- wait a cycle
         wait until falling_edge(clk);
         -- see if we have a hit
         if dcache_out.cpu.hit = '0' then
            -- we didnt, so wait for the hit
            wait until dcache_out.cpu.hit = '1';
            -- and advance to the falling edge
            wait until falling_edge(clk);
         end if;
         assert dcache_out.cpu.rdat = to_word(i*4);
         tick(clk, 1);
      end loop;
      dcache_in.cpu.ren <= '0';


      -- read out the first 32 words and make sure 0-31 were written back to memory
      dcache_in.cpu.ren <= '1';
      for i in 0 to 31 loop
         dcache_in.cpu.addr <= to_word(i*4);
         -- wait a cycle
         wait until falling_edge(clk);
         -- see if we have a hit
         if dcache_out.cpu.hit = '0' then
            -- we didnt, so wait for the hit
            wait until dcache_out.cpu.hit = '1';
            -- and advance to the falling edge
            wait until falling_edge(clk);
         end if;
         assert dcache_out.cpu.rdat = to_word(i);
         tick(clk, 1);
      end loop;
      dcache_in.cpu.ren <= '0';


      --dcache_in.cpu.wen <= '1';
      --for i in 0 to 15 loop
      --   dcache_in.cpu.addr <= to_word(i*4);
      --   dcache_in.cpu.wdat <= to_word(i);
      --   while dcache_out.cpu.hit = '0' loop
      --      tick(clk, 1);
      --   end loop;
      --   tick(clk, 1);
      --end loop;
      --dcache_in.cpu.wen <= '0';

      --dcache_in.cpu.ren <= '1';
      --for i in 0 to 15 loop
      --   dcache_in.cpu.addr <= to_word(i*4);
      --   while dcache_out.cpu.hit = '0' loop
      --      tick(clk, 1);
      --   end loop;
      --   assert dcache_out.cpu.rdat = to_word(i);
      --   tick(clk, 1);
      --end loop;
      --dcache_in.cpu.ren <= '0';


      -- stop the clock
      stop <= '1';
      tick(clk, 1);
      wait;

   end process;

end;

