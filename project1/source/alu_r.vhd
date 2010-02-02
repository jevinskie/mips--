-- this is the alu (records style) for the cpu

use work.common.all;
use work.alu_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity alu_r is
   port (
      d : in  alu_in_type;
      q : out alu_out_type
   );
end;


architecture twoproc of alu_r is
begin

   -- combinatiorial process
   comb : process(d)
      variable res : word;
   begin

      -- module algorithm
      case d.op is
         when sll_alu_op =>
            res := d.a sll to_integer(resize(d.b, 5));
         when srl_alu_op =>
            res := d.a srl to_integer(resize(d.b, 5));
         when add_alu_op =>
            res := d.a + d.b;
         when sub_alu_op =>
            res := d.a - d.b;
         when and_alu_op =>
            res := d.a and d.b;
         when nor_alu_op =>
            res := d.a nor d.b;
         when or_alu_op =>
            res := d.a or d.b;
         when xor_alu_op =>
            res := d.a xor d.b;
         when slt_alu_op =>
            -- rs < rt ? 1 : 0
            -- a < b ? 1 : 0
            -- subtract (a - b) and if negative set 1 else 0
            if signed(d.a) < signed(d.b) then
               res := to_word(1);
            else
               res := to_word(0);
            end if;
         when sltu_alu_op =>
            -- rs < rt ? 1 : 0
            -- a < b ? 1 : 0
            -- subtract (a - b) and if negative set 1 else 0
            -- then if sign(a) != sign(b), flip the result
            if d.a < d.b then
               res := to_word(1);
            else
               res := to_word(0);
            end if;
         when others =>
            res := (others => '0');
            assert false;
      end case;

      -- drive module outputs

      -- drive the result output
      q.r <= res;

      --drive the flags
      
      -- zero
      if res = (res'range => '0') then
         q.z <= '1';
      else
         q.z <= '0';
      end if;

      -- negative
      q.n <= res(res'high);

      -- overflow
      if d.op = add_alu_op then
         q.v <= calc_overflow(d.a, d.b, res, '0');
      elsif d.op = sub_alu_op then
         q.v <= calc_overflow(d.a, d.b, res, '1');
      else
         q.v <= '0';
      end if;
   end process;

end;

