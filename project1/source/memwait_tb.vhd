-- memwait testbench

use work.common.all;
use work.common_tb.all;
use work.memwait_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memwait_tb is
end;

architecture test of memwait_tb is

   signal clk           : std_logic := '0';
   signal nrst          : std_logic := '0';
   signal memwait_in    : memwait_in_type;
   signal memwait_out   : memwait_out_type;

   signal stop : std_logic := '1';


   type memwait_tb_vector is record
      d : memwait_in_type;
      q : memwait_out_type;
   end record;

   --type vector_table is array (natural range <>) of pc_tb_vector;

   --constant vecs : vector_table := (
   --);


begin

   memwait_b : memwait_r port map (
      clk => clk, nrst => nrst, d => memwait_in, q => memwait_out
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

      memwait_in.op <= special_op;
      tick(clk, 1);
      assert memwait_out.memwait = '0';

      memwait_in.op <= lw_op;
      tick(clk, 1);
      assert memwait_out.memwait = '1';
      tick(clk, 1);
      assert memwait_out.memwait = '0';
      tick(clk, 1);
      assert memwait_out.memwait = '1';
      tick(clk, 1);
      assert memwait_out.memwait = '0';

      memwait_in.op <= special_op;
      tick(clk, 1);
      assert memwait_out.memwait = '0';

      memwait_in.op <= sw_op;
      tick(clk, 1);
      assert memwait_out.memwait = '1';
      tick(clk, 1);
      assert memwait_out.memwait = '0';
      tick(clk, 1);
      assert memwait_out.memwait = '1';
      tick(clk, 1);
      assert memwait_out.memwait = '0';

      -- stop the clock
      stop <= '1';
      tick(clk, 1);
      wait;

   end process;

end;

