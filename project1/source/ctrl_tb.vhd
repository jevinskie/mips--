-- control testbench

use work.common.all;
use work.common_tb.all;
use work.pc_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_tb is
end;

architecture test of pc_tb is

   signal clk     : std_logic := '0';
   signal nrst    : std_logic := '0';
   signal pc_in   : pc_in_type;
   signal pc_out  : pc_out_type;

   signal stop : std_logic := '1';


   type pc_tb_vector is record
      d : pc_in_type;
      q : pc_out_type;
   end record;

   type vector_table is array (natural range <>) of pc_tb_vector;

   constant vecs : vector_table := (
      -- assume a reset has set PC to 0
      (d => (op => special_op, imm => to_hword(0), j_addr => (others => '0'), z => '0', we => '1'),
       q => (pc => to_word(1*4))),

      -- another plain pc increment
      (d => (op => special_op, imm => to_hword(0), j_addr => (others => '0'), z => '0', we => '1'),
       q => (pc => to_word(2*4))),

      -- branch 13 words ahead
      -- 2 + 13 = 15
      (d => (op => beq_op, imm => to_hword(12), j_addr => (others => '0'), z => '1', we => '1'),
       q => (pc => to_word(15*4))),

      -- don't branch 13 words ahead
      -- 15 + 1 = 16
      (d => (op => beq_op, imm => to_hword(12), j_addr => (others => '0'), z => '0', we => '1'),
       q => (pc => to_word(16*4))),

      -- branch 7 words backwards
      -- 16 - 7 = 9
      (d => (op => beq_op, imm => to_hword(-8), j_addr => (others => '0'), z => '1', we => '1'),
       q => (pc => to_word(9*4))),

      -- bne branch 3 words forwards
      -- 9 + 3 = 12
      (d => (op => bne_op, imm => to_hword(2), j_addr => (others => '0'), z => '0', we => '1'),
       q => (pc => to_word(12*4))),

      -- bne dont branch 5 words forwards
      -- 12 + 1 = 13
      (d => (op => bne_op, imm => to_hword(4), j_addr => (others => '0'), z => '1', we => '1'),
       q => (pc => to_word(13*4))),

      -- bne branch 6 words backwards
      -- 13 - 6 = 7
      (d => (op => bne_op, imm => to_hword(-7), j_addr => (others => '0'), z => '0', we => '1'),
       q => (pc => to_word(7*4))),

      -- bne branch to same spot
      -- 7 - 0 = 7
      (d => (op => bne_op, imm => to_hword(-1), j_addr => (others => '0'), z => '0', we => '1'),
       q => (pc => to_word(7*4))),

      -- bne dont branch to same spot
      -- 7 + 1 = 8
      (d => (op => bne_op, imm => to_hword(-1), j_addr => (others => '0'), z => '1', we => '1'),
       q => (pc => to_word(8*4))),

      -- jump to 243
      (d => (op => j_op, imm => to_hword(0), j_addr => to_j_address(243), z => '0', we => '1'),
       q => (pc => to_word(243*4))),

      -- jump with a jal to 1337
      (d => (op => jal_op, imm => to_hword(0), j_addr => to_j_address(1337), z => '0', we => '1'),
       q => (pc => to_word(1337*4))),

      -- jump to the end of this 256MB segment
      (d => (op => j_op, imm => to_hword(0), j_addr => to_j_address(67108863), z => '0', we => '1'),
       q => (pc => to_word(67108863*4))),

      -- run the pc to the next segment
      (d => (op => special_op, imm => to_hword(0), j_addr => (others => '0'), z => '0', we => '1'),
       q => (pc => to_word(67108864*4))),

      -- jump to 0, but really, since we are at the start of the 256MB segment, stand still
      (d => (op => j_op, imm => to_hword(0), j_addr => to_j_address(0), z => '0', we => '1'),
       q => (pc => to_word(67108864*4))),

      -- halt the processor
      (d => (op => special_op, imm => to_hword(0), j_addr => to_j_address(0), z => '0', we => '0'),
       q => (pc => to_word(67108864*4)))
    );


begin

   pc_b : pc_r port map (
      clk => clk, nrst => nrst, d => pc_in, q => pc_out
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
      pc_in <= vecs(0).d;
      tick(clk, 1);

      for i in 1 to vecs'length-1 loop
         assert pc_out = vecs(i-1).q;
         pc_in <= vecs(i).d;
         tick(clk, 1);
      end loop;
      assert pc_out = vecs(vecs'length-1).q;
            
      -- stop the clock
      stop <= '1';
      tick(clk, 1);
      wait;

   end process;

end;

