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
      variable big_res : unsigned(res'high+1 downto 0);
   begin

      -- clear out the extended result
      big_res := (others => '0');

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
         when others =>
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
      if d.op = add_alu_op or d.op = sub_alu_op then
         if (d.a(d.a'high) = d.b(d.b'high)) and res(res'high) /= d.a(d.a'high) then
            q.v <= '1';
         else
            q.v <= '0';
         end if;
      else
         q.v <= '0';
      end if;
   end process;

end;


