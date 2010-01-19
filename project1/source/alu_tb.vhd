-- alu testbench

use work.common.all;
use work.common_tb.all;
use work.alu_comp.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is
end;

architecture test of alu_tb is

   signal clk     : std_logic := '0';
   signal nrst    : std_logic := '0';
   signal alu_in  : alu_in_type;
   signal alu_out : alu_out_type;

   signal stop : std_logic := '1';


   type alu_tb_vector is record
      d : alu_in_type;
      q : alu_out_type;
   end record;

   type vector_table is array (natural range <>) of alu_tb_vector;

   constant vecs : vector_table :=
   (
      -- adding nothing  to nothing
--      (d => (a => to_word(0), b => to_word(0), op => add_alu_op),
--       q => (r => to_word(0), n => '0', v => '0', z => '1')),
      
      -- overflow to 0
      (d => (a => x"FFFFFFFF", b => to_word(1), op => add_alu_op),
       q => (r => to_word(0), n => '0', v => '1', z => '1')),

      -- make sure INT_MAX - 1 works
      (d => (a => x"FFFFFFFF", b => to_word(1), op => sub_alu_op),
       q => (r => to_word(0), n => '1', v => '0', z => '0'))
   );


begin

   alu_b : alu port map (
      d => alu_in, q => alu_out
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

      for i in vecs'range loop
         alu_in <= vecs(i).d;
         tick(clk, 1);
         assert alu_out = vecs(i).q;
      end loop;

      -- try to add numbers
--      alu_in.op <= add_alu_op;
--      for i in 0 to 7 loop
--         for j in 0 to 7 loop
--            alu_in.a <= to_word(i);
--            alu_in.b <= to_word(j);
--            tick(clk, 1);
--            assert alu_out.r = to_word(i+j);
--         end loop;
--      end loop;
      
      -- stop the clock
      stop <= '1';
      tick(clk, 1);
      wait;

   end process;

end;

