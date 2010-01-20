-- regfile testbench

use work.common.all;
use work.common_tb.all;
use work.regfile_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile_tb is
end;

architecture test of regfile_tb is

   signal clk     : std_logic := '0';
   signal nrst    : std_logic := '0';
   signal reg_in  : regfile_in_type;
   signal reg_out : regfile_out_type;

   signal stop : std_logic := '1';

begin

   regfile_b : regfile_r port map (
      clk => clk, nrst => nrst, d => reg_in, q => reg_out
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
      nrst <= '0';
      tick(clk, 1);
      nrst <= '1';
      tick(clk, 1);

      -- try writing to all of the registers
      reg_in.wen <= '1';
      for i in reg_index loop
         reg_in.wsel <= i;
         reg_in.rsel1 <= i;
         reg_in.rsel2 <= i;
         for j in 0 to 7 loop
            prng_gen(rand_state, rand);
            reg_in.wdat <= rand;
            tick(clk, 1);
            if i /= 0 then
               assert reg_out.rdat1 = reg_in.wdat and reg_out.rdat2 = reg_in.wdat;
            else
               assert reg_out.rdat1 = (reg_out.rdat1'range => '0') and reg_out.rdat1 = (reg_out.rdat2'range => '0');
            end if;
         end loop;
      end loop;

      -- stop the clock
      stop <= '1';
      tick(clk, 1);
      wait;

   end process;

end;

